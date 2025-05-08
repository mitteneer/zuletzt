@zig {
  const ColumnChoices = []const enum{song, album, artist, artistlist, scrobbles, date};
  const columns: ColumnChoices = &.{.song, .scrobbles};
}

<html>
<head>
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>{{.album}}</h1>
@partial partials/newtable(T: ColumnChoices, table_data: .songs, columns: columns)
</body>
</html>