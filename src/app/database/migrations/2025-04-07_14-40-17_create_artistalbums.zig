const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "artistalbums",
        &.{
            t.primaryKey("id", .{}),
            t.column("album_id", .integer, .{ .reference = .{ "albums", "id" } }),
            t.column("artist_id", .integer, .{ .reference = .{ "artists", "id" } }),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("artistalbums", .{});
}
