<html>
<head>
<link rel="stylesheet" href="styles.css">
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Albums</h1>
<table>
<tr>
<th>Name</th>
@for (.albums) |album| {
  <tr>
  <td class=cell><a href="/albums/{{album.url}}">{{album.name}}</a></td>
  </tr>
}
</table>
</body>
</html>