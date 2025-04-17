const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var artists_view = try root.put("artists", .array);

    const query =
        \\SELECT artists.name, artists.id, COUNT(scrobbles) AS scrobbles
        \\FROM albumsongsartists
        \\INNER JOIN artists ON albumsongsartists.artist_id = artists.id
        \\INNER JOIN albumsongs ON albumsongsartists.albumsong_id = albumsongs.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\GROUP BY artists.id
        \\ORDER BY scrobbles DESC;
    ;

    var artists_jq_result = try request.repo.executeSql(query, .{});
    defer artists_jq_result.deinit();

    const Artist = struct { name: []const u8, id: i32, scrobbles: i64 };

    while (try artists_jq_result.postgresql.result.next()) |artist_row| {
        const artist = try artist_row.to(Artist, .{ .dupe = true, .allocator = request.allocator });
        var artist_view = try artists_view.append(.object);
        try artist_view.put("name", artist.name);
        try artist_view.put("url", artist.id);
        try artist_view.put("scrobbles", artist.scrobbles);
    }

    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var albums_view = try root.put("albums", .array);
    const artist_name = try jetzig.database.Query(.Artist).find(id).select(.{ .id, .name }).execute(request.repo);
    _ = try root.put("artist", artist_name.?.name);
    const query =
        \\SELECT albums.name, albums.id, COUNT(scrobbles) AS scrobbles
        \\FROM artistalbums
        \\INNER JOIN albums ON albums.id = artistalbums.album_id
        \\INNER JOIN albumsongs ON albumsongs.album_id = albums.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\WHERE artistalbums.artist_id = $1
        \\GROUP BY albums.id
        \\ORDER BY scrobbles DESC
    ;

    var albums_jq_result = try request.repo.executeSql(query, .{id});
    defer albums_jq_result.deinit();

    const Album = struct { name: []const u8, id: i32, scrobbles: i64 };

    while (try albums_jq_result.postgresql.result.next()) |album_row| {
        const album = try album_row.to(Album, .{ .dupe = true, .allocator = request.allocator });
        var album_view = try albums_view.append(.object);
        try album_view.put("name", album.name);
        try album_view.put("url", album.id);
        try album_view.put("scrobbles", album.scrobbles);
    }
    //const artist = try jetzig.database.Query(.Artist)
    //    .find(id)
    //    .select(.{ .id, .name })
    //    .execute(request.repo);
    //var root = try request.data(.object);
    //try root.put("artist", artist.?.name);
    //var albums_view = try root.put("albums", .array);
    //const query = jetzig.database.Query(.Albumartist)
    //    .select(.{.id})
    //    .include(.album, .{ .select = .{ .name, .id } })
    //    .join(.inner, .artist)
    //    .where(.{ .artist = .{ .id = id } });

    //const albums = try request.repo.all(query);
    //for (albums) |album| {
    //    const scrobbles = try jetzig.database.Query(.Scrobble)
    //        .where(.{ .album_id = album.album.id })
    //        .count()
    //        .execute(request.repo);
    //    var album_view = try albums_view.append(.object);
    //    try album_view.put("name", album.album.name);
    //    try album_view.put("url", album.album.id);
    //    try album_view.put("scrobbles", scrobbles);
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

    const response = try app.request(.GET, "/artist", .{});
    try response.expectStatus(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/artist/example-id", .{});
    try response.expectStatus(.ok);
}

test "new" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/artist/new", .{});
    try response.expectStatus(.ok);
}

test "edit" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/artist/example-id/edit", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/artist", .{});
    try response.expectStatus(.created);
}

test "put" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PUT, "/artist/example-id", .{});
    try response.expectStatus(.ok);
}

test "patch" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PATCH, "/artist/example-id", .{});
    try response.expectStatus(.ok);
}

test "delete" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.DELETE, "/artist/example-id", .{});
    try response.expectStatus(.ok);
}
