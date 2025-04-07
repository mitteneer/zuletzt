const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "scrobbles",
        &.{
            t.primaryKey("id", .{}),
            t.column("albumsong", .integer, .{ .reference = .{ "albumsongs", "id" } }),
            t.column("datetime", .datetime, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("scrobbles", .{});
}
