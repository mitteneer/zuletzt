const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const Scrobble = @import("../../types.zig").LastFMScrobble;
const lastfm = @import("../../types.zig").LastFM;

// The `run` function for a job is invoked every time the job is processed by a queue worker
// (or by the Jetzig server if the job is processed in-line).
//
// Arguments:
// * allocator: Arena allocator for use during the job execution process.
// * params:    Params assigned to a job (from a request, values added to response data).
// * env:       Provides the following fields:
//              - logger:      Logger attached to the same stream as the Jetzig server.
//              - environment: Enum of `{ production, development }`.
pub fn run(allocator: std.mem.Allocator, params: *jetzig.data.Value, env: jetzig.jobs.JobEnv) !void {
    //_ = env;
    const file = try std.fs.cwd().openFile("rules.json", .{ .mode = .read_only });
    const file_content = try file.readToEndAlloc(allocator, 16_000_000);

    const rules = try std.json.parseFromSliceLeaky(Rules, allocator, file_content, .{});

    if (params.getT(.array, "scrobbles")) |scrobbles| {
        for (scrobbles.items()) |item| {
            //const fixed_date: u32 = @as(u32, item.getT(.integer, "date").?);
            const scrobble: Scrobble = .{ .track = item.getT(.string, "track").?, .artist = item.getT(.string, "artist").?, .album = item.getT(.string, "album") orelse "", .date = @as(u64, @bitCast(@as(i64, @truncate(item.getT(.integer, "date").? * 1000)))) };

            for (rules) |rule| {}

            // Make hashes
            //const album_hash = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.album)));
            //const artist_hash = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.artist)));
            //const song_hash = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.track)));

            // Create a buffer to hold the metadata to hash. Numbers based on the title of a
            // particularly long Sufjan Stevens song title, and we're gonna pray the metadata
            // does not exceed three times it's length.
            var buffer = [_]u8{undefined} ** (288 * 3);
            const artist_id = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.artist)));
            const album_prehash = try std.fmt.bufPrint(&buffer, "{s}{s}", .{ scrobble.artist, scrobble.album });
            const album_id = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(album_prehash)));
            const song_prehash = try std.fmt.bufPrint(&buffer, "{s}{s}{s}", .{ scrobble.artist, scrobble.album, scrobble.track });
            const song_id = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(song_prehash)));

            // Make IDs
            // Song:    Song hash XOR artist hash XOR album hash
            //          This way, if two songs share a name, then
            //          the IDs also depend on the hash of the album
            //          they're on, as well as the artist name. As far
            //          as I can tell, this is only as issue for Sufjan
            //          Steven's `Songs for Christmas`. (In practice.
            //          In reality, there are albums with several untitled
            //          songs (Selected Ambient Works Vol. II by Aphex Twin,
            //           ( ) by Sigur Ros, ...) that have working titles
            //          in their place.)

            // Album:   If the album is not self-titled, then
            //          album hash XOR artist hash. This way, if two
            //          artists have an album of the same name, then
            //          the IDs also depend on the hash of the artist
            //          name. As far as I can tell, this is only an
            //          issue for Weezer and Peter Gabriel, but their
            //          albums go by unique names anyways.

            // Artist:  Artist hash. If two artists have the same name,
            //          then a disambiguating string can be provided to
            //          differentiate after the fact, or in a rule.

            //var album_id: i32 = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(formed)));
            //const song_id = (song_hash ^ artist_hash ^ album_hash);

            var albumsong = try jetzig.database.Query(.Albumsong).findBy(.{ .album_id = album_id, .song_id = song_id }).select(.{.id}).execute(env.repo);
            var ins_album = try jetzig.database.Query(.Album).find(album_id).select(.{.id}).execute(env.repo);

            var ins_artist = try jetzig.database.Query(.Artist).find(artist_id).select(.{.id}).execute(env.repo);
            if (ins_artist == null) ins_artist = try jetzig.database.Query(.Artist).insert(.{ .id = artist_id, .name = scrobble.artist, .disambiguation = null }).returning(.{.id}).execute(env.repo);

            if (albumsong == null) {
                var ins_song = try jetzig.database.Query(.Song).find(song_id).select(.{.id}).execute(env.repo);
                if (ins_song == null) ins_song = try jetzig.database.Query(.Song).insert(.{ .id = song_id, .name = scrobble.track, .length = null, .hidden = false }).returning(.{.id}).execute(env.repo);

                if (ins_album == null) {
                    ins_album = try jetzig.database.Query(.Album).insert(.{ .id = album_id, .name = scrobble.album, .length = null }).returning(.{.id}).execute(env.repo);
                    // I think there's still technically a bug here when you have a different artist but I'm not sure
                    try jetzig.database.Query(.Artistalbum).insert(.{ .artist_id = ins_artist.?.id, .album_id = ins_album.?.id }).execute(env.repo);
                }

                albumsong = try jetzig.database.Query(.Albumsong).insert(.{ .song_id = ins_song.?.id, .album_id = ins_album.?.id }).returning(.{.id}).execute(env.repo);

                try jetzig.database.Query(.Albumsongsartist).insert(.{ .albumsong_id = albumsong.?.id, .artist_id = ins_artist.?.id }).execute(env.repo);
            } else {
                const ins_albumsongartist = try jetzig.database.Query(.Albumsongsartist).findBy(.{ .albumsong_id = albumsong.?.id, .artist_id = ins_artist.?.id }).select(.{.id}).execute(env.repo);
                if (ins_albumsongartist == null) try jetzig.database.Query(.Albumsongsartist).insert(.{ .albumsong_id = albumsong.?.id, .artist_id = ins_artist.?.id }).execute(env.repo);

                const ins_artistalbum = try jetzig.database.Query(.Artistalbum).findBy(.{ .album_id = ins_album.?.id, .artist_id = ins_artist.?.id }).select(.{.id}).execute(env.repo);
                if (ins_artistalbum == null) try jetzig.database.Query(.Artistalbum).insert(.{ .album_id = ins_album.?.id, .artist_id = ins_artist.?.id }).execute(env.repo);
            }

            //if (ins_artist_id == null) {
            //    ins_artist_id = try jetzig.database.Query(.Artist).insert(.{ .id = artist_id, .name = scrobble.artist, .disambiguation = null }).returning(.{.id}).execute(env.repo);
            //    try jetzig.database.Query(.Albumsongartist).insert(.{ .albumsong_id = albumsong_id, .artist_id = ins_artist_id });
            //    try jetzig.database.Query(.Artistalbum).insert(.{ .artist_id = ins_artist_id, .album_id = ins_album_id });
            //}

            try jetzig.database.Query(.Scrobble).insert(.{ .albumsong = albumsong.?.id, .datetime = scrobble.date }).execute(env.repo);
        }
    }

    // I would like to replicate this kind of functionality for several kinds of queries
    // This one gives me all albums by Dream Theater (it also returns Dream Theater for
    // each entry, but removing artists.name from the SELECT would remove that)
    //
    // SELECT
    // artists.name, albums.name
    // FROM
    // "Albumartists"
    // INNER JOIN artists
    // ON "Albumartists".artist_id = artists.id
    // INNER JOIN albums
    // ON "Albumartists".album_id = albums.id
    // WHERE artists.name = 'Dream Theater';

    //const query = jetzig.database.Query(.Artist).include(.artistalbums, .{});
    //const results = try env.repo.all(query);
    //defer env.repo.free(results);
    //for (results) |result| {
    //    for (result.artistalbums) |artistalbum| {
    //        std.log.debug("{s}: {any}", .{ result.name, artistalbum.album_id });
    //    }
    //}
}
