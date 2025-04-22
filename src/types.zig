pub const LastFMScrobble = struct {
    track: []const u8,
    artist: []const u8,
    album: []const u8 = "",
    date: i128,
};

// From lastfmstats.com
pub const LastFM = struct { username: []const u8, scrobbles: []LastFMScrobble };

// I derived whether or not these values were optional from searching
// the respective fields for null in Vim, so there may be some fields
// that can be optional that I haven't run into yet
pub const SpotifyScrobble = struct {
    ts: []const u8,
    username: []const u8,
    platform: []const u8,
    ms_played: u64,
    conn_country: []const u8,
    ip_addr_decrypted: ?[]const u8,
    user_agent_decrypted: ?[]const u8,
    master_metadata_track_name: ?[]const u8,
    master_metadata_album_artist_name: ?[]const u8,
    master_metadata_album_album_name: ?[]const u8,
    spotify_track_uri: ?[]const u8,
    episode_name: ?[]const u8,
    episode_show_name: ?[]const u8,
    spotify_episode_uri: ?[]const u8,
    reason_start: []const u8,
    reason_end: ?[]const u8,
    shuffle: bool,
    skipped: ?bool,
    offline: bool,
    offline_timestamp: u64,
    incognito_mode: ?bool,
};

pub const Rule = struct {
    name: []const u8,
    cond_req: enum { any, all },
    conditionals: []struct {
        match_on: ScrobbleFields,
        match_cond: enum { is, contains },
        match_txt: []const u8,
    },
    actions: []struct {
        action: enum { replace, add },
        action_on: ScrobbleFields,
        action_txt: []const u8,
    },
};

pub const Rules = struct {
    rules: []const Rule,
};

pub const ScrobbleFields = enum {
    artist,
    album,
    track,
};
