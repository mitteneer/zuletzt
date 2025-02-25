> [!note] Notice
> Queries involving artists are likely inaccurate due to database structure and
> limitations of scrobbles. Specifics and fixes are being planned.

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
zuletzt_dev-# ORDER BY scount DESC;
```
