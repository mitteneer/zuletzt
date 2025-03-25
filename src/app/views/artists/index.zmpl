<html>
<head>
<link rel="stylesheet" href="styles.css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1> Artists</h1>
<table>
<tr>
<th>Name</th>
@for (.artists) |artist| {
  <tr>
  <td class=cell><a href="/artists/{{artist.url}}">{{artist.name}}</a></td>
  <td class=cell>{{artist.scrobbles}}</td>
  </tr>
}
</table>
</body>
</html>