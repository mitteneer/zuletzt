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
    var job = try request.job("process_scrobbles");
    var counter: u16 = 0;

    if (try request.file("upload")) |file| {
        const parsed = try std.json.parseFromSlice(lastfm, request.allocator, file.content, .{});

        const history = parsed.value;

        var scrobbles = try root.put("scrobbles", .array);
        for (history.scrobbles) |scrobble| {
            try scrobbles.append(scrobble);
            //const song_hash: u64 = std.hash.Fnv1a_64.hash(scrobble.track) % 99999989;
            //job.params.put(scrobble.song, song_hash);
            //std.debug.print("{d}\n", .{song_hash});

            const database_update = jetzig.database.Query(.RawScrobble)
                .insert(.{ .id = counter, .track = scrobble.track, .album = scrobble.album, .artist = scrobble.artist, .date = @divFloor(scrobble.date, 1000) });

            try request.repo.execute(database_update);
            counter += 1;
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
