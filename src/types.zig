pub const LastFMScrobble = struct {
    track: []u8,
    artist: []u8,
    album: ?[]u8,
    date: u64,
};

// From lastfmstats.com
pub const LastFM = struct { username: []u8, scrobbles: []LastFMScrobble };

pub const SpotifyScrobble = struct {
    ts: []u8,
    username: []u8,
    platform: []u8,
    ms_played: u64,
    conn_country: []u8,
    ip_addr_decrypted: []u8,
    user_agent_decrypted: []u8,
    master_metadata_track_name: []u8,
    master_metadata_artist_name: []u8,
    master_metadata_album_name: []u8,
    spotify_track_uri: []u8,
    episode_name: []u8,
    reason_start: []u8,
    reason_end: []u8,
    shuffle: bool,
    skipped: bool,
    offline: bool,
    offline_timestamp: u64,
    incognito_mode: bool,
};

pub const Spotify = struct { scrobbles: []SpotifyScrobble };
