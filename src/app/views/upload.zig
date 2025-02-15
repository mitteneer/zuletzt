const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

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
    const Scrobble = struct {
        track: []u8,
        artist: []u8,
        album: ?[]u8,
        date: u64,
    };

    const lastfm = struct {
        username: []u8,
        scrobbles: []Scrobble,
    };

    var root = try request.data(.object);
    var job = try request.job("process_scrobbles");
    var uploaded_scrobbles = try job.params.put("data", .array);

    if (try request.file("upload")) |file| {
        const content = try std.json.parseFromSlice(lastfm, request.allocator, file.content, .{});
        defer content.deinit();
        const history = content.value;

        var scrobbles = try root.put("scrobbles", .array);
        for (history.scrobbles) |scrobble| {
            try scrobbles.append(scrobble);
            try uploaded_scrobbles.append(scrobble);
        }
    }

    try job.schedule();

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
