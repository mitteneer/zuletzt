const std = @import("std");
const jetzig = @import("jetzig");
const search = @import("../../db.zig");

pub fn index(request: *jetzig.Request, data: *jetzig.Data) !jetzig.View {
    var root = try data.object();
    const params = try request.params();
    const query =  params.get("q");
    try root.put("q",query);
    //try root.put("q", data.string("Welcome"));
    return request.render(.ok);
}
