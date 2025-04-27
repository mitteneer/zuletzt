const std = @import("std");
const jetzig = @import("jetzig");
const Data = @import("../../types.zig");

pub fn run(allocator: std.mem.Allocator, params: *jetzig.data.Value, env: jetzig.jobs.JobEnv) !void {
    _ = env;

    const rule = try std.json.parseFromSliceLeaky(Data.Rule, allocator, try params.toJson(), .{ .ignore_unknown_fields = true });

    const file_read: std.fs.File = std.fs.cwd().openFile("rules.json", .{}) catch |read_err| switch (read_err) {
        error.FileNotFound => {
            const file = std.fs.cwd().createFile("rules.json", .{ .read = true, .exclusive = true }) catch |write_err| switch (write_err) {
                error.PathAlreadyExists => unreachable,
                else => {
                    std.log.debug("{any} while writing file", .{write_err});
                    return;
                },
            };
            const out_rules = Data.Rules{ .rules = &[_]Data.Rule{rule} };
            const out = try std.json.stringifyAlloc(allocator, out_rules, .{});
            try file.writeAll(out);
            file.close();
            return;
        },
        else => {
            std.log.debug("{any} while reading file", .{read_err});
            return;
        },
    };

    var rules = std.ArrayList(Data.Rule).init(allocator);

    const file_content = try file_read.readToEndAlloc(allocator, 16_000_000);
    file_read.close();

    const file_write: std.fs.File = try std.fs.cwd().openFile("rules.json", .{ .mode = .write_only });
    if (file_content.len == 0) {
        const out_rules = Data.Rules{ .rules = &[_]Data.Rule{rule} };
        const out = try std.json.stringifyAlloc(allocator, out_rules, .{});
        try file_write.writeAll(out);
        file_write.close();
        return;
    }
    const content: Data.Rules = try std.json.parseFromSliceLeaky(Data.Rules, allocator, file_content, .{});
    try rules.appendSlice(content.rules);
    try rules.append(rule);

    const out_rules = Data.Rules{ .rules = rules.items };
    const out = try std.json.stringifyAlloc(allocator, out_rules, .{});

    try file_write.writeAll(out);
    file_write.close();
    return;
}
