const std = @import("std");
const jetzig = @import("jetzig");
const queries = @import("../lib/db.zig");
const sqlite = @import("sqlite");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.array();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    var db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = "/home/swebb/Source/zuletzt/src/app/database/data.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });
    const params = try request.params();
    const queryOrNull: ?[]const u8 = if (params.get("q")) |param| param.string.value else null;
    if (queryOrNull) |query| {
        //       sql.search(query, db);
        var artistSearch = try db.prepare(queries.total_search);
        defer artistSearch.deinit();

        const artistResults = try artistSearch.all(
            struct {
                artist: []u8,
                url: []u8,
                form: []u8,
            },
            arena.allocator(),
            .{},
            .{ .artist = query, .album = query, .track = query },
        );

        for (artistResults) |r| {
            std.log.debug("artist: {s}, url: {s}", .{ r.artist, r.url });
            try root.append(data.string(r.artist));
            try root.append(data.string(r.url));
            try root.append(data.string(r.form));
            //std.log.debug("{s}", .{r});
        }
    } else {
        return request.render(.bad_request);
    }
    //const query =  params.get("q");
    //try root.put("q",query);
    //try root.put("q", data.string("Welcome"));
    return request.render(.ok);
}
