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
        album: []u8,
        date: i64,
    };

    const lastfm = struct {
        username: []u8,
        scrobbles: []Scrobble,
    };

    var root = try request.data(.object);

    if (try request.file("upload")) |file| {
        const parsed = try std.json.parseFromSlice(lastfm, request.allocator, file.content, .{});

        const history = parsed.value;

        //std.debug.print("{s}", .{history.scrobbles[19].artist});

        var scrobbles = try root.put("scrobbles", .array);
        for (history.scrobbles) |scrobble| {
            try scrobbles.append(scrobble);

            const database_update = jetzig.database.Query(.RawScrobble)
                .insert(.{ .track = scrobble.track, .album = scrobble.album, .artist = scrobble.artist, .date = @divFloor(scrobble.date, 1000) });

            try request.repo.execute(database_update);
        }
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
