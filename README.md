# Zuletzt
**Zuletzt** gives you the statistics of your music listening habits.

Inspired by [Last.fm](https://last.fm), [Maloja](https://github.com/krateng/maloja), and [Lastfmstats.com](https://www.lastfmstats.com).


**Z**uletzt is written with [**Z**ig](https://github.com/ziglang/zig) and [Jetzig](https://github.com/jetzig-framework/jetzig) as a means of learning the
language, reintroducing myself to programming, and combining
the functionality of the aforementioned inspirations.

Zuletzt means "last" in German.

Licensed under MIT.

## To-Do List:
- [ ] Entity statistics
    - [x] See all artists under "/artists"
        - [ ] List all songs on artist page, with respective album
        - [x] List all albums on artist page
        - [x] Include number of plays for each
    - [x] See all albums under "/albums"
        - [x] See all songs from album
        - [ ] Include number of plays
    - [x] See all songs under "/songs"
        - [ ] Include respective artist(s)
        - [ ] Include respective album[^10]
        - [ ] Inclue number of plays
    - [ ] Create disambiguation pages
        - [ ] Artists
        - [ ] Albums
        - [ ] Songs
    - [ ] Toggleable default sorting method
        - [ ] Default to sorting by plays
    - [ ] Filter by dates
    - [ ] Highlight specific high-performing entities
- [ ] Lastfmstats.com statistics[^1]
- [ ] Collections
    - [ ] Import from Discogs[^2]
- [ ] Import listening history
    - [x] From Lastfmstats.com (.json file)[^3]
    - [ ] From Last.fm (authentication)
    - [x] From Spotify (.json file)
    - [ ] From other streaming services[^4]
    - [ ] "Unofficial scrobbles"[^9]
    - [ ] Import rules
        - [ ] Simple find/replace
        - [ ] User-defined regex
- [ ] Tags
    - [ ] Genres
    - [ ] Owned
    - [ ] Holiday
- [ ] MusicBrainz integration
- [ ] Concerts
    - [ ] Import from Setlist.fm[^5]
- [ ] Ratings
    - [ ] RYM integration[^6]
    - [ ] Rank songs
- [ ] Custom statistics[^7]
- [ ] "Playlists"[^8]

[^1]: I do not intend to exactly replicate all the statistics Lastfmstats.com provides, but I would at least like to give the user the option to see those kinds of statistics, or generate them themselves (see 7).

[^2]: I do not intend to provide the level of granularity that Discogs provides, but a simple toggle that means "I own some version of this release" is all that is necessary.

[^3]: I have not investigated any other service for downloading your listening history from Last.fm, but providing the listening history as a JSON rather than a CSV is highly preferred. I may eventually provide my own way of downloading Last.fm data as a JSON, but I would prefer to allow users to enter their username, or authenticate, and avoid needing to upload a file altogether.

[^4]: I only intend to allow imports from Last.fm and Spotify at the moment because those are the only data sources I currently rely on. To that extent, I imagine I could import from other sources as well fairly easily, although I do not know what their data dumps look like.

[^5]: I only intend to allow imports from Setlist.fm at the moment because that is the only data source I currently rely on.

[^6]: RYM has the most data, and once it has an API, will be the only user-driven review site that *has* an API. In this context, "integration" simply means displaying the critic score and user score next to the album. You will be able to write reviews and ranks songs/albums(/artists?), but not for them to be published to RYM.

[^7]: I envision something akin to the Custom Reports from [Actual Budget](https://github.com/actualbudget/actual) that will allow users to create their own ways of rating/ranking songs/albums, and view their listening habits.

[^8]: Misleading title, but same functionality as "Lists" on AlbumOfTheYear, although I would like to allow albums and songs to appear on the same list.

[^9]: This is a working title, but I have sources (iPods) that provide a play count, but no play dates, so I can't list them among my usual Scrobbles. However, I would still like to display that information along with everything else, so I would like to provide a way of entering this data into a separate category that can be toggled to display alongside "official" Scrobbles.

[^10]: Would probably select the album with the most scrobbles

## Contributing
I am a math student who is interested in programming. I will not be writing quality code. That said, Zuletzt is something that, at the moment, I am very excited about making, and using to relearn some things about programming. Unless contributions are given in the form of code review, or some kind of constructive criticism, it's not likely that I accept pull requests. The project is, however, licensed under the MIT License, so feel free to do what you like with it in your own way.
