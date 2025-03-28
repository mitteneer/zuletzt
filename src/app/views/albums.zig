const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var albums_view = try root.put("albums", .array);
    const albums = try jetzig.database.Query(.Album)
        .select(.{ .id, .name })
        .include(.albumartists, .{ .select = .{.artist_id} })
        .include(.scrobbles, .{ .select = .{.id} })
        .orderBy(.{ .name = .asc })
        .all(request.repo);
    //const albums = try request.repo.all(query);

    for (albums) |album| {
        var album_view = try albums_view.append(.object);

        var artist_infos = try album_view.put("artist_info", .array);
        for (album.albumartists) |artist| {
            var artist_info = try artist_infos.append(.object);
            const artist_data = try jetzig.database.Query(.Artist)
                .find(artist.artist_id)
                .select(.{ .id, .name })
                .execute(request.repo);
            try artist_info.put("name", artist_data.?.name);
            try artist_info.put("id", artist_data.?.id);
        }

        try album_view.put("name", album.name);
        try album_view.put("url", album.id);
        try album_view.put("scrobbles", (album.scrobbles).len);
    }
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    const album = try jetzig.database.Query(.Album)
        .find(id)
        .select(.{ .id, .name })
        .execute(request.repo);
    var root = try request.data(.object);
    try root.put("album", album.?.name);
    var songs_view = try root.put("songs", .array);
    const query = jetzig.database.Query(.Albumsong)
        .select(.{.id})
        .include(.song, .{ .select = .{ .name, .id } })
        .join(.inner, .album)
        .where(.{ .album = .{ .id = id } });

    const songs = try request.repo.all(query);
    for (songs) |song| {
        const scrobbles = try jetzig.database.Query(.Scrobble)
            .where(.{ .song_id = song.song.id })
            .count()
            .execute(request.repo);
        var song_view = try songs_view.append(.object);
        try song_view.put("name", song.song.name);
        try song_view.put("url", song.song.id);
        try song_view.put("scrobbles", scrobbles);
    }
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
