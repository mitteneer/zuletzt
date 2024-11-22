const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "songs",
        &.{
            t.primaryKey("id", .{}),
            t.column("title", .string, .{}),
            t.column("length", .float, .{}),
            t.column("hidden", .boolean, .{}),
            t.column("holiday", .boolean, .{}),
            t.column("play_count", .integer, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("songs", .{});
}
