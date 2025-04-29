const std = @import("std");
const zeit = @import("zeit");

pub fn dateFmt(allocator: std.mem.Allocator, epoch: i64) ![]const u8 {
    var date = std.ArrayList(u8).init(allocator);
    try (try zeit.instant(.{ .source = .{ .unix_timestamp = @divFloor(epoch, 1_000) } })).time().strftime(date.writer(), "%d %b %Y, %H:%M");
    return date.items;
}
