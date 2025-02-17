const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const Scrobble = @import("../../types.zig").LastFMScrobble;
const lastfm = @import("../../types.zig").LastFM;

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
        const content = try std.json.parseFromSlice(lastfm, request.allocator, file.content, .{});
        defer content.deinit();
        const history = content.value;

        var scrobbles_view = try root.put("scrobbles", .array);

        var job = try request.job("process_scrobbles");
        var scrobbles_data = try job.params.put("scrobbles", .array);

        for (history.scrobbles) |scrobble| {
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
