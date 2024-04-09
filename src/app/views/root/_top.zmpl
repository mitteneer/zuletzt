@html {
<style>
#myHeader {  background-color: lightblue;  color: black;  padding: 40px;  text-align: center;}
</style>
}
<div>
<fieldset>
Top:
<input type="radio" label="Artist" name="q" value="artist" hx-get="/stats" hx-target="#update" hx-include="[name='t']" hx-swap="outerHTML" hx-trigger="click" checked>Artist</input>
<input type="radio" label="Album" name="q" value="album">Album</input>
<input type="radio" label="Track" name="q" value="track">Track</input>
</fieldset>

<fieldset>
of:
<input type="radio" label="Day" name="t" value="day" checked>Day</input>
<input type="radio" label="Week" name="t" value="week">Week</input>
<input type="radio" label="Month" name="t" value="month">Month</input>
<input type="radio" label="3 Months" name="t" value="quarter">3 Months</input>
<input type="radio" label="6 Months" name="t" value="half">6 Months</input>
<input type="radio" label="Current Year" name="t" value="begin">Current Year</input>
<input type="radio" label="365 Days" name="t" value="year">365 days</input>
<input type="radio" label="All Time" name="t" value="all">All Time</input>
</fieldset>

<tr>
<td colspan="3">
<b id="myHeader">hyello</b>
</td>
</tr>
</div>
