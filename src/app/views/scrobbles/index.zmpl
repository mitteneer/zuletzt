<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" type="text/css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Scrobbles</h1>
<table id="myTable">
<thead>
<tr>
<th>Song</th>
<th>Album</th>
<th>Date</th>
</tr>
</thead>
<tbody>
@for (.scrobbles) |scrobble| {
  <tr>
  <td class=cell><a href="/songs/{{scrobble.song_id}}">{{scrobble.song_name}}</a></td>
  <td class=cell><a href="/albums/{{scrobble.album_id}}">{{scrobble.album_name}}</a></td>
  <td class=cell>{{scrobble.date}}</td>
  </tr>
}
</tbody>
</table>
<script src="https://cdn.jsdelivr.net/npm/simple-datatables@latest" type="text/javascript"></script>
<script>
    const dataTable = new simpleDatatables.DataTable("#myTable", {
        searchable: true,
        perPage: 50,
        perPageSelect: [25,50,100],
    });
</script>
</body>
</html>