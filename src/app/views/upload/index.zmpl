<html>
<body>
@partial partials/header
<div>
  <span>Upload Last.fm or Spotify history file here (in json format).</span>
</div>
<form action="/" enctype="multipart/form-data" method="POST">
  <label>Filename</label>
  <input type="text" name="description" />
  <label>File</label>
  <input type="file" name="upload" />
  <input type="submit" value="Submit" />
  <fieldset>
  <input type="radio" name="t" label="Last.fm">Last.fm</input>
  <input type="radio" name="t" label="Spotify">Spotify</input>
  </fieldset>
</form>
</body>
</html>