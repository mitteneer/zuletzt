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
            .albumsongs = jetquery.hasMany(.Albumsong, .{}),
            .artistalbums = jetquery.hasMany(.Artistalbum, .{}),
        },
    },
);

pub const Albumsong = jetquery.Model(
    @This(),
    "albumsongs",
    struct {
        id: i32,
        song_id: i32,
        album_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .song = jetquery.belongsTo(.Song, .{}),
            .album = jetquery.belongsTo(.Album, .{}),
            .scrobbles = jetquery.hasMany(.Scrobble, .{
                .foreign_key = "albumsong",
            }),
            .albumsongsartists = jetquery.hasMany(.Albumsongsartist, .{}),
        },
    },
);

pub const Albumsongsartist = jetquery.Model(
    @This(),
    "albumsongsartists",
    struct {
        id: i32,
        albumsong_id: i32,
        artist_id: i32,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .albumsong = jetquery.belongsTo(.Albumsong, .{}),
            .artist = jetquery.belongsTo(.Artist, .{}),
        },
    },
);

pub const Artistalbum = jetquery.Model(
    @This(),
    "artistalbums",
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

pub const Artist = jetquery.Model(
    @This(),
    "artists",
    struct {
        id: i32,
        name: []const u8,
        disambiguation: ?[]const u8,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .albumsongsartists = jetquery.hasMany(.Albumsongsartist, .{}),
            .artistalbums = jetquery.hasMany(.Artistalbum, .{}),
        },
    },
);

pub const Scrobble = jetquery.Model(
    @This(),
    "scrobbles",
    struct {
        id: i32,
        albumsong: i32,
        datetime: jetquery.DateTime,
        created_at: jetquery.DateTime,
        updated_at: jetquery.DateTime,
    },
    .{
        .relations = .{
            .albumsong = jetquery.belongsTo(.Albumsong, .{
                .foreign_key = "albumsong",
            }),
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
            .albumsongs = jetquery.hasMany(.Albumsong, .{}),
        },
    },
);
