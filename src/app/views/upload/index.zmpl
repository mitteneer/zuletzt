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
  <input type="radio" name="t" label="Last.fm" value="0" required>Last.fm</input>
  <input type="radio" name="t" label="Spotify" value="1" required>Spotify</input>
  <input type="checkbox" name="bbool" id="bbool" value="false" onclick="document.getElementById('abool').setAttribute('required', 'required')"></input>Limit to Scrobbles before: <input type="datetime-local" name="b" label="date-before"></input>
  <input type="checkbox" name="abool" id="abool" value="false" onclick="document.getElementById('bbool').setAttribute('required', 'required')"></input>Limit to Scrobbles after: <input type="datetime-local" name="a" label="date-after"></input>
  </fieldset>
</form>
</body>
</html>