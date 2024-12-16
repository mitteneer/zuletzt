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
        length: f32,
        play_count: i32,
        holiday: bool,
        compilation: bool,
        deluxe: bool,
        live: bool,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
            .ratings = jetquery.hasMany(.Ratings, .{}),
            .aliases = jetquery.hasMany(.Aliases, .{}),
            .songs = jetquery.hasMany(.AlbumSongs, .{}),
            .artists = jetquery.hasMany(.ArtistAlbums, .{}),
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
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
            .aliases = jetquery.hasMany(.Aliases, .{}),
            .concerts = jetquery.hasMany(.Concerts, .{}),
            .songs = jetquery.hasMany(.ArtistSongs, .{}),
            .albums = jetquery.hasMany(.ArtistAlbums, .{}),
        },
    },
);

pub const Scrobble = jetquery.Model(
    @This(),
    "scrobbles",
    struct {
        id: i32,
        date: jetquery.DateTime,
        song_id: i32,
        album_id: ?i32,
        artist_id: i32,
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
        title: []const u8,
        length: f32,
        hidden: bool,
        holiday: bool,
        play_count: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
            .ratings = jetquery.hasMany(.Ratings, .{}),
            .aliases = jetquery.hasMany(.Aliases, .{}),
            .artists = jetquery.hasMany(.ArtistSongs, .{}),
            .albums = jetquery.hasMany(.AlbumSongs, .{}),
        },
    },
);

pub const Alias = jetquery.Model(
    @This(),
    "aliases",
    struct {
        id: i32,
        reference_id: i32,
        alias: []const u8,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);

pub const Concert = jetquery.Model(
    @This(),
    "concerts",
    struct {
        id: i32,
        location: []const u8,
        date: jetquery.DateTime,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);

pub const Rating = jetquery.Model(
    @This(),
    "ratings",
    struct {
        id: i32,
        reference_id: i32,
        score: f32,
        date: jetquery.DateTime,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);

pub const RawScrobble = jetquery.Model(
    @This(),
    "raw_scrobbles",
    struct {
        id: i32,
        track: []const u8,
        artist: []const u8,
        album: []const u8,
        date: jetquery.DateTime,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{},
);
