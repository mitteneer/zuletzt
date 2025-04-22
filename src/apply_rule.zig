const std = @import("std");
const Scrobble = @import("./types.zig").LastFMScrobble;
const Rules = @import("./types.zig").Rules;

// Wrapper for containsAtLeast to make the switch below to work
fn containsAtLeastOne(haystack: []const u8, needle: []const u8) bool {
    return std.mem.containsAtLeast(u8, haystack, 1, needle);
}

fn eqlDecomped(haystack: []const u8, needle: []const u8) bool {
    return std.mem.eql(u8, haystack, needle);
}

pub fn applyScrobbleRule(scrobble: Scrobble, rules: Rules) Scrobble {
    var output_scrobble: Scrobble = scrobble;
    for (rules.rules) |rule| {
        var match_found: bool = switch (rule.cond_req) {
            .any => false,
            .all => true,
        };
        for (rule.conditionals) |cond| {
            const match_fn: *const fn ([]const u8, []const u8) bool = switch (cond.match_cond) {
                .is => eqlDecomped,
                .contains => containsAtLeastOne,
            };
            switch (rule.cond_req) {
                .any => switch (cond.match_on) {
                    inline else => |on| match_found = match_found or match_fn(@field(scrobble, @tagName(on)), cond.match_txt),
                },
                .all => switch (cond.match_on) {
                    inline else => |on| match_found = match_found and match_fn(@field(scrobble, @tagName(on)), cond.match_txt),
                },
            }
        }
        if (match_found) {
            for (rule.actions) |act| {
                switch (act.action) {
                    .add => {},
                    .replace => switch (act.action_on) {
                        inline else => |on| @field(output_scrobble, @tagName(on)) = act.action_txt,
                    },
                }
            }
        }
    }

    return output_scrobble;
}

//pub fn applyAlbumRule() !Album {}
