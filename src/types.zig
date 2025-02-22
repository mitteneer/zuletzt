const zeit = @import("zeit");

pub const LastFMScrobble = struct {
    track: []const u8,
    artist: []const u8,
    album: []const u8 = "",
    date: i128,
};

// From lastfmstats.com
pub const LastFM = struct { username: []const u8, scrobbles: []LastFMScrobble };

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

    pub fn scrobblize(self: *SpotifyScrobble) LastFMScrobble {
        return LastFMScrobble{ .track = self.master_metadata_track_name, .artist = self.master_metadata_artist_name, .album = self.master_metadata_album_name, .date = try zeit.instant(.{ .source = .{ .iso8601 = self.ts } }).unixTimestamp() };
    }
};

pub const Spotify = struct { scrobbles: []SpotifyScrobble };

const UploadDataTag = enum { spotify, lastfm };

pub const UploadData = union(UploadDataTag) { spotify: Spotify, lastfm: LastFM };
