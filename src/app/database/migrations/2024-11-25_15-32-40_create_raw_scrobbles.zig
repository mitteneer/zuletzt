const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "raw_scrobbles",
        &.{
            t.primaryKey("id", .{}),
            t.column("track", .string, .{}),
            t.column("artist", .string, .{}),
            t.column("album", .string, .{}),
            t.column("date", .integer, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("raw_scrobbles", .{});
}
