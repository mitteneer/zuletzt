<div>
<fieldset>
Top:
<input type="radio" label="Artist" name="q" value="artist" hx-get="/stats" hx-target="#update" hx-include="[name='t']" hx-swap="outerHTML" hx-trigger="click" checked>Artist</input>
<input type="radio" label="Album" name="q" value="album" hx-get="/stats" hx-target="#update" hx-include="[name='t']" hx-swap="outerHTML" hx-trigger="click">Album</input>
<input type="radio" label="Track" name="q" value="track" hx-get="/stats" hx-target="#update" hx-include="[name='t']" hx-swap="outerHTML" hx-trigger="click">Track</input>
</fieldset>

<fieldset>
of:
<input type="radio" label="Day" name="t" value="day" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click" checked>Day</input>
<input type="radio" label="Week" name="t" value="week" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">Week</input>
<input type="radio" label="Month" name="t" value="month" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">Month</input>
<input type="radio" label="3 Months" name="t" value="quarter" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">3 Months</input>
<input type="radio" label="6 Months" name="t" value="half" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">6 Months</input>
<input type="radio" label="Current Year" name="t" value="begin" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">Current Year</input>
<input type="radio" label="365 Days" name="t" value="year" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">365 days</input>
<input type="radio" label="All Time" name="t" value="all" hx-get="/stats" hx-target="#update" hx-include="[name='q']" hx-swap="outerHTML" hx-trigger="click">All Time</input>
</fieldset>

<tr>
<td colspan="3">
<b id="update">hyello</b>
</td>
</tr>
</div>
