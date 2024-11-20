const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "artists",
        &.{
            t.primaryKey("id", .{}),
            t.column("name", .string, .{}),
            t.column("album_num", .integer, .{}),
            t.column("song_num", .integer, .{}),
            t.column("play_count", .integer, .{}),
            t.column("avg_album_score", .float, .{}),
            t.column("avg_song_score", .float, .{}),
            t.column("url", .string, .{}),
            t.column("aliased", .boolean, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("artists", .{});
}
