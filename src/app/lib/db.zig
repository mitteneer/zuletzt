pub const addArtist = \\INSERT INTO artists ('artist', 'plays', 'url') VALUES (?,?)
;

pub const addTrack = \\INSERT INTO tracks ('artist', 'track', 'album', 'plays', 'url') VALUES (?,?,?,?)
;

pub const getArtist = \\SELECT artist, plays FROM artists WHERE artist == ?
;

pub const getTrack = \\SELECT artist, track, album, plays FROM tracks WHERE track == ?
;

pub const getTrackSearch = \\SELECT url FROM artists WHERE artist == ?
;

pub const getArtistSearch = \\SELECT artist, url FROM artists WHERE artist LIKE '%' || ? || '%'
;