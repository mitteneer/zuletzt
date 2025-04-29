const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;
const lastfm = @import("../../types.zig").LastFM;
const Data = @import("../../types.zig");
const rules = @import("../../apply_rule.zig");

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
    if (params.getT(.array, "scrobbles")) |scrobbles| {
        for (scrobbles.items()) |item| {

            // Probably want to include artist name here, but not sure how to yet

            const track_artist_count = item.getT(.array, "artists_track").?.count();
            const album_artist_count = item.getT(.array, "artists_album").?.count();
            var track_artist_name_buffer = try allocator.alloc([]const u8, track_artist_count);
            var album_artist_name_buffer = try allocator.alloc([]const u8, album_artist_count);
            var track_artist_id_buffer = try allocator.alloc(i32, track_artist_count);
            var album_artist_id_buffer = try allocator.alloc(i32, album_artist_count);

            const scrobble: Data.Scrobble = .{
                .track = item.getT(.string, "track").?,
                .artists_track = track_artist_name_buffer,
                .album = item.getT(.string, "album") orelse "",
                .artists_album = album_artist_name_buffer,
                .date = @as(u64, @bitCast(@as(i64, @truncate(item.getT(.integer, "date").?)))),
            };

            var id_prehash = std.ArrayList(u8).init(allocator);

            for (item.getT(.array, "artists_track").?.items(), 0..track_artist_count) |artist, i| {
                const artist_name = try artist.coerce([]const u8);
                track_artist_name_buffer[i] = artist_name;
                track_artist_id_buffer[i] = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(artist_name)));
            }

            for (item.getT(.array, "artists_album").?.items(), 0..album_artist_count) |artist, i| {
                const artist_name = try artist.coerce([]const u8);
                album_artist_name_buffer[i] = artist_name;
                album_artist_id_buffer[i] = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(artist_name)));
                try id_prehash.appendSlice(artist_name);
            }

            try id_prehash.appendSlice(scrobble.album);
            const album_id = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(id_prehash.items)));
            try id_prehash.appendSlice(scrobble.track);
            const song_id = @as(i32, @bitCast(std.hash.Fnv1a_32.hash(id_prehash.items)));

            var albumsong = try jetzig.database.Query(.Albumsong)
                .findBy(.{ .album_id = album_id, .song_id = song_id })
                .select(.{.id}).execute(env.repo);

            var ins_album = try jetzig.database.Query(.Album)
                .find(album_id)
                .select(.{.id}).execute(env.repo);

            for (track_artist_name_buffer, track_artist_id_buffer) |artist_name, artist_id| {
                var ins_artist = try jetzig.database.Query(.Artist)
                    .find(artist_id)
                    .select(.{.id}).execute(env.repo);

                if (ins_artist == null)
                    ins_artist = try jetzig.database.Query(.Artist)
                        .insert(.{ .id = artist_id, .name = artist_name, .disambiguation = null })
                        .returning(.{.id}).execute(env.repo);

                if (albumsong == null) {
                    var ins_song = try jetzig.database.Query(.Song)
                        .find(song_id)
                        .select(.{.id}).execute(env.repo);

                    if (ins_song == null)
                        ins_song = try jetzig.database.Query(.Song)
                            .insert(.{ .id = song_id, .name = scrobble.track, .length = null, .hidden = false })
                            .returning(.{.id}).execute(env.repo);

                    if (ins_album == null)
                        ins_album = try jetzig.database.Query(.Album)
                            .insert(.{ .id = album_id, .name = scrobble.album, .length = null })
                            .returning(.{.id}).execute(env.repo);

                    albumsong = try jetzig.database.Query(.Albumsong)
                        .insert(.{ .song_id = ins_song.?.id, .album_id = ins_album.?.id })
                        .returning(.{.id}).execute(env.repo);

                    try jetzig.database.Query(.Albumsongsartist)
                        .insert(.{ .albumsong_id = albumsong.?.id, .artist_id = ins_artist.?.id }).execute(env.repo);
                } else {
                    const ins_albumsongartist = try jetzig.database.Query(.Albumsongsartist)
                        .findBy(.{ .albumsong_id = albumsong.?.id, .artist_id = ins_artist.?.id })
                        .select(.{.id}).execute(env.repo);

                    if (ins_albumsongartist == null)
                        try jetzig.database.Query(.Albumsongsartist)
                            .insert(.{ .albumsong_id = albumsong.?.id, .artist_id = ins_artist.?.id }).execute(env.repo);
                }
            }
            for (album_artist_name_buffer, album_artist_id_buffer) |artist_name, artist_id| {
                const ins_artistalbum = try jetzig.database.Query(.Artistalbum)
                    .findBy(.{ .album_id = ins_album.?.id, .artist_id = artist_id })
                    .select(.{.id}).execute(env.repo);

                if (ins_artistalbum == null) {
                    var ins_artist = try jetzig.database.Query(.Artist)
                        .find(artist_id)
                        .select(.{.id}).execute(env.repo);
                    if (ins_artist == null)
                        ins_artist = try jetzig.database.Query(.Artist)
                            .insert(.{ .id = artist_id, .name = artist_name, .disambiguation = null })
                            .returning(.{.id}).execute(env.repo);
                    try jetzig.database.Query(.Artistalbum)
                        .insert(.{ .album_id = ins_album.?.id, .artist_id = ins_artist.?.id }).execute(env.repo);
                }
            }

            try jetzig.database.Query(.Scrobble)
                .insert(.{ .albumsong = albumsong.?.id, .datetime = scrobble.date }).execute(env.repo);
        }
    }
}
