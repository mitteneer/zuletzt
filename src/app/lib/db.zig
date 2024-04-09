const std = @import("std");
const sql  = @import("sqlite");

pub fn loadDb(path: []u8) !sql.sqlite.Db{
    try sql.sqlite.Db.init(.{
    .mode = sql.sqlite.Db.Mode{ .File = path},
    .open_flags = .{
        .write = true,
        .create = true,
    },
    .threading_mode = .MultiThread,
    });
}

const addArtist = \\INSERT INTO artists ('artist', 'plays', 'url') VALUES (?,?)
;

const addTrack = \\INSERT INTO tracks ('artist', 'track', 'album', 'plays', 'url') VALUES (?,?,?,?)
;

const getArtist = \\SELECT artist, plays FROM artists WHERE artist == ?
;

const getTrack = \\SELECT artist, track, album, plays FROM tracks WHERE track == ?
;

const getTrackSearch = \\SELECT url FROM artists WHERE artist == ?
;

const getArtistSearch = \\SELECT artist, plays FROM artists WHERE artist == ?
;

pub var db = loadDb("/home/swebb/Source/zuletzt/src/app/database/data.db");

pub fn search(query: []const u8) !void{
    var artistSearch = try db.prepare(getArtistSearch);
    defer artistSearch.deinit();
    var trackSearch = try db.prepare(getTrackSearch);
    defer trackSearch.deinit();

    const artistResults = try artistSearch.one(
        struct {
            artist: [128:0]u8,
            plays: usize,
        },
        .{},
        .{ .artist = query},
    );

    if (artistResults) |r|{
        std.log.debug("Artist: {}, Plays: {}", .{r.name, r.plays});
    }

}