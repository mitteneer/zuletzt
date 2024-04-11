pub const addArtist = \\INSERT INTO artists ('artist', 'plays', 'url') VALUES (?,?)
;

pub const addTrack = \\INSERT INTO tracks ('artist', 'track', 'album', 'plays', 'url') VALUES (?,?,?,?)
;

pub const getArtist = \\SELECT artist, plays FROM artists WHERE artist == ?
;

pub const getTrack = \\SELECT artist, track, album, plays FROM tracks WHERE track == ?
;

pub const getTrackSearch = \\SELECT track, url, form FROM tracks WHERE track LIKE '%' || ? || '%'
;

pub const getArtistSearch = \\SELECT artist, url, form FROM artists WHERE artist LIKE '%' || ? || '%'
;

pub const getAlbumSearch = \\SELECT album, url, form FROM albums WHERE album LIKE '%' || ? || '%'
;

pub const total_search = getArtistSearch ++ " UNION " ++ getAlbumSearch ++ " UNION " ++ getTrackSearch;