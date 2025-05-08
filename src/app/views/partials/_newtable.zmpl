@args T: type, table_data: *ZmplValue, columns: T

<table>
<thead>
<tr>
@zig {
    for (columns) |header| {
        switch (header) {
            .song => {
                <th>Song</th>
            },
            .album => {
                <th>Album</th>
            },
            .artist => {
                <th>Artist</th>
            },
            .artistlist => {
                <th>Artist(s)</th>
            },
            .scrobbles => {
                <th>Scrobbles</th>
            },
            .date => {
                <th>Date</th>
            }
        }
    }
}
</tr>
</thead>
<tbody>
@zig {
    const array = table_data.items(.array);
    for (array) |ent| {
        <tr>
        for (columns) |header| {
            switch (header) {
                .song, .album, .artist => {
                    const path = switch (header) {
                        .song => "songs",
                        .album => "albums",
                        .artist => "artists",
                        else => unreachable
                    };
                    <td class=cell>
                    <a href="/{{path}}/{{ent.id}}">{{ent.name}}</a>
                    </td>
                },
                .artistlist => {
                    <td class=cell>
                    @for (ent.get("artist_info").?) |artist| {
                        <a href="/artists/{{artist.id}}">{{artist.name}}</a>
                    }
                    </td>
                },
                .scrobbles => {
                    <td class=cell>{{ent.scrobbles}}</td>
                },
                .date =>{
                    <td class=cell>{{ent.date}}</td>
                }
            }
        }
        </tr>
    }
}
</tbody>
</table>