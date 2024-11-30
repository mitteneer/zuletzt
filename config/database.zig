pub const database = .{
    .testing = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "postgres",
        .database = "zuletzt_testing",
        .pool_size = 16,
    },

    .development = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "postgres",
        .database = "zuletzt_dev",
        .pool_size = 16,
    },

    .production = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "postgres",
        .database = "zuletzt",
        .pool_size = 16,
    },
};
