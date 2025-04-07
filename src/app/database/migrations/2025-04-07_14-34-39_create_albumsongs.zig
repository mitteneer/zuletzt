const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "albumsongs",
        &.{
            t.primaryKey("id", .{}),
            t.column("song_id", .integer, .{ .reference = .{ "songs", "id" } }),
            t.column("album_id", .integer, .{ .reference = .{ "albums", "id" } }),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("albumsongs", .{});
}
