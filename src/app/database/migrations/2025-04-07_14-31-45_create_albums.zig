const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "albums",
        &.{
            t.primaryKey("id", .{}),
            t.column("name", .string, .{}),
            t.column("length", .float, .{ .optional = true }),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("albums", .{});
}
