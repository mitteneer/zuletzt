@zig {
  const ColumnChoices = []const enum{song, album, artist, artistlist, scrobbles, date};
  const columns: ColumnChoices = &.{.album, .scrobbles};
}

<html>
<head>
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>{{.artist.name}}</h1>
@partial partials/firstlast_listens(scrobbles: .artist.scrobbles, rank: .artist.rank, last_song: .last, first_song: .first)

<h2>Albums</h2>
@partial partials/newtable(T: ColumnChoices, table_data: .albums, columns: columns)

<h2>Albums Featured On</h2>
@partial partials/newtable(T: ColumnChoices, table_data: .appears, columns: columns)

</body>
</html>