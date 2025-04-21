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
If
<select name="match-on" id="match-on">
<option value="artist">artist</option>
<option value="album">album</option>
<option value="track">song</option>
</select>
<select name="match-cond" id="match-cond">
<option value="is">is</option>
<option value="contains">contains</option>
<option value="matches">matches regex</option>
</select>
<input type="text" name="match-txt" id="match-txt">
<label for="case-sens">Toggle case sensitivity</label>
<input type="checkbox" name="case-sens" id="case-sens">
<label for="accent-sens">Toggle diacritic sensitivity</label>
<input type="checkbox" name="accent-sens" id="accent-sens">
<button type="button" onclick="condAdd()">
        Add Conditional
</button>

<script>
function condAdd() {
  const sep = document.getElementById("cond-ins");
  const wrapper = document.createElement("div");
  const cond = document.createElement("select");
  const match_on = document.createElement("select");
  const match_cond = document.createElement("select");
  const match_txt = document.createElement("input");

  const or_opt = document.createElement("option")
  or_opt.value = "or";
  or_opt.innerHTML = "or";
  const and_opt = document.createElement("option")
  and_opt.value = "and";
  and_opt.innerHTML = "and";
  const artist_opt = document.createElement("option")
  artist_opt.value = "artist";
  artist_opt.innerHTML = "artist";
  const album_opt = document.createElement("option")
  album_opt.value = "album"
  album_opt.innerHTML = "album"
  const song_opt = document.createElement("option")
  song_opt.value = "song";
  song_opt.innerHTML = "song";
  const is_opt = document.createElement("option")
  is_opt.value = "is";
  is_opt.innerHTML = "is";
  const contains_opt = document.createElement("option")
  contains_opt.value = "contains"
  contains_opt.innerHTML = "contains"

  match_txt.setAttribute("type","text");
  
  cond.appendChild(or_opt);
  cond.appendChild(and_opt);
  match_on.appendChild(artist_opt);
  match_on.appendChild(album_opt);
  match_on.appendChild(song_opt);
  match_cond.appendChild(is_opt);
  match_cond.appendChild(contains_opt);
  
  wrapper.appendChild(cond);
  wrapper.appendChild(match_on);
  wrapper.appendChild(match_cond);
  wrapper.appendChild(match_txt);
  
  sep.appendChild(wrapper);
}
</script>

<div id="cond-ins"></div>
then
<select name="action" id="action">
<option value="replace">replace</option>
<option value="add">add</option>
</select>
<select name="action-on" id="action-on">
<option value="artist">artist</option>
<option value="album">album</option>
<option value="track">song</option>
</select>
with
<input type="text" name="action-txt" id="action-txt">
<button type="submit" value="Submit">Submit</button>
</form>

Current rules:

</html>