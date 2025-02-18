const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "songs",
        &.{
            t.primaryKey("id", .{}),
            t.column("name", .string, .{}),
            t.column("length", .float, .{ .optional = true }),
            t.column("hidden", .boolean, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("songs", .{});
}
