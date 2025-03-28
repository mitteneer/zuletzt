<html>
<head>
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>{{.album}}</h1>
<table>
<tr>
<th>Name</th>
@for (.songs) |song| {
  <tr>
  <td class=cell><a href="/songs/{{song.url}}">{{song.name}}</a></td>
  <td class=cell>{{song.scrobbles}}</td>
  </tr>
}
</table>
</body>
</html>