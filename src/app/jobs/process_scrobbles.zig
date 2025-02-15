const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

const Scrobble = struct {
    track: []u8,
    artist: []u8,
    album: ?[]u8,
    date: u64,
};
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
    _ = env;
    if (params.getT(.array, "data")) |scrobbles| {

        //var scrobble = params.pop();
        for (scrobbles.items()) |val| {
            std.log.debug("{s}", .{val});
            // const scrobble = val.coerce(Scrobble);
            // // Make hashes
            // const album_hash = std.hash.Fnv1a_64.hash(scrobble.album);
            // const artist_hash = std.hash.Fnv1a_64.hash(scrobble.artist);
            // const song_hash = std.hash.Fnv1a_64.hash(scrobble.track);

            // var album_id: u64 = 0;
            // const song_id = (song_hash ^ artist_hash ^ album_hash) % 99999989;
            // if (artist_hash == album_hash) {
            //     album_id = album_hash % 99999989;
            // } else {
            //     album_id = (artist_hash ^ album_hash) % 99999989;
            // }
            // const artist_id = artist_hash % 99999989;

            // // ID start - I think we can use SERIAL for this
            // // We don't compare intermediate IDs to anything,
            // // so keeping it a SERIAL is probably fine
            // const artistalbum_offset = try jetzig.database.Query(.ArtistAlbum).select(.{}).count().execute(env.repo) orelse unreachable;
            // const albumsong_offset = try jetzig.database.Query(.AlbumSong).select(.{}).count().execute(env.repo) orelse unreachable;
            // const artistsong_offset = try jetzig.database.Query(.ArtistSong).select(.{}).count().execute(env.repo) orelse unreachable;

            // // Inserts
            // const artistalbum_insert = jetzig.database.Query(.ArtistAlbum).insert(.{ .id = 1 + artistalbum_offset, .artist_id = artist_id, .album_id = album_id });
            // const albumsong_insert = jetzig.database.Query(.AlbumSong).insert(.{ .id = 1 + albumsong_offset, .song_id = song_id, .album_id = album_id });
            // const artistsong_insert = jetzig.database.Query(.ArtistSong).insert(.{ .id = 1 + artistsong_offset, .artist_id = artist_id, .song_id = song_id });
            // const album_insert = jetzig.database.Query(.Album).insert(.{ .id = album_id, .title = scrobble.album, .song_num = 0, .length = 0.0, .play_count = 0, .holiday = false, .compilation = false, .deluxe = false, .live = false });
            // const artist_insert = jetzig.database.Query(.Artist).insert(.{ .id = artist_id, .name = scrobble.artist, .album_num = 0, .song_num = 0, .play_count = 0 });
            // const song_insert = jetzig.database.Query(.Song).insert(.{ .id = song_id, .title = scrobble.track, .length = 0.0, .hidden = false, .holiday = false, .play_count = 0 });

            // // Checks
            // const artistalbum_check = try jetzig.database.Query(.ArtistAlbum).where(.{ .{ .artist_id = artist_id }, .AND, .{ .album_id = album_id } }).count().execute(env.repo);
            // const albumsong_check = try jetzig.database.Query(.AlbumSong).where(.{ .{ .album_id = album_id }, .AND, .{ .song_id = song_id } }).count().execute(env.repo);
            // const artistsong_check = try jetzig.database.Query(.ArtistSong).where(.{ .{ .artist_id = artist_id }, .AND, .{ .song_id = song_id } }).count().execute(env.repo);
            // const album_check = try jetzig.database.Query(.Album).where(.{.{ .id = album_id }}).count().execute(env.repo);
            // const artist_check = try jetzig.database.Query(.Artist).where(.{.{ .id = artist_id }}).count().execute(env.repo);
            // const song_check = try jetzig.database.Query(.Song).where(.{.{ .id = song_id }}).count().execute(env.repo);

            // // Insert into Intermediate Tables
            // if (artistalbum_check == 0) try env.repo.execute(artistalbum_insert);
            // if (albumsong_check == 0) try env.repo.execute(albumsong_insert);
            // if (artistsong_check == 0) try env.repo.execute(artistsong_insert);

            // if (album_check == 0) try env.repo.execute(album_insert);
            // if (artist_check == 0) try env.repo.execute(artist_insert);
            // if (song_check == 0) try env.repo.execute(song_insert);

            // const scrobble_offset = try jetzig.database.Query(.Scrobble).select(.{}).count().execute(env.repo) orelse unreachable;
            // try jetzig.database.Query(.Scrobble).insert(.{ .id = scrobble_offset + 1, .song_id = song_id, .album_id = album_id, .artist_id = artist_id, .date = scrobble.date }).execute(env.repo);

            //scrobble = params.pop();
        }
    }
}
