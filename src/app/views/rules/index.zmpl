<html>
<head>
<meta charset="UTF-8">
</head>
<body>
@partial partials/header
<h1>Rules</h1>
Rules allow you change the default Scrobble import behavior based on provided criteria.
Add a rule below.
<br><br>
<form action="/rules" enctype="multipart/form-data" method="POST">
<label for="rule-title">Rule Name:</label>
<input type="text" name="rule-title" id="rule-title">
<br>
Match
<select name="cond-req" id="cond-req">
  <option value="any">any</option>
  <option value="all">all</option>
</select>
conditonals.
<br>
If
@for (0..5) |i| {
  <select name="match-on{{i}}" id="match-on{{i}}">
    <option value="artist">artist</option>
    <option value="album">album</option>
    <option value="track">song</option>
  </select>
  <select name="match-cond{{i}}" id="match-cond{{i}}">
    <option value="is">is</option>
    <option value="contains">contains</option>
    <option value="matches">matches regex</option>
  </select>
  <input type="text" name="match-txt{{i}}" id="match-txt{{i}}">
  <label for="case-sens">Toggle case sensitivity</label>
  <input type="checkbox" name="case-sens{{i}}" id="case-sens{{i}}">
  <label for="accent-sens">Toggle diacritic sensitivity</label>
  <input type="checkbox" name="accent-sens{{i}}" id="accent-sens{{i}}">
  <br>
}
then
@for (0..5) |i| {
  <select name="action{{i}}" id="action{{i}}">
    <option value="replace">replace</option>
    <option value="add">add</option>
  </select>
  <select name="action-on{{i}}" id="action-on{{i}}">
    <option value="artists_track">artist (song)</option>
    <option value="artists_album">artist (album)</option>
    <option value="album">album</option>
    <option value="track">song</option>
  </select>
  with
  <input type="text" name="action-txt{{i}}" id="action-txt{{i}}">
  <br>
}
<button type="submit" value="Submit">Submit</button>
</form>

Current rules:

</html>