const std = @import("std");
const jetzig = @import("jetzig");

pub fn run(allocator: std.mem.Allocator, params: *jetzig.data.Value, env: jetzig.jobs.JobEnv) !void {
    _ = env;
    //_ = params;

    const Rule = struct {
        name: []const u8,
        conditionals: []struct {
            match_on: []const u8,
            match_cond: []const u8,
            match_txt: []const u8,
        },
        actions: []struct {
            action: []const u8,
            action_on: []const u8,
            action_txt: []const u8,
        },
    };

    const Rules = struct {
        rules: []const Rule,
    };

    const rule = try std.json.parseFromSliceLeaky(Rule, allocator, try params.toJson(), .{ .ignore_unknown_fields = true });

    const file_read: std.fs.File = std.fs.cwd().openFile("rules.json", .{}) catch |read_err| switch (read_err) {
        error.FileNotFound => {
            const file = std.fs.cwd().createFile("rules.json", .{ .read = true, .exclusive = true }) catch |write_err| switch (write_err) {
                error.PathAlreadyExists => unreachable,
                else => {
                    std.log.debug("{any} while writing file", .{write_err});
                    return;
                },
            };
            const out_rules = Rules{ .rules = &[_]Rule{rule} };
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

    var rules = std.ArrayList(Rule).init(allocator);
    defer rules.deinit();

    const file_content = try file_read.readToEndAlloc(allocator, 16_000_000);
    const content: Rules = try std.json.parseFromSliceLeaky(Rules, allocator, file_content, .{});
    try rules.appendSlice(content.rules);
    try rules.append(rule);
    file_read.close();

    const file_write: std.fs.File = try std.fs.cwd().openFile("rules.json", .{ .mode = .write_only });
    const out_rules = Rules{ .rules = rules.items };
    const out = try std.json.stringifyAlloc(allocator, out_rules, .{});

    try file_write.writeAll(out);
    file_write.close();
    return;
}
