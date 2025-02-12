const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "concerts",
        &.{
            t.primaryKey("id", .{}),
            t.column("location", .string, .{}),
            t.column("date", .datetime, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("concerts", .{});
}
