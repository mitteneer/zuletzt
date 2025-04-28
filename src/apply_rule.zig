const std = @import("std");
const Rules = @import("./types.zig").Rules;
const Data = @import("./types.zig");

// Wrapper for containsAtLeast to make the switch below to work
fn containsWrapper(haystack: []const u8, needle: []const u8) bool {
    return std.mem.containsAtLeast(u8, haystack, 1, needle);
}

fn eqlWrapper(haystack: []const u8, needle: []const u8) bool {
    return std.mem.eql(u8, haystack, needle);
}

pub fn applyScrobbleRule(allocator: std.mem.Allocator, scrobble: Data.ImportedScrobble, rules: Rules) !Data.Scrobble {
    const artists = try allocator.alloc([]const u8, 1);
    artists[0] = scrobble.artist;
    var output_scrobble = Data.Scrobble{
        .track = scrobble.track,
        .artists_track = artists,
        .album = scrobble.album,
        .artists_album = artists,
        .date = scrobble.date,
    };

    for (rules.rules) |rule| {
        var match_found: bool = switch (rule.cond_req) {
            .any => false,
            .all => true,
        };
        for (rule.conditionals) |cond| {
            const match_fn: *const fn ([]const u8, []const u8) bool = switch (cond.match_cond) {
                .is => eqlWrapper,
                .contains => containsWrapper,
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
                    .add => {
                        var al = std.ArrayList([]const u8).init(allocator);
                        switch (act.action_on) {
                            .album, .track => unreachable,
                            inline else => |on| {
                                try al.appendSlice(@field(output_scrobble, @tagName(on)));
                                try al.append(act.action_txt);
                                const list = try al.toOwnedSlice();
                                @field(output_scrobble, @tagName(on)) = list;
                            },
                        }
                    },
                    .replace => switch (act.action_on) {
                        inline .album, .track => |on| @field(output_scrobble, @tagName(on)) = act.action_txt,
                        inline .artists_album, .artists_track => |on| {
                            const artist = try allocator.alloc([]const u8, 1);
                            artist[0] = act.action_txt;
                            @field(output_scrobble, @tagName(on)) = artist;
                        },
                    },
                }
            }
        }
    }

    return output_scrobble;
}
