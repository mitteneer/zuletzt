<table>
  <tr>
    <th>Artist</th>
    <th>Album</th>
    <th>Track</th>
  </tr>
  @zig {
    for (zmpl.items(.array), 0..) |u,i| {
      if(@mod(i,3)==0){
      <tr>
        <td id={{zmpl.items(.array)[i+2].string.value}}><a href={{zmpl.items(.array)[i+1].string.value}}>{{u}}</a></td>
      </tr>
      }
    }
  }
</table>