const std = @import("std");
const jetzig = @import("jetzig");

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var songs_view = try root.put("songs", .array);
    //const songs = try jetzig.database.Query(.Song)
    //    .select(.{ .id, .name })
    //    .include(.songartists, .{ .select = .{.artist_id} })
    //    .include(.scrobbles, .{ .select = .{.id} })
    //    .orderBy(.{ .name = .asc })
    //    .all(request.repo);

    const query =
        \\SELECT songs.name, songs.id, artists.name, artists.id, COUNT(scrobbles) AS scrobbles
        \\FROM albumsongs
        \\INNER JOIN songs ON albumsongs.song_id = songs.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\INNER JOIN albumsongsartists ON albumsongsartists.albumsong_id = albumsongs.id
        \\INNER JOIN artists ON artists.id = albumsongsartists.artist_id
        \\GROUP BY songs.id, artists.id
        \\ORDER BY scrobbles DESC, songs.name ASC
    ;

    var songs_js_result = try request.repo.executeSql(query, .{});
    defer songs_js_result.deinit();

    const Song = struct { name: []const u8, id: i32, artist_name: []const u8, artist_id: i32, scrobbles: i64 };

    var prev_song_id: ?i32 = null;
    var prev_artist_infos: ?*jetzig.zmpl.Data.Value = null;

    blk: while (try songs_js_result.postgresql.result.next()) |song_row| {
        const song = try song_row.to(Song, .{ .dupe = true, .allocator = request.allocator });
        if (song.id == prev_song_id) {
            var artist_info = try prev_artist_infos.?.append(.object);
            try artist_info.put("name", song.artist_name);
            try artist_info.put("url", song.artist_id);
            continue :blk;
        }
        var song_view = try songs_view.append(.object);

        var artist_infos = try song_view.put("artist_info", .array);
        var artist_info = try artist_infos.append(.object);
        try artist_info.put("name", song.artist_name);
        try artist_info.put("url", song.artist_id);

        try song_view.put("name", song.name);
        try song_view.put("url", song.id);
        try song_view.put("scrobbles", song.scrobbles);

        prev_artist_infos = artist_infos;
        prev_song_id = song.id;
    }

    //for (songs) |song| {
    //    var song_view = try songs_view.append(.object);

    //    var artist_infos = try song_view.put("artist_info", .array);
    //    for (song.songartists) |artist| {
    //        var artist_info = try artist_infos.append(.object);
    //        const artist_data = try jetzig.database.Query(.Artist)
    //            .find(artist.artist_id)
    //            .select(.{ .id, .name })
    //            .execute(request.repo);
    //        try artist_info.put("name", artist_data.?.name);
    //        try artist_info.put("id", artist_data.?.id);
    //    }
    //    try song_view.put("name", song.name);
    //    try song_view.put("url", song.id);
    //    try song_view.put("scrobbles", (song.scrobbles).len);
    //}
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn new(request: *jetzig.Request) !jetzig.View {
    return request.render(.ok);
}

pub fn edit(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    return request.render(.created);
}

pub fn put(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn patch(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/song", .{});
    try response.expectStatus(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/song/example-id", .{});
    try response.expectStatus(.ok);
}

test "new" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/song/new", .{});
    try response.expectStatus(.ok);
}

test "edit" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/song/example-id/edit", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/song", .{});
    try response.expectStatus(.created);
}

test "put" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PUT, "/song/example-id", .{});
    try response.expectStatus(.ok);
}

test "patch" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PATCH, "/song/example-id", .{});
    try response.expectStatus(.ok);
}

test "delete" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.DELETE, "/song/example-id", .{});
    try response.expectStatus(.ok);
}
