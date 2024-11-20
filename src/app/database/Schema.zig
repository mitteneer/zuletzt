const jetquery = @import("jetzig").jetquery;

pub const AlbumSong = jetquery.Model(
    @This(),
    "album_songs",
    struct {
        id: i32,
        album_id: i32,
        song_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);

pub const Album = jetquery.Model(
    @This(),
    "albums",
    struct {
        id: i32,
        title: []const u8,
        song_num: i32,
        length: f64,
        play_count: i32,
        score: f64,
        avg_song_score: f64,
        url: []const u8,
        holiday: bool,
        compilation: bool,
        collaboration: bool,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
        },
    },
);

pub const ArtistAlbum = jetquery.Model(
    @This(),
    "artist_albums",
    struct {
        id: i32,
        artist_id: i32,
        album_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);

pub const ArtistSong = jetquery.Model(
    @This(),
    "artist_songs",
    struct {
        id: i32,
        artist_id: i32,
        song_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);

pub const Artist = jetquery.Model(
    @This(),
    "artists",
    struct {
        id: i32,
        name: []const u8,
        album_num: i32,
        song_num: i32,
        play_count: i32,
        avg_album_score: f64,
        avg_song_score: f64,
        url: []const u8,
        aliased: bool,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
        },
    },
);

pub const Scrobble = jetquery.Model(
    @This(),
    "scrobbles",
    struct {
        id: i32,
        date: jetquery.DateTime,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .song = jetquery.belongsTo(.Song, .{}),
            .album = jetquery.belongsTo(.Album, .{}),
            .artist = jetquery.belongsTo(.Artist, .{}),
        },
    },
);

pub const Song = jetquery.Model(
    @This(),
    "songs",
    struct {
        id: i32,
        name: []const u8,
        play_count: i32,
        length: f64,
        score: f64,
        url: []const u8,
        aliased: bool,
        track_num: i32,
        hidden: bool,
        holiday: bool,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
        },
    },
);
