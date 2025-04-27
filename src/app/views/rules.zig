const std = @import("std");
const jetzig = @import("jetzig");

pub fn index(request: *jetzig.Request) !jetzig.View {
    return request.render(.ok);
}

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn new(request: *jetzig.Request) !jetzig.View {
    return request.render(.ok);
}

pub fn edit(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
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

pub fn put(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn patch(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

pub fn delete(id: []const u8, request: *jetzig.Request) !jetzig.View {
    _ = id;
    return request.render(.ok);
}

test "index" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/rules", .{});
    try response.expectStatus(.ok);
}

test "get" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/rules/example-id", .{});
    try response.expectStatus(.ok);
}

test "new" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/rules/new", .{});
    try response.expectStatus(.ok);
}

test "edit" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.GET, "/rules/example-id/edit", .{});
    try response.expectStatus(.ok);
}

test "post" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.POST, "/rules", .{});
    try response.expectStatus(.created);
}

test "put" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PUT, "/rules/example-id", .{});
    try response.expectStatus(.ok);
}

test "patch" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.PATCH, "/rules/example-id", .{});
    try response.expectStatus(.ok);
}

test "delete" {
    var app = try jetzig.testing.app(std.testing.allocator, @import("routes"));
    defer app.deinit();

    const response = try app.request(.DELETE, "/rules/example-id", .{});
    try response.expectStatus(.ok);
}
