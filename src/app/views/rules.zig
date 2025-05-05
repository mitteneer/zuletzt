const std = @import("std");
const jetzig = @import("jetzig");

pub fn index(request: *jetzig.Request) !jetzig.View {
    return request.render(.ok);
}
pub fn post(request: *jetzig.Request) !jetzig.View {
    const params = try request.params();

    std.log.debug("{s}", .{try params.toJson()});

    var job = try request.job("process_rule");

    _ = try job.params.put("name", params.get("rule-title"));
    _ = try job.params.put("cond_req", params.get("cond-req"));

    var conditionals = try job.params.put("conditionals", .array);
    inline for (0..5) |i| {
        if (!std.mem.eql(u8, "", params.getT(.string, comptime std.fmt.comptimePrint("match-txt{}", .{i})).?)) {
            //if (params.getT(.string, comptime std.fmt.comptimePrint("match-txt{}", .{i})) != null) {
            var cond = try conditionals.append(.object);
            try cond.put("match_on", params.get(comptime std.fmt.comptimePrint("match-on{}", .{i})));
            try cond.put("match_cond", params.get(comptime std.fmt.comptimePrint("match-cond{}", .{i})));
            try cond.put("match_txt", params.get(comptime std.fmt.comptimePrint("match-txt{}", .{i})));
        }
    }

    var actions = try job.params.put("actions", .array);
    inline for (0..5) |i| {
        if (!std.mem.eql(u8, "", params.getT(.string, comptime std.fmt.comptimePrint("action-txt{}", .{i})).?)) {
            //if (params.getT(.string, comptime std.fmt.comptimePrint("action-txt{}", .{i})) != null) {
            var act = try actions.append(.object);
            try act.put("action", params.get(comptime std.fmt.comptimePrint("action{}", .{i})));
            try act.put("action_on", params.get(comptime std.fmt.comptimePrint("action-on{}", .{i})));
            try act.put("action_txt", params.get(comptime std.fmt.comptimePrint("action-txt{}", .{i})));
        }
    }
    try job.schedule();

    return request.render(.created);
}
