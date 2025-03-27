<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="styles.css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Albums</h1>
<table id="myTable">
<thead>
<tr>
<th>Name</th>
<th>Artist(s)</th>
<th>Scrobbles</th>
</tr>
</thead>
</tbody>
@for (.albums) |album| {
  <tr>
  <td class=cell><a href="/albums/{{album.url}}">{{album.name}}</a></td>
  <td class=cell>
  @for (album.get("artist_info").?) |ai| {
    <a href="/artists/{{ai.id}}">{{ai.name}}</a>
  }
  </td>
  <td class=cell>{{album.scrobbles}}</td>
  </tr>
}
</tbody>
</table>
<script src="https://cdn.jsdelivr.net/npm/simple-datatables@latest" type="text/javascript"></script>
<script>
    const dataTable = new simpleDatatables.DataTable("#myTable", {
        searchable: false,
        perPage: 50,
        perPageSelect: [25,50,100],
    });
</script>
</body>
</html>