const std = @import("std");
const jetzig = @import("jetzig");

pub const static_params = .{
    .index = .{
        //.{ .params = .{ .foo = "hi", .bar = "bye" } },
        //.{ .params = .{ .foo = "hello", .bar = "goodbye" } },
    },
    //.get = .{
    //    .{ .id = "1", .params = .{ .foo = "hi", .bar = "bye" } },
    //    .{ .id = "2", .params = .{ .foo = "hello", .bar = "goodbye" } },
    //},
};

pub fn index(request: *jetzig.StaticRequest, data: *jetzig.Data) !jetzig.View {
    var root = try data.object();

    const params = try request.params();

    if (params.get("foo")) |foo| try root.put("foo", foo);
    if (params.get("foo") == null) try root.put("foo", data.string("no foo"));
    if (params.get("bar")) |bar| try root.put("bar", bar);
    if (params.get("bar") == null) try root.put("bar", data.string("no bar"));

    return request.render(.ok);
}

//pub fn get(id: []const u8, request: *jetzig.StaticRequest, data: *jetzig.Data) !jetzig.View {
//    var root = try data.object();
//
//    const params = try request.params();
//
//    if (std.mem.eql(u8, id, "1")) {
//        try root.put("id", data.string("id is '1'"));
//    }
//
//    if (params.get("foo")) |foo| try root.put("foo", foo);
//    if (params.get("bar")) |bar| try root.put("bar", bar);
//
//    return request.render(.created);
//}