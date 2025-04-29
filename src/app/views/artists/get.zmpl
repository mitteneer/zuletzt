<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css" rel="stylesheet" type="text/css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>{{.artist.name}}</h1>
{{.artist.scrobbles}} scrobbles ({{.artist.rank}} place)
<br>
First listen: <a href="/songs/{{.first_song_id}}">{{.first_song_name}}</a> ({{.first_song_date}})
<br>
Most recent listen: <a href="/songs/{{.last_song_id}}">{{.last_song_name}}</a> ({{.last_song_date}})
<h2>Albums</h2>
<table id="myTable">
<thead>
<tr>
<th>Name</th><th>Scrobbles</th>
</tr>
</thead>
<tbody>
@for (.albums) |album| {
  <tr>
  <td class=cell><a href="/albums/{{album.id}}">{{album.name}}</a></td>
  <td class=cell>{{album.scrobbles}}</td>
  </tr>
}
</tbody>
</table>
<h2>Albums Featured On</h2>
<table id="myTable">
  <thead>
    <tr>
      <th>Name</th><th>Scrobbles</th>
    </tr>
  </thead>
  <tbody>
    @for (.appears) |album| {
      <tr>
        <td class=cell><a href="/albums/{{album.id}}">{{album.name}}</a></td>
        <td class=cell>{{album.scrobbles}}</td>
      </tr>
    }
  </tbody>
    <table>
<script src="https://cdn.jsdelivr.net/npm/simple-datatables@latest" type="text/javascript"></script>
<script>
    const dataTable = new simpleDatatables.DataTable("#myTable", {
        searchable: false,
    });
</script>
</body>
</html>