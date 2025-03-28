const std = @import("std");
const jetzig = @import("jetzig");

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var scrobbles_view = try root.put("scrobbles", .array);
    const query = jetzig.database.Query(.Scrobble)
        .select(.{ .id, .date })
        .include(.song, .{ .select = .{ .id, .name } })
        .include(.album, .{ .select = .{ .id, .name } })
        .include(.scrobbleartists, .{ .select = .{.artist_id} })
        .orderBy(.{ .date = .desc });
    const scrobbles = try request.repo.all(query);
    for (scrobbles) |scrobble| {
        var scrobble_view = try scrobbles_view.append(.object);

        var artist_infos = try scrobble_view.put("artist_info", .array);
        for (scrobble.scrobbleartists) |artist| {
            var artist_info = try artist_infos.append(.object);
            const artist_data = try jetzig.database.Query(.Artist)
                .find(artist.artist_id)
                .select(.{ .id, .name })
                .execute(request.repo);
            try artist_info.put("name", artist_data.?.name);
            try artist_info.put("id", artist_data.?.id);
        }

        try scrobble_view.put("song_name", scrobble.song.name);
        try scrobble_view.put("song_id", scrobble.song.id);
        try scrobble_view.put("album_name", scrobble.album.name);
        try scrobble_view.put("album_id", scrobble.album.id);
        try scrobble_view.put("date", scrobble.date);
    }
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = id;
    _ = data;
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
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
