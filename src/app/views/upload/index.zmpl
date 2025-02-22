<html>
<head>
<link rel="stylesheet" href="styles.css">
</head>
<body>
@partial partials/header
<div>
  <span>Upload Last.fm or Spotify history file here (in json format).</span>
</div>
<form action="/upload" enctype="multipart/form-data" method="POST">
  <label>Filename</label>
  <input type="text" name="description" />
  <label>File</label>
  <input type="file" name="upload" />
  <input type="submit" value="Submit" />
  <fieldset>
  <input type="radio" name="t" label="Last.fm" value="0">Last.fm</input>
  <input type="radio" name="t" label="Spotify" value="1">Spotify</input>
  Upload Scrobbles after: <input type="datetime-local" name="l" label="date"></input>
  </fieldset>
</form>
</body>
</html>