@zig {
  const ColumnChoices = []const enum{song, album, artist, artistlist, scrobbles, date};
  const columns: ColumnChoices = &.{.album, .artistlist, .scrobbles};
}

<html>
<head>
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Albums</h1>
@partial partials/newtable(T: ColumnChoices, table_data: .albums, columns: columns)
</body>
</html>