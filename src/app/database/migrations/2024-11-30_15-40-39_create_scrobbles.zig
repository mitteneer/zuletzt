const std = @import("std");
const jetquery = @import("jetquery");
const t = jetquery.schema.table;

pub fn up(repo: anytype) !void {
    try repo.createTable(
        "scrobbles",
        &.{
            t.primaryKey("id", .{}),
            t.column("date", .datetime, .{}),
            t.column("song_id", .integer, .{}),
            t.column("album_id", .integer, .{ .optional = true }),
            t.column("artist_id", .integer, .{}),
            t.timestamps(.{}),
        },
        .{},
    );
}

pub fn down(repo: anytype) !void {
    try repo.dropTable("scrobbles", .{});
}
