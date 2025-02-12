@args table_data: *ZmplValue, table_headers: *ZmplValue

<table>
<tr>
@for (table_headers) |text| {
    <th>{{text}}</th>
}
</tr>

    @for (table_data) |value| {
    <tr>
       <td class=cell>{{value.track}}</td> 
       <td class=cell>{{value.artist}}</td> 
       <td class=cell>{{value.album}}</td> 
       <td class=cell>{{value.date}}</td> 
    </tr>
    }
</table>