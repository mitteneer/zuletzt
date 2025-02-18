const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "ratings",
        &.{
            t.primaryKey("id", .{}),
            t.column("reference_id", .integer, .{}),
            t.column("score", .float, .{}),
            t.column("date", .datetime, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("ratings", .{});
}
