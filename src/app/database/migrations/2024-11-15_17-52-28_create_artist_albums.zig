const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "artist_albums",
        &.{
            t.primaryKey("id", .{}),
            t.column("artist_id", .integer, .{}),
            t.column("album_id", .integer, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("artist_albums", .{});
}
