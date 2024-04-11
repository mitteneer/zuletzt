<table>
  <tr>
    <th>Artist</th>
    <th>Album</th>
    <th>Track</th>
  </tr>
  @zig ZIG
    for (zmpl.items(.array), 0..) |u,i| {
      if(@mod(i,2)==0){
      <tr>
        <td id="artistUpdate"><a href={{zmpl.items(.array)[i+1].string.value}}>{{u}}</a></td>
        <td id="albumUpdate">{{i}}</td>
        <td id="trackUpdate"></td>
      </tr>
      }
    }
    ZIG
</table>