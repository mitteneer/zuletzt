const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const dateFmt = @import("../../date_fmt.zig").dateFmt;
const ordinalFmt = @import("../../ordinal_fmt.zig").ordinalFmt;

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

    const ArtistResult = struct { name: []const u8, id: i32, scrobbles: i64, rank: i64 };
    const AlbumsResult = struct { name: []const u8, id: i32, scrobbles: i64 };
    const ScrobbleResult = struct { name: []const u8, id: i32, date: i64 };

    const artist_info_query =
        \\SELECT * FROM
        \\(SELECT *, ROW_NUMBER() OVER (ORDER BY scrobbles DESC) AS rank FROM
        \\(SELECT artists.name AS name, artists.id AS id, COUNT(scrobbles) AS scrobbles
        \\FROM albumsongsartists
        \\INNER JOIN artists ON albumsongsartists.artist_id = artists.id
        \\INNER JOIN albumsongs ON albumsongsartists.albumsong_id = albumsongs.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\GROUP BY artists.id))
        \\WHERE id = $1
    ;

    var artist_jq_result = try request.repo.executeSql(artist_info_query, .{id});
    defer artist_jq_result.deinit();

    if (try artist_jq_result.postgresql.result.next()) |artist_row| {
        const artist = try artist_row.to(ArtistResult, .{ .dupe = true, .allocator = request.allocator });
        var artist_view = try root.put("artist", .object);
        try artist_view.put("name", artist.name);
        try artist_view.put("id", artist.id);
        try artist_view.put("scrobbles", artist.scrobbles);
        try artist_view.put("rank", ordinalFmt(request.allocator, artist.rank));
    }
    try artist_jq_result.drain();

    const albums_query =
        \\SELECT albums.name AS name, albums.id AS id, COUNT(scrobbles) AS scrobbles
        \\FROM artistalbums
        \\INNER JOIN albums ON albums.id = artistalbums.album_id
        \\INNER JOIN albumsongs ON albumsongs.album_id = albums.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\WHERE artistalbums.artist_id = $1
        \\GROUP BY albums.id
        \\ORDER BY scrobbles DESC
    ;

    var albums_view = try root.put("albums", .array);

    var albums_jq_result = try request.repo.executeSql(albums_query, .{id});
    defer albums_jq_result.deinit();

    while (try albums_jq_result.postgresql.result.next()) |album_row| {
        const album = try album_row.to(AlbumsResult, .{ .dupe = true, .allocator = request.allocator });
        try albums_view.append(album);
    }
    //albums_jq_result.drain();

    const appears_query =
        \\SELECT albums.name AS name, albums.id AS id, COUNT(scrobbles) AS scrobbles
        \\FROM artistalbums
        \\INNER JOIN albums ON albums.id = artistalbums.album_id
        \\INNER JOIN albumsongs ON albumsongs.album_id = albums.id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\INNER JOIN albumsongsartists ON albumsongsartists.albumsong_id = albumsongs.id
        \\WHERE albumsongsartists.artist_id = $1 AND artistalbums.artist_id != $1
        \\GROUP BY albums.id
        \\ORDER BY scrobbles DESC;
    ;

    var appears_view = try root.put("appears", .array);

    var appears_jq_result = try request.repo.executeSql(appears_query, .{id});
    defer appears_jq_result.deinit();

    while (try appears_jq_result.postgresql.result.next()) |appears_row| {
        const appears = try appears_row.to(AlbumsResult, .{ .dupe = true, .allocator = request.allocator });
        try appears_view.append(appears);
    }

    //appears_jq_result.drain();

    const first_last_songs_query =
        \\(SELECT songs.name AS name, songs.id AS id, scrobbles.datetime AS date
        \\FROM albumsongs
        \\INNER JOIN songs ON songs.id = albumsongs.song_id
        \\INNER JOIN scrobbles ON albumsongs.id = scrobbles.albumsong
        \\INNER JOIN albumsongsartists ON albumsongsartists.albumsong_id = albumsongs.id
        \\WHERE albumsongsartists.artist_id = $1
        \\ORDER BY scrobbles.datetime DESC
        \\LIMIT 1)
        \\
        \\UNION ALL
        \\
        \\(SELECT songs.name AS name, songs.id AS id, scrobbles.datetime AS date
        \\FROM albumsongs
        \\INNER JOIN songs ON songs.id = albumsongs.song_id
        \\INNER JOIN scrobbles ON albumsongs.id = scrobbles.albumsong
        \\INNER JOIN albumsongsartists ON albumsongsartists.albumsong_id = albumsongs.id
        \\WHERE albumsongsartists.artist_id = $1
        \\ORDER BY scrobbles.datetime ASC    
        \\LIMIT 1)
    ;

    var first_last_songs_jq_result = try request.repo.executeSql(first_last_songs_query, .{id});
    defer first_last_songs_jq_result.deinit();

    // These look backwards, but it's correct this way
    if (try first_last_songs_jq_result.postgresql.result.next()) |last_song_row| {
        const last_song = try last_song_row.to(ScrobbleResult, .{ .dupe = true, .allocator = request.allocator });
        try root.put("last_song_name", last_song.name);
        try root.put("last_song_id", last_song.id);
        try root.put("last_song_date", (try dateFmt(request.allocator, last_song.date)));
    }

    if (try first_last_songs_jq_result.postgresql.result.next()) |first_song_row| {
        const first_song = try first_song_row.to(ScrobbleResult, .{ .dupe = true, .allocator = request.allocator });
        try root.put("first_song_name", first_song.name);
        try root.put("first_song_id", first_song.id);
        try root.put("first_song_date", (try dateFmt(request.allocator, first_song.date)));
    }

    try first_last_songs_jq_result.drain();

    return request.render(.ok);
}
