const std = @import("std");
const Scrobble = @import("./types.zig").LastFMScrobble;
const Rules = @import("./types.zig").Rules;

pub fn applyScrobbleRule(scrobble: Scrobble, rules: Rules) Scrobble {
    var match_found: bool = true;
    var output_scrobble: Scrobble = scrobble;
    for (rules.rules) |rule| {
        for (rule.conditionals) |cond| {
            switch (cond.match_cond) {
                .is => switch (cond.match_on) {
                    inline else => |on| match_found = match_found and std.mem.eql(u8, @field(scrobble, @tagName(on)), cond.match_txt),
                },
                .contains => switch (cond.match_on) {
                    inline else => |on| match_found = match_found and std.mem.containsAtLeast(u8, @field(scrobble, @tagName(on)), 1, cond.match_txt),
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
