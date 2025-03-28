const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var artists_view = try root.put("artists", .array);
    const query = jetzig.database.Query(.Artist)
        .select(.{ .id, .name })
        .orderBy(.{ .name = .asc });
    const artists = try request.repo.all(query);
    for (artists) |artist| {
        const scrobbles = try jetzig.database.Query(.Scrobbleartist).where(.{ .artist_id = artist.id }).count().execute(request.repo);
        var artist_view = try artists_view.append(.object);
        //const output = try request.allocator.dupe(u8, artist.name);
        //std.mem.replaceScalar(u8, output, ' ', '_');
        try artist_view.put("name", artist.name);
        try artist_view.put("url", artist.id);
        try artist_view.put("scrobbles", scrobbles);
    }

    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    const artist = try jetzig.database.Query(.Artist).find(id).execute(request.repo);
    var root = try request.data(.object);
    try root.put("artist", artist.?.name);
    var albums_view = try root.put("albums", .array);
    const query = jetzig.database.Query(.Albumartist)
        .select(.{.id})
        .include(.album, .{ .select = .{ .name, .id } })
        .join(.inner, .artist)
        .where(.{ .artist = .{ .id = id } });

    //const query = jetzig.database.Query(.Albumartist)
    //    .select(.{ .artist_id, jetquery.sql.count(.album_id) })
    //    .groupBy(.{.artist_id})
    //    .orderBy(.count__album_id);

    const albums = try request.repo.all(query);
    for (albums) |album| {
        const scrobbles = try jetzig.database.Query(.Scrobble).where(.{ .album_id = album.album.id }).count().execute(request.repo);
        var album_view = try albums_view.append(.object);
        try album_view.put("name", album.album.name);
        try album_view.put("url", album.album.id);
        //try album_view.put("name", album.count__album_id);
        //try album_view.put("url", album.count__album_id);
        try album_view.put("scrobbles", scrobbles);
        //std.log.debug("{s}", .{album.album.name});
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
