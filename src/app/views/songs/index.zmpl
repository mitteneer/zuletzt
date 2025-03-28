<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" type="text/css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Songs</h1>
<table id="myTable">
<thead>
<tr>
<th>Name</th>
<th>Artists(s)</th>
<th>Scrobbles</th>
</tr>
</thead>
<tbody>
@for (.songs) |song| {
  <tr>
  <td class=cell><a href="/songs/{{song.url}}">{{song.name}}</a></td>
  <td class=cell>
  @for (song.get("artist_info").?) |ai| {
    <a href="/artists/{{ai.id}}">{{ai.name}}</a>
  }
  </td>
  <td class=cell>{{song.scrobbles}}</td>
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