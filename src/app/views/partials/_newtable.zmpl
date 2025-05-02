@args table_data *ZmplValue, table_headers: []enum{Song, Album, Artist, Scrobbles, Date}

<table>
<thead>
<tr>
@zig {
    for (table_headers) |header| {
        switch (header) {
            .Artist => {
                <th>Artist(s)</th>
            },
            inline else => |other| {
                const h = @tagName(other);
                <th>{{h}}</th>
            },
        }
    }
}
</tr>
</thead>
<tbody>
@zig {
    for (table_data) |data| {
        <tr>
        for (table_header) |header| {
            switch (header) {
                .Song => {
                    <td class=cell>
                    <a href="/songs/{{data.id}}">{{data.name}}</a>
                    </td>
                },
                .Album => {
                    <td class=cell>
                    <a href="/albums/{{data.id}}">{{data.name}}</a>
                    </td>
                },
                .Artist => {
                    <td class=cell>
                    @for (data.get("artist_info").?) |ai| {
                        <a href="/artists/{{ai.id}}">{{ai.name}}</a>
                    }
                    </td>
                },
                .Scrobbles => {
                    <td class=cell>{{data.scrobbles}}</td>
                },
                .Date =>{
                    <td class=cell>{{data.date}}</td>
                }
            };
        }
    }
}
</tbody>
</table>