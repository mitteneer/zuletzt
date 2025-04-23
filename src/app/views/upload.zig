const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const zeit = @import("zeit");
const rules = @import("../../apply_rule.zig");
const Data = @import("../../types.zig");

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
        const before_limiter: bool = if (params.get("bbool")) |_| true else false;
        const after_limiter: bool = if (params.get("abool")) |_| true else false;

        var scrobbles_view = try root.put("scrobbles", .array);
        var job = try request.job("process_scrobbles");
        var scrobbles_data = try job.params.put("scrobbles", .array);

        var skipped_tracks: u64 = 0;
        var limited_tracks: u64 = 0;

        const rule_file = try (std.fs.cwd().openFile("rules.json", .{ .mode = .read_only }) catch |err| switch (err) {
            error.FileNotFound => std.fs.cwd().createFile("rules.json", .{ .read = true }),
            else => err,
        });

        defer rule_file.close();
        const file_content = try rule_file.readToEndAlloc(request.allocator, 16_000_000);
        const rule_list = std.json.parseFromSliceLeaky(Data.Rules, request.allocator, file_content, .{}) catch null;

        switch (source) {
            0 => {
                const content: Data.LastFM = try std.json.parseFromSliceLeaky(Data.LastFM, request.allocator, file.content, .{});
                const before_limiting_date = if (before_limiter and params.get("b") != null) (try zeit.instant(.{ .source = .{ .iso8601 = params.get("b").?.string.value } })).unixTimestamp() * 1000 else 0;
                const after_limiting_date = if (after_limiter and params.get("a") != null) (try zeit.instant(.{ .source = .{ .iso8601 = params.get("a").?.string.value } })).unixTimestamp() * 1000 else 9_223_372_036_854_775_807;
                appends: for (content.scrobbles) |scrobble| {
                    // We can short-circuit on the limiter bools
                    if ((before_limiter or after_limiter) and (scrobble.date > before_limiting_date or scrobble.date < after_limiting_date)) continue :appends;

                    const formatted_scrobble = if (rule_list) |rl|
                        rules.applyScrobbleRule(request.allocator, scrobble, rl)
                    else
                        Data.Scrobble{
                            .album = scrobble.album,
                            .artists_album = &[_][]const u8{scrobble.artist},
                            .track = scrobble.track,
                            .artists_track = &[_][]const u8{scrobble.artist},
                            .date = scrobble.date,
                        };

                    var scrobble_view = try scrobbles_view.append(.object);
                    var artists = try scrobble_view.put("artists", .array);

                    try scrobble_view.put("track", formatted_scrobble.track);
                    try scrobble_view.put("album", formatted_scrobble.album);
                    for (formatted_scrobble.artists_track) |artist| {
                        try artists.append(artist);
                    }
                    try scrobble_view.put("date", formatted_scrobble.date);

                    var scrobble_data = try scrobbles_data.append(.object);
                    var artists_album = try scrobble_data.put("artists_album", .array);
                    var artists_track = try scrobble_data.put("artists_track", .array);

                    try scrobble_data.put("track", formatted_scrobble.track);
                    try scrobble_data.put("album", formatted_scrobble.album);
                    for (formatted_scrobble.artists_album) |artist| {
                        try artists_album.append(artist);
                    }

                    for (formatted_scrobble.artists_track) |artist| {
                        try artists_track.append(artist);
                    }
                    try scrobble_data.put("date", formatted_scrobble.date);
                }
            },
            1 => {
                const content: []Data.SpotifyScrobble = try std.json.parseFromSliceLeaky([]Data.SpotifyScrobble, request.allocator, file.content, .{ .ignore_unknown_fields = true });
                const before_limiting_date: zeit.Time = if (before_limiter) (try zeit.Time.fromISO8601(params.get("b").?.string.value)) else (try zeit.instant(.{})).time();
                const after_limiting_date: zeit.Time = if (after_limiter) (try zeit.Time.fromISO8601(params.get("a").?.string.value)) else (try zeit.instant(.{ .source = .{ .unix_nano = 0 } })).time();
                appends: for (content) |scrobble| {
                    if (scrobble.ms_played < 30_000 and (scrobble.reason_end == null or !std.mem.eql(u8, scrobble.reason_end.?, "trackdone"))) {
                        skipped_tracks += 1;
                        continue :appends;
                    }
                    if (scrobble.master_metadata_album_artist_name == null or scrobble.master_metadata_track_name == null) {
                        skipped_tracks += 1;
                        continue :appends;
                    }

                    const iso_ts = try zeit.Time.fromISO8601(scrobble.ts);
                    if ((before_limiter or after_limiter) and (iso_ts.after(before_limiting_date) or iso_ts.before(after_limiting_date))) {
                        limited_tracks += 1;
                        continue :appends;
                    }

                    const pre_formatted_scrobble: Data.ImportedScrobble = .{ .track = scrobble.master_metadata_track_name.?, .album = scrobble.master_metadata_album_album_name.?, .artist = scrobble.master_metadata_album_artist_name.?, .date = (try zeit.instant(.{ .source = .{ .iso8601 = scrobble.ts } })).unixTimestamp() * 1000 };
                    const formatted_scrobble = if (rule_list) |rl|
                        rules.applyScrobbleRule(request.allocator, pre_formatted_scrobble, rl)
                    else
                        Data.Scrobble{
                            .album = pre_formatted_scrobble.album,
                            .artists_album = &[_][]const u8{pre_formatted_scrobble.artist},
                            .track = pre_formatted_scrobble.track,
                            .artists_track = &[_][]const u8{pre_formatted_scrobble.artist},
                            .date = pre_formatted_scrobble.date,
                        };

                    var scrobble_view = try scrobbles_view.append(.object);
                    var artists = try scrobble_view.put("artists", .array);

                    try scrobble_view.put("track", formatted_scrobble.track);
                    try scrobble_view.put("album", formatted_scrobble.album);
                    for (formatted_scrobble.artists_track) |artist| {
                        try artists.append(artist);
                    }
                    try scrobble_view.put("date", formatted_scrobble.date);

                    var scrobble_data = try scrobbles_data.append(.object);
                    var artists_album = try scrobble_data.put("artists_album", .array);
                    var artists_track = try scrobble_data.put("artists_track", .array);

                    try scrobble_data.put("track", formatted_scrobble.track);
                    try scrobble_data.put("album", formatted_scrobble.album);
                    for (formatted_scrobble.artists_album) |artist| {
                        try artists_album.append(artist);
                    }

                    for (formatted_scrobble.artists_track) |artist| {
                        try artists_track.append(artist);
                    }
                    try scrobble_data.put("date", formatted_scrobble.date);
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
