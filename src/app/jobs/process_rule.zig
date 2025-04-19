const std = @import("std");
const jetzig = @import("jetzig");

pub fn run(allocator: std.mem.Allocator, params: *jetzig.data.Value, env: jetzig.jobs.JobEnv) !void {
    _ = allocator;
    _ = env;
    //_ = params;

    const rule = try params.toJson();

    //const rule = struct {
    //    name: []const u8 = params,
    //    conditions: []struct {
    //        match_on: []const u8,
    //        match_cond: []const u8,
    //        match_text: []const u8,
    //    },
    //    actions: []struct {
    //        action: []const u8,
    //        action_cond: []const u8,
    //        action_text: []const u8,
    //    },
    //};

    //var file = try std.fs.cwd().openFile("rules.json", .{});

    //_ = try file.write(rule);
    try std.fs.cwd().writeFile(.{ "rules.json", rule, .{} });

    // Job execution code goes here. Add any code that you would like to run in the background.
    //try env.logger.INFO("Running a job.", .{});
}
