const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "aliases",
        &.{
            t.primaryKey("id", .{}),
            t.column("reference_id", .integer, .{}),
            t.column("alias", .string, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("aliases", .{});
}
