const std = @import("std");
//const log = std.math.log10;

pub fn ordinalFmt(allocator: std.mem.Allocator, ord: isize) ![]const u8 {
    const buff = try allocator.alloc(u8, 3 + @as(usize, @intFromFloat(@floor(@log10(@as(f64, @floatFromInt(ord)))))));
    const ind: []const u8 = switch (@mod(ord, 100)) {
        11, 12, 13 => "th",
        else => switch (@mod(ord, 10)) {
            1 => "st",
            2 => "nd",
            3 => "rd",
            else => "th",
        },
    };
    return std.fmt.bufPrint(buff, "{}{s}", .{ ord, ind });
}
