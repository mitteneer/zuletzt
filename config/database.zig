pub const database = .{
    .testing = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "postgres",
        .database = "zuletzt_testing",
    },

    .development = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "postgres",
        .database = "zuletzt_dev",
    },

    .production = .{
        .adapter = .postgresql,
        .hostname = "localhost",
        .port = 5432,
        .username = "postgres",
        .password = "postgres",
        .database = "zuletzt",
    },
};
