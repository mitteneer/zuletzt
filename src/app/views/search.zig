const std = @import("std");
const jetzig = @import("jetzig");
const queries = @import("../lib/db.zig");
const sqlite = @import("sqlite");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    _ = data;
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
    //var root = try data.object();
    const params = try request.params();
    const query: ?[]const u8 = if (params.get("q")) |param| param.string.value else null;
    if (query != null){
 //       sql.search(query, db);
        var artistSearch = try db.prepare(queries.getArtistSearch);
        defer artistSearch.deinit();

        const artistResults = try artistSearch.all(
            struct{
                artist: []u8,
                plays: usize,
            },
            arena.allocator(),
            .{},
            .{ .artist = query},
        );

        for (artistResults) |r|{
            std.log.debug("artist: {s}, Plays: {}", .{r.artist, r.plays});
            //std.log.debug("{s}", .{r});
        }
    } else{
        return request.render(.bad_request);
    }
    //const query =  params.get("q");
    //try root.put("q",query);
    //try root.put("q", data.string("Welcome"));
    return request.render(.ok);
}
