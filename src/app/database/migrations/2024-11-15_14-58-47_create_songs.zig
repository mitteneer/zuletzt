const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "songs",
        &.{
            t.primaryKey("id", .{}),
            t.column("name", .string, .{}),
            t.column("play_count", .integer, .{}),
            t.column("length", .float, .{}),
            t.column("score", .float, .{}),
            t.column("url", .string, .{}),
            t.column("aliased", .boolean, .{}),
            t.column("track_num", .integer, .{}),
            t.column("hidden", .boolean, .{}),
            t.column("holiday", .boolean, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("songs", .{});
}
