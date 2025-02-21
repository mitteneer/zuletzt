const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const Scrobble = @import("../../types.zig").SafeLastFMScrobble;
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
    _ = allocator;
    //_ = env;

    if (params.getT(.array, "scrobbles")) |scrobbles| {
        for (scrobbles.items()) |item| {
            //const fixed_date: u32 = @as(u32, item.getT(.integer, "date").?);
            const scrobble: Scrobble = .{ .track = item.getT(.string, "track").?, .artist = item.getT(.string, "artist").?, .album = item.getT(.string, "album") orelse "", .date = @as(u64, @bitCast(@as(i64, @truncate(item.getT(.integer, "date").? * 1000)))) };

            // Make hashes
            const album_hash = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.album)));
            const artist_hash = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.artist)));
            const song_hash = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(scrobble.track)));

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
            //          issue for Weezer.

            // Artist:  Artist hash. If two artists have the same name,
            //          then a descriptive string can be provided to
            //          differentiate after the fact, or in a rule.

            var album_id: i32 = 0;
            const song_id = (song_hash ^ artist_hash ^ album_hash);
            if (artist_hash == album_hash) {
                album_id = album_hash;
            } else {
                album_id = (artist_hash ^ album_hash);
            }
            const artist_id = artist_hash;

            // Inserts
            const album_insert = jetzig.database.Query(.Album).insert(.{ .id = album_id, .name = scrobble.album, .length = null });
            const artist_insert = jetzig.database.Query(.Artist).insert(.{ .id = artist_id, .name = scrobble.artist, .descriptive_string = "" });
            const song_insert = jetzig.database.Query(.Song).insert(.{ .id = song_id, .name = scrobble.track, .length = null, .hidden = false });

            // Checks
            const album_check = try jetzig.database.Query(.Album).find(album_id).execute(env.repo);
            const artist_check = try jetzig.database.Query(.Artist).find(artist_id).execute(env.repo);
            const song_check = try jetzig.database.Query(.Song).find(song_id).execute(env.repo);

            // I think there must be a better way to do this next part
            // There are very few situations where artist_check is null
            // but song_check/album is not. Also yes, the order of these
            // checks is weird, I didn't put a lot of thought into it
            var associative_table_flags: [3]bool = [3]bool{ true, true, true };

            if (album_check == null) {
                try env.repo.execute(album_insert);
                try jetzig.database.Query(.Albumartist).insert(.{ .album_id = album_id, .artist_id = artist_id }).execute(env.repo);
                associative_table_flags[0] = false;
                try jetzig.database.Query(.Albumsong).insert(.{ .album_id = album_id, .song_id = song_id }).execute(env.repo);
                associative_table_flags[1] = false;
            }

            if (artist_check == null) {
                try env.repo.execute(artist_insert);
                if (associative_table_flags[0]) try jetzig.database.Query(.Albumartist).insert(.{ .album_id = album_id, .artist_id = artist_id }).execute(env.repo);
                try jetzig.database.Query(.Songartist).insert(.{ .song_id = song_id, .artist_id = artist_id }).execute(env.repo);
                associative_table_flags[2] = false;
            }

            if (song_check == null) {
                try env.repo.execute(song_insert);
                if (associative_table_flags[1]) try jetzig.database.Query(.Albumsong).insert(.{ .album_id = album_id, .song_id = song_id }).execute(env.repo);
                if (associative_table_flags[2]) try jetzig.database.Query(.Songartist).insert(.{ .song_id = song_id, .artist_id = artist_id }).execute(env.repo);
            }

            try jetzig.database.Query(.Scrobble).insert(.{ .song_id = song_id, .album_id = album_id, .date = scrobble.date }).execute(env.repo);
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
