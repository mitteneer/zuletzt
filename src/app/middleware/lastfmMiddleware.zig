/// Demo middleware. Assign middleware by declaring `pub const middleware` in the
/// `jetzig_options` defined in your application's `src/main.zig`.
///
/// Middleware is called before and after the request, providing full access to the active
/// request, allowing you to execute any custom code for logging, tracking, inserting response
/// headers, etc.
///
/// This middleware is configured in the demo app's `src/main.zig`:
///
/// ```
/// pub const jetzig_options = struct {
///    pub const middleware: []const type = &.{@import("app/middleware/DemoMiddleware.zig")};
/// };
/// ```
const std = @import("std");
const jetzig = @import("jetzig");
const jetquery = @import("jetzig").jetquery;

/// Define any custom data fields you want to store here. Assigning to these fields in the `init`
/// function allows you to access them in various middleware callbacks defined below, where they
/// can also be modified.
my_custom_value: []const u8,

const Self = @This();

/// Initialize middleware.
pub fn init(request: *jetzig.http.Request) !*Self {
    var middleware = try request.allocator.create(Self);
    middleware.my_custom_value = "initial value";
    return middleware;
}

/// Invoked immediately after the request is received but before it has started processing.
/// Any calls to `request.render` or `request.redirect` will prevent further processing of the
/// request, including any other middleware in the chain.
//pub fn afterRequest(self: *Self, request: *jetzig.http.Request) !void {
//    const Scrobble = struct {
//        track: []u8,
//        artist: []u8,
//        album: []u8,
//        date: i64
//    };
//
//    const lastfm = struct {
//        username: u8,
//        scrobbles: []Scrobble,
//    };
//
//    var root = try request.data(.object);
//
//    if (try request.file("upload")) |file| {
//        const parsed = try std.json.parseFromSlice(lastfm, request.allocator, file.content, .{});
//        const history = parsed.value;
//        var scrobbles = try root.put("scrobbles", .array);
//
//        for (history.scrobbles) |scrobble| {
//            try scrobbles.append(scrobble);
//        }
//
//        //var scrobble = try root.put("scrobbles", .array);
//    }
//}

/// Invoked immediately before the response renders to the client.
/// The response can be modified here if needed.
pub fn beforeResponse(self: *Self, request: *jetzig.http.Request, response: *jetzig.http.Response) !void {
    try request.server.logger.DEBUG(
        "[DemoMiddleware:beforeResponse] my_custom_value: {s}, response status: {s}",
        .{ self.my_custom_value, @tagName(response.status_code) },
    );
}
