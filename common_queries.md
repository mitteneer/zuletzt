Get all albums from specified artist:
```sql
SELECT artists.name, albums.name
FROM "Albumartists"
INNER JOIN artists
ON "Albumartists".artist_id = artists.id
INNER JOIN albums
ON "Albumartists".album_id = albums.id
WHERE artists.name = {ARTIST};
```

Get all songs from specified artist:
```sql
SELECT artists.name, songs.name
FROM "Songartists"
INNER JOIN artists
ON "Songartists".artist_id = artists.id
INNER JOIN songs 
ON "Songartists".song_id = songs.id
WHERE artists.name = {ARTIST};
```

Get all songs from any album of the specified name:
```sql
SELECT songs.name
FROM "Albumsongs"
INNER JOIN albums
ON "Albumsongs".album_id = albums.id
INNER JOIN songs
ON "Albumsongs".song_id = songs.id
WHERE albums.name = {ALBUM};
```

Sort all songs by plays (does not list artist or album):
```sql
SELECT songs.name, COUNT(scrobbles.song_id) AS scount
FROM songs, scrobbles
WHERE songs.id = scrobbles.song_id
GROUP BY songs.id
ORDER BY scount DESC;
```

Sort all songs by plays, and include artist:
```sql
SELECT songs.name, artists.name, COUNT(scrobbles.song_id) AS scount
FROM scrobbles, "Songartists"
INNER JOIN artists
ON "Songartists".artist_id = artists.id
INNER JOIN songs
ON "Songartists".song_id = songs.id
WHERE songs.id = scrobbles.song_id
GROUP BY songs.id, artists.id
ORDER BY scount DESC;
```

Sort all songs by plays, and include artist and album:
```sql
SELECT songs.name, artists.name, albums.name, COUNT(scrobbles.song_id) AS scount
FROM scrobbles CROSS JOIN "Songartists" CROSS JOIN "Albumsongs"
INNER JOIN artists
ON "Songartists".artist_id = artists.id
INNER JOIN songs
ON "Songartists".song_id = songs.id AND "Albumsongs".song_id = songs.id
INNER JOIN albums
ON "Albumsongs".album_id = albums.id
WHERE songs.id = scrobbles.song_id
GROUP BY songs.id, artists.id, albums.id
ORDER BY scount DESC;
```

Sort all albums by plays, and include artist:
```sql
SELECT albums.name, artists.name, COUNT(scrobbles.album_id) AS scount
FROM scrobbles, "Albumartists"
INNER JOIN albums
ON "Albumartists".album_id = albums.id
INNER JOIN artists
ON "Albumartists".artist_id = artists.id
WHERE albums.id = scrobbles.album_id
GROUP BY artists.id, albums.id
ORDER BY scount DESC;
```

Sort all artists by plays:
```sql
SELECT artists.name, COUNT(scrobbles.id) AS scount
FROM artists, "Scrobbleartists"
INNER JOIN scrobbles
ON scrobbles.id = "Scrobbleartists".scrobble_id
WHERE "Scrobbleartists".artist_id = artists.id
GROUP BY artists.id
ORDER BY scount DESC;
```

Sort all artists by alphabetical order, and include the first time you listened to that artist:
```sql
SELECT artists.name, MIN(scrobbles.date)
FROM "Scrobbleartists"
INNER JOIN artists
ON "Scrobbleartists".artist_id = artists.id
INNER JOIN scrobbles
ON "Scrobbleartists".scrobble_id = scrobbles.id
GROUP BY artists.id
ORDER BY artists.name ASC;
```

Sort all songs by alphabetical order, and include the first time you listened to that song:
```sql
SELECT songs.name, MIN(scrobbles.date)
FROM scrobbles
INNER JOIN songs
ON scrobbles.song_id = songs.id
GROUP BY songs.id
ORDER BY songs.name ASC;
```

Sort all albums by alphabetical order, and include the first time you listened to that album:
```sql
SELECT albums.name, MIN(scrobbles.date)
FROM scrobbles
INNER JOIN albums
ON scrobbles.album_id = albums.id
GROUP BY albums.id
ORDER BY albums.name ASC;
```

Select all songs by specified artists, include the number of plays of each song, and sort by plays:
```sql
SELECT songs.name, COUNT(scrobbles.song_id) as count
FROM songs, "Scrobbleartists"
INNER JOIN artists
ON "Scrobbleartists".artist_id = artists.id
INNER JOIN scrobbles
ON "Scrobbleartists".scrobble_id = scrobbles.id
WHERE songs.id = scrobbles.song_id AND artists.name = {ARTIST}
GROUP BY songs.id
ORDER BY count DESC;
```

Select all albums by specified artist, include the number of plays of each album, and sort by plays:
```sql
SELECT albums.name, COUNT(scrobbles.song_id) as count
FROM albums, "Scrobbleartists"
INNER JOIN artists
ON "Scrobbleartists".artist_id = artists.id
INNER JOIN scrobbles
ON "Scrobbleartists".scrobble_id = scrobbles.id
WHERE albums.id = scrobbles.album_id AND artists.name = {ARTIST}
GROUP BY albums.id
ORDER BY count DESC;
```

Select all songs from an album specified by an ID, and sort by plays
```sql
SELECT songs.name, COUNT(scrobbles.song_id) AS count
FROM "Albumsongs"
INNER JOIN songs
ON songs.id = "Albumsongs".song_id
INNER JOIN scrobbles
ON scrobbles.song_id = "Albumsongs".song_id
WHERE "Albumsongs".album_id = {ALBUM_ID}
GROUP BY songs.id
ORDER BY count DESC;
```