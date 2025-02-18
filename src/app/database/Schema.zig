const jetquery = @import("jetzig").jetquery;

pub const Album = jetquery.Model(@This(), "albums", struct {
    id: i32,
    name: []const u8,
    length: ?f32,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .scrobbles = jetquery.hasMany(.Scrobble, .{}),
    .ratings = jetquery.hasMany(.Rating, .{}),
    .aliases = jetquery.hasMany(.Alias, .{}),
    .songs = jetquery.hasMany(.Song, .{}),
    .artists = jetquery.hasMany(.Artist, .{}),
} });

pub const Alias = jetquery.Model(@This(), "aliases", struct {
    id: i32,
    reference_id: i32,
    alias: []const u8,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{});

pub const Artist = jetquery.Model(@This(), "artists", struct {
    id: i32,
    name: []const u8,
    descriptive_string: []const u8,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .scrobbles = jetquery.hasMany(.Scrobble, .{}),
    .aliases = jetquery.hasMany(.Alias, .{}),
    .songs = jetquery.hasMany(.Song, .{}),
    .albums = jetquery.hasMany(.Album, .{}),
} });

pub const Masteralbum = jetquery.Model(@This(), "masteralbums", struct {
    id: i32,
    name: []const u8,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .albums = jetquery.hasMany(.Album, .{}),
} });

pub const Mastersong = jetquery.Model(@This(), "mastersongs", struct {
    id: i32,
    name: []const u8,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .songs = jetquery.hasMany(.Song, .{}),
} });

pub const Rating = jetquery.Model(@This(), "ratings", struct {
    id: i32,
    reference_id: i32,
    score: f32,
    date: jetquery.DateTime,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .song = jetquery.belongsTo(.Song, .{}),
    .album = jetquery.belongsTo(.Album, .{}),
    .artist = jetquery.belongsTo(.Artist, .{}),
} });

pub const Scrobble = jetquery.Model(@This(), "scrobbles", struct {
    id: i32,
    song_id: i32,
    album_id: ?i32,
    date: jetquery.DateTime,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .song = jetquery.belongsTo(.Song, .{}),
    .album = jetquery.belongsTo(.Album, .{}),
    .artists = jetquery.hasMany(.Artist, .{}),
} });

pub const Song = jetquery.Model(@This(), "songs", struct {
    id: i32,
    name: []const u8,
    length: ?f32,
    hidden: bool,
    created_at: jetquery.DateTime,
    updated_at: jetquery.DateTime,
}, .{ .relations = .{
    .scrobbles = jetquery.hasMany(.Scrobble, .{}),
    .ratings = jetquery.hasMany(.Rating, .{}),
    .aliases = jetquery.hasMany(.Alias, .{}),
    .artists = jetquery.hasMany(.Artist, .{}),
    .albums = jetquery.hasMany(.Album, .{}),
} });
