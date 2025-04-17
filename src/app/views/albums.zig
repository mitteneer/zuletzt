const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var albums_view = try root.put("albums", .array);
    //const albums = try jetzig.database.Query(.Album)
    //    .select(.{ .id, .name })
    //    .include(.albumartists, .{ .select = .{.artist_id} })
    //    .include(.scrobbles, .{ .select = .{.id} })
    //    .orderBy(.{ .name = .asc })
    //    .all(request.repo);
    ////const albums = try request.repo.all(query);

    const query =
        \\SELECT albums.name, albums.id, artists.name, artists.id, COUNT(scrobbles) AS scrobbles
        \\FROM albumsongs
        \\INNER JOIN albums ON albumsongs.album_id = albums.id
        \\INNER JOIN scrobbles ON albumsongs.id = scrobbles.albumsong
        \\INNER JOIN artistalbums ON artistalbums.album_id = albums.id
        \\INNER JOIN artists ON artists.id = artistalbums.artist_id
        \\GROUP BY albums.id, artists.id
        \\ORDER BY scrobbles DESC
    ;

    //var inter_conn = try request.repo.connect();
    //defer inter_conn.release();

    var albums_jq_result = try request.repo.executeSql(query, .{});
    defer albums_jq_result.deinit();

    const Album = struct { name: []const u8, id: i32, artist_name: []const u8, artist_id: i32, scrobbles: i64 };

    var prev_album_id: ?i32 = null;
    var prev_artist_infos: ?*jetzig.zmpl.Data.Value = null;

    blk: while (try albums_jq_result.postgresql.result.next()) |album_row| {
        const album = try album_row.to(Album, .{ .dupe = true, .allocator = request.allocator });
        if (album.id == prev_album_id) {
            var artist_info = try prev_artist_infos.?.append(.object);
            try artist_info.put("name", album.artist_name);
            try artist_info.put("url", album.artist_id);
            continue :blk;
        }
        var album_view = try albums_view.append(.object);
        var artist_infos = try album_view.put("artist_info", .array);
        //const artist_data = try jetzig.database.Query(.Artistalbum)
        //    .select(.{.id})
        //    .where(.{ .album_id = album.id })
        //    .include(.artist, .{ .select = .{ .name, .id } })
        //    .all(request.repo);

        var artist_info = try artist_infos.append(.object);
        try artist_info.put("name", album.artist_name);
        try artist_info.put("url", album.artist_id);

        try album_view.put("name", album.name);
        try album_view.put("url", album.id);
        try album_view.put("scrobbles", album.scrobbles);
        prev_artist_infos = artist_infos;
        prev_album_id = album.id;
    }
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var songs_view = try root.put("songs", .array);
    const album_name = try jetzig.database.Query(.Album).find(id).select(.{ .id, .name }).execute(request.repo);
    _ = try root.put("album", album_name.?.name);

    const query =
        \\SELECT songs.name, songs.id, COUNT(scrobbles) AS scrobbles
        \\FROM albumsongs
        \\INNER JOIN songs ON albumsongs.song_id = songs.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\WHERE albumsongs.album_id = $1
        \\GROUP BY songs.id
        \\ORDER BY scrobbles DESC
    ;

    var songs_js_result = try request.repo.executeSql(query, .{id});
    defer songs_js_result.deinit();

    const Song = struct { name: []const u8, id: i32, scrobbles: i64 };

    while (try songs_js_result.postgresql.result.next()) |song_row| {
        const song = try song_row.to(Song, .{ .dupe = true, .allocator = request.allocator });
        var song_view = try songs_view.append(.object);
        try song_view.put("name", song.name);
        try song_view.put("url", song.id);
        try song_view.put("scrobbles", song.scrobbles);
    }

    //const album = try jetzig.database.Query(.Album)
    //    .find(id)
    //    .select(.{ .id, .name })
    //    .execute(request.repo);
    //var root = try request.data(.object);
    //try root.put("album", album.?.name);
    //var songs_view = try root.put("songs", .array);
    //const query = jetzig.database.Query(.Albumsong)
    //    .select(.{.id})
    //    .include(.song, .{ .select = .{ .name, .id } })
    //    .join(.inner, .album)
    //    .where(.{ .album = .{ .id = id } });

    //const songs = try request.repo.all(query);
    //for (songs) |song| {
    //    const scrobbles = try jetzig.database.Query(.Scrobble)
    //        .where(.{ .song_id = song.song.id })
    //        .count()
    //        .execute(request.repo);
    //    var song_view = try songs_view.append(.object);
    //    try song_view.put("name", song.song.name);
    //    try song_view.put("url", song.song.id);
    //    try song_view.put("scrobbles", scrobbles);
    //}
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

    const response = try app.request(.GET, "/album", .{});
    try response.expectStatus(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/album/example-id", .{});
    try response.expectStatus(.ok);
}

test "new" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/album/new", .{});
    try response.expectStatus(.ok);
}

test "edit" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/album/example-id/edit", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/album", .{});
    try response.expectStatus(.created);
}

test "put" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PUT, "/album/example-id", .{});
    try response.expectStatus(.ok);
}

test "patch" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PATCH, "/album/example-id", .{});
    try response.expectStatus(.ok);
}

test "delete" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.DELETE, "/album/example-id", .{});
    try response.expectStatus(.ok);
}
