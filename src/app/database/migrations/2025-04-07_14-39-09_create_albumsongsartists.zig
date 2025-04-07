const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "albumsongsartists",
        &.{
            t.primaryKey("id", .{}),
            t.column("albumsong_id", .integer, .{ .reference = .{ "albumsongs", "id" } }),
            t.column("artist_id", .integer, .{ .reference = .{ "artists", "id" } }),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("albumsongsartists", .{});
}
