const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
//const Scrobble = @import("../../types.zig").LastFMScrobble;
//const lastfm = @import("../../types.zig").LastFM;
//const UploadData = @import("../../types").UploadData;
const ScrobbleTypes = @import("../../types.zig");
const zeit = @import("zeit");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);

    if (try request.file("upload")) |file| {
        const params = try request.params();
        const source = try std.fmt.parseInt(u8, params.get("t").?.string.value, 10); // This param is required in HTML
        // Date limiting is broken atm
        const before_limiter: bool = if (params.get("bbool")) |_| true else false;
        const after_limiter: bool = if (params.get("abool")) |_| true else false;

        var scrobbles_view = try root.put("scrobbles", .array);
        var job = try request.job("process_scrobbles");
        var scrobbles_data = try job.params.put("scrobbles", .array);

        var skipped_tracks: u64 = 0;
        var limited_tracks: u64 = 0;

        // The only difference between a LastFM scrobble and a Spotify scrobble is the format.
        // I've made a branches for each, because doing it all in one made the readability terrible,
        // and formatting the date in particular was challenging. I could probably pull out the
        // actual appending at some point, since that's the same process for each, but I'm not
        // sure how to do that yet.
        switch (source) {
            0 => {
                const content: ScrobbleTypes.LastFM = try std.json.parseFromSliceLeaky(ScrobbleTypes.LastFM, request.allocator, file.content, .{});
                const before_limiting_date = if (before_limiter and params.get("b") != null) (try zeit.instant(.{ .source = .{ .iso8601 = params.get("b").?.string.value } })).unixTimestamp() * 1000 else 0;
                const after_limiting_date = if (after_limiter and params.get("a") != null) (try zeit.instant(.{ .source = .{ .iso8601 = params.get("a").?.string.value } })).unixTimestamp() * 1000 else 9_223_372_036_854_775_807;
                appends: for (content.scrobbles) |scrobble| {
                    // We can short-circuit on the limiter bools
                    if ((before_limiter or after_limiter) and (scrobble.date > before_limiting_date or scrobble.date < after_limiting_date)) continue :appends;
                    var value = try scrobbles_data.append(.object);

                    // This is so unnecessary, probably useful once I start doing Spotify integration though
                    inline for (std.meta.fields(ScrobbleTypes.LastFMScrobble)) |f| {
                        try value.put(f.name, @as(f.type, @field(scrobble, f.name)));
                    }
                    // Note sure why this works for ZMPL, but not for jobs.
                    try scrobbles_view.append(scrobble);
                }
            },
            1 => {
                const content: []ScrobbleTypes.SpotifyScrobble = try std.json.parseFromSliceLeaky([]ScrobbleTypes.SpotifyScrobble, request.allocator, file.content, .{});
                const before_limiting_date: ?zeit.Time = if (before_limiter) (try zeit.Time.fromISO8601(params.get("b").?.string.value)) else null;
                const after_limiting_date: ?zeit.Time = if (after_limiter) (try zeit.Time.fromISO8601(params.get("a").?.string.value)) else null;
                appends: for (content) |scrobble| {
                    // A LastFM Scrobble occurs when half a song has been played
                    // or the song plays for 4 minutes, whichever happens first.
                    // Spotify considers a song played if it plays for 30 seconds.
                    // Ideally, I would go with the LastFM convention, but Spotify
                    // history data only gives us so much information. I'm okay
                    // with the 30 second convention, but eventually I would prefer
                    // to get the song length from MusicBrainz and check if it meets
                    // the requirement. Until then, if it goes 30 seconds, or the
                    // reason_end field reads "trackdone", then it counts as a Scrobble.
                    // May consider giving user control to the minimum millisecond requirement.
                    if (scrobble.reason_end != null and (scrobble.ms_played < 30_000 and !std.mem.eql(u8, scrobble.reason_end.?, "trackdone"))) {
                        skipped_tracks += 1;
                        continue :appends;
                    }
                    // In the case where the artist is null, but there's other metadata, I could
                    // probably let the user edit it in themselves, although I'm not sure if that
                    // situation happens.
                    if (scrobble.master_metadata_album_artist_name == null or scrobble.master_metadata_track_name == null) {
                        skipped_tracks += 1;
                        continue :appends;
                    }

                    // I'm separating these on account of the above comment, as well as
                    // this part being kinda complicated
                    const iso_ts = try zeit.Time.fromISO8601(scrobble.ts);
                    if ((before_limiter or after_limiter) and (iso_ts.after(before_limiting_date.?) or iso_ts.before(after_limiting_date.?))) {
                        limited_tracks += 1;
                        continue :appends;
                    }

                    // Turn SpotifyScrobble into a LastFM scrobble
                    const formatted_scrobble: ScrobbleTypes.LastFMScrobble = .{ .track = scrobble.master_metadata_track_name.?, .album = scrobble.master_metadata_album_album_name.?, .artist = scrobble.master_metadata_album_artist_name.?, .date = (try zeit.instant(.{ .source = .{ .iso8601 = scrobble.ts } })).unixTimestamp() * 1000 };

                    var value = try scrobbles_data.append(.object);

                    // This is so unnecessary, probably useful once I start doing Spotify integration though
                    inline for (std.meta.fields(ScrobbleTypes.LastFMScrobble)) |f| {
                        try value.put(f.name, @as(f.type, @field(formatted_scrobble, f.name)));
                    }
                    // Note sure why this works for ZMPL, but not for jobs.
                    try scrobbles_view.append(formatted_scrobble);
                }
            },
            else => unreachable,
        }
        try job.schedule();
        std.log.debug("Skipped {} tracks", .{skipped_tracks});
        std.log.debug("Filtered {} tracks", .{limited_tracks});
    }

    var upload_table = try root.put("upload_table", .array);
    try upload_table.append("Track");
    try upload_table.append("Artist");
    try upload_table.append("Album");
    try upload_table.append("Date");

    return request.render(.created);
}

pub fn put(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn patch(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
    _ = id;
    return request.render(.ok);
}
