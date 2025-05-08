@args scrobbles: i64, rank: []const u8, last_song: *ZmplValue, first_song: *ZmplValue

<div>
{{scrobbles}} scrobbles ({{rank}} place)
<br>
First listen: <a href="/songs/{{first_song.id}}">{{first_song.name}}</a> ({{first_song.date}})
<br>
Most recent listen: <a href="/songs/{{last_song.id}}">{{last_song.name}}</a> ({{last_song.date}})
</div>