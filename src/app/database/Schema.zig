const jetquery = @import("jetzig").jetquery;

pub const Album = jetquery.Model(
    @This(),
    "albums",
    struct {
        id: i32,
        name: []const u8,
        length: ?f32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .masteralbum = jetquery.belongsTo(.Masteralbum, .{}),
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
            .ratings = jetquery.hasMany(.Rating, .{}),
            .aliases = jetquery.hasMany(.Alias, .{}),
            .albumsongs = jetquery.hasMany(.Albumsong, .{}),
            .albumartists = jetquery.hasMany(.Albumartist, .{}),
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

pub const Artist = jetquery.Model(
    @This(),
    "artists",
    struct {
        id: i32,
        name: []const u8,
        descriptive_string: []const u8,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobbleartists = jetquery.hasMany(.Scrobbleartist, .{}),
            .aliases = jetquery.hasMany(.Alias, .{}),
            .artistsongs = jetquery.hasMany(.Songartist, .{}),
            .mastersongs = jetquery.hasMany(.Mastersong, .{}),
            .artistalbums = jetquery.hasMany(.Albumartist, .{}),
            .masteralbums = jetquery.hasMany(.Masteralbum, .{}),
        },
    },
);

pub const Masteralbum = jetquery.Model(
    @This(),
    "masteralbums",
    struct {
        id: i32,
        name: []const u8,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .albums = jetquery.hasMany(.Album, .{}),
        },
    },
);

pub const Mastersong = jetquery.Model(
    @This(),
    "mastersongs",
    struct {
        id: i32,
        name: []const u8,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .songs = jetquery.hasMany(.Song, .{}),
        },
    },
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
    .{
        .relations = .{
            .song = jetquery.belongsTo(.Song, .{}),
            .album = jetquery.belongsTo(.Album, .{}),
            .artist = jetquery.belongsTo(.Artist, .{}),
        },
    },
);

pub const Scrobble = jetquery.Model(
    @This(),
    "scrobbles",
    struct {
        id: i32,
        song_id: i32,
        album_id: ?i32,
        date: jetquery.DateTime,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .song = jetquery.belongsTo(.Song, .{}),
            .album = jetquery.belongsTo(.Album, .{}),
            .scrobbleartists = jetquery.hasMany(.Scrobbleartist, .{}),
        },
    },
);

pub const Song = jetquery.Model(
    @This(),
    "songs",
    struct {
        id: i32,
        name: []const u8,
        length: ?f32,
        hidden: bool,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .mastersong = jetquery.belongsTo(.Mastersong, .{}),
            .scrobbles = jetquery.hasMany(.Scrobble, .{}),
            .ratings = jetquery.hasMany(.Rating, .{}),
            .aliases = jetquery.hasMany(.Alias, .{}),
            .songartists = jetquery.hasMany(.Songartist, .{}),
            .albumsongs = jetquery.hasMany(.Albumsong, .{}),
        },
    },
);

pub const Albumartist = jetquery.Model(
    @This(),
    "Albumartists",
    struct {
        id: i32,
        album_id: i32,
        artist_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .album = jetquery.belongsTo(.Album, .{}),
            .artist = jetquery.belongsTo(.Artist, .{}),
        },
    },
);

pub const Songartist = jetquery.Model(
    @This(),
    "Songartists",
    struct {
        id: i32,
        song_id: i32,
        artist_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .song = jetquery.belongsTo(.Song, .{}),
            .artist = jetquery.belongsTo(.Artist, .{}),
        },
    },
);

pub const Albumsong = jetquery.Model(
    @This(),
    "Albumsongs",
    struct {
        id: i32,
        album_id: i32,
        song_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .album = jetquery.belongsTo(.Album, .{}),
            .song = jetquery.belongsTo(.Song, .{}),
        },
    },
);

pub const Scrobbleartist = jetquery.Model(
    @This(),
    "Scrobbleartists",
    struct {
        id: i32,
        scrobble_id: i32,
        artist_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .scrobble = jetquery.belongsTo(.Scrobble, .{}),
            .artist = jetquery.belongsTo(.Artist, .{}),
        },
    },
);
