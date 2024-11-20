const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "albums",
        &.{
            t.primaryKey("id", .{}),
            t.column("title", .string, .{}),
            t.column("song_num", .integer, .{}),
            t.column("length", .float, .{}),
            t.column("play_count", .integer, .{}),
            t.column("score", .float, .{}),
            t.column("avg_song_score", .float, .{}),
            t.column("url", .string, .{}),
            t.column("holiday", .boolean, .{}),
            t.column("compilation", .boolean, .{}),
            t.column("collaboration", .boolean, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("albums", .{});
}
