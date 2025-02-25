<html>
<head>
<link rel="stylesheet" href="styles.css">
</head>
<body>
@partial partials/header
<div>
  <span>Look for an artist</span>
</div>
<form action="/scrobbles" method"GET">
  <label>Filename</label>
  <input type="text" name="ar" />
  <input type="submit" value="Submit" />
</form>
</body>
</html>
