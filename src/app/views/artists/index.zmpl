<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" type="text/css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Artists</h1>
<table id="myTable" class='table'>
<thead>
<tr>
<th>Name</th>
<th>Scrobbles</th>
</tr>
</thead>
<tbody>
@for (.artists) |artist| {
  <tr>
  <td class=cell><a href="/artists/{{artist.url}}">{{artist.name}}</a></td>
  <td class=cell>{{artist.scrobbles}}</td>
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