const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "Songartists",
        &.{
            t.primaryKey("id", .{}),
            t.column("song_id", .integer, .{}),
            t.column("artist_id", .integer, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("Songartists", .{});
}
