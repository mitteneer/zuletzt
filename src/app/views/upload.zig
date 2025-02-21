const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const Scrobble = @import("../../types.zig").LastFMScrobble;
const lastfm = @import("../../types.zig").LastFM;
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
        //std.debug.print("{s}", .{file.content});
        const content = try std.json.parseFromSliceLeaky(lastfm, request.allocator, file.content, .{ .ignore_unknown_fields = true });

        var scrobbles_view = try root.put("scrobbles", .array);

        var job = try request.job("process_scrobbles");
        var scrobbles_data = try job.params.put("scrobbles", .array);

        const params = try request.params();
        const limiting_date_string: ?[]const u8 = if (params.get("l")) |param| param.string.value else null;
        const limiting_date_instant: ?zeit.Instant = if (limiting_date_string) |str| try zeit.instant(.{ .source = .{ .iso8601 = str } }) else null;
        // This is seconds from Unix epoch
        const limiting_date_epoch = if (limiting_date_instant) |time| time.unixTimestamp() else 9_223_372_036_854_775_807;

        appends: for (content.scrobbles) |scrobble| {
            // Scrobble.date is in milliseconds from Unix epoch
            if (scrobble.date < limiting_date_epoch * 1000) continue :appends;
            var value = try scrobbles_data.append(.object);
            // This is so unnecessary, probably useful once I start doing Spotify integration though
            inline for (std.meta.fields(Scrobble)) |f| {
                try value.put(f.name, @as(f.type, @field(scrobble, f.name)));
            }
            // Note sure why this works for ZMPL, but not for jobs.
            try scrobbles_view.append(scrobble);
        }
        try job.schedule();
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
