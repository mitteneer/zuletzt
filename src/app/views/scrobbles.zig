const std = @import("std");
const jetzig = @import("jetzig");
const zeit = @import("zeit");

pub fn index(request: *jetzig.Request) !jetzig.View {
    var root = try request.data(.object);
    var scrobbles_view = try root.put("scrobbles", .array);

    const query =
        \\SELECT songs.name, songs.id, albums.name, albums.id, artists.name, artists.id, scrobbles.id, scrobbles.datetime
        \\FROM albumsongs
        \\INNER JOIN songs ON songs.id = albumsongs.song_id
        \\INNER JOIN albums ON albums.id = albumsongs.album_id
        \\INNER JOIN scrobbles ON scrobbles.albumsong = albumsongs.id
        \\INNER JOIN albumsongsartists ON albumsongsartists.albumsong_id = albumsongs.id
        \\INNER JOIN artists ON artists.id = albumsongsartists.artist_id
        \\ORDER BY scrobbles.datetime ASC
    ;

    var scrobbles_jq_result = try request.repo.executeSql(query, .{});
    defer scrobbles_jq_result.deinit();

    const Scrobble = struct { song_name: []const u8, song_id: i32, album_name: []const u8, album_id: i32, artist_name: []const u8, artist_id: i32, s_id: i32, date: i64 };

    var prev_s_id: ?i32 = null;
    var prev_artist_infos: ?*jetzig.zmpl.Data.Value = null;

    blk: while (try scrobbles_jq_result.postgresql.result.next()) |scrobble_row| {
        const scrobble = try scrobble_row.to(Scrobble, .{ .dupe = true, .allocator = request.allocator });
        if (scrobble.s_id == prev_s_id) {
            var artist_info = try prev_artist_infos.?.append(.object);
            try artist_info.put("name", scrobble.artist_name);
            try artist_info.put("url", scrobble.artist_id);
            continue :blk;
        }
        // Not appending the scrobble directly because we don't want the unix timestamp or scrobble id
        var scrobble_view = try scrobbles_view.append(.object);

        var artist_infos = try scrobble_view.put("artist_info", .array);
        var artist_info = try artist_infos.append(.object);
        try artist_info.put("name", scrobble.artist_name);
        try artist_info.put("url", scrobble.artist_id);

        try scrobble_view.put("song_name", scrobble.song_name);
        try scrobble_view.put("song_id", scrobble.song_id);
        try scrobble_view.put("album_name", scrobble.album_name);
        try scrobble_view.put("album_id", scrobble.album_id);
        var date = std.ArrayList(u8).init(request.allocator);
        try (try zeit.instant(.{ .source = .{ .unix_timestamp = @divFloor(scrobble.date, 1_000) } })).time().strftime(date.writer(), "%d %b %Y, %H:%M");
        try scrobble_view.put("date", date.items);

        prev_artist_infos = artist_infos;
        prev_s_id = scrobble.s_id;
    }

    return request.render(.ok);
}
