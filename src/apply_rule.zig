const Scrobble = @import("types").LastFMScrobble;
const Rules = @import("types").Rules;

pub fn applyRule(scrobble: Scrobble, rules: Rules) !Scrobble {
    var output_scrobble: Scrobble = scrobble;
    for (rules) |rule| {
        for (rule.conditionals) |cond| {
            switch (cond.match_cond) {}
        }
    }
}
