const std = @import("std");
const jetzig = @import("jetzig");

// The `run` function for a job is invoked every time the job is processed by a queue worker
// (or by the Jetzig server if the job is processed in-line).
//
// Arguments:
// * allocator: Arena allocator for use during the job execution process.
// * params:    Params assigned to a job (from a request, any values added to `data`).
// * env:       Provides the following fields:
//              - logger:      Logger attached to the same stream as the Jetzig server.
//              - environment: Enum of `{ production, development }`.
pub fn run(allocator: std.mem.Allocator, params: *jetzig.data.Value, env: jetzig.jobs.JobEnv) !void {
    _ = allocator;
    _ = params;
    // Job execution code goes here. Add any code that you would like to run in the background.
    try env.logger.INFO("Running a job.", .{});
}
