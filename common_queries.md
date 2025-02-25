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
