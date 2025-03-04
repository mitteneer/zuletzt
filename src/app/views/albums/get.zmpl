<html>
<head>
<link rel="stylesheet" href="styles.css">
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
  </tr>
}
</table>
</body>
</html>