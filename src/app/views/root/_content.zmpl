<!--// Renders the `message` response data value.-->
@args message: *ZmplValue
<h3 class="message text-[#39b54a]">{{message}}</h3>

<div><img class="p-3 mx-auto" src="/jetzig.png" /></div>

<div>
  <a href="https://github.com/jetzig-framework/zmpl">
    <img class="p-3 m-3 mx-auto" src="/zmpl.png" />
  </a>

</div>

<div>Visit <a class="font-bold text-[#39b54a]" href="https://jetzig.dev/">jetzig.dev</a> to get started.
  <div>Join our Discord server and introduce yourself:</div>
  <div>
    <a class="font-bold text-[#39b54a]">Search for an artist, album, or song:</a>
    <input type="text" name="search" hx-include="[name='search']" hx-get="/test" hx-trigger="keyup[keyCode==13]">
    <button type="button" hx-include="[name='search']" hx-get="/test">Yo whattup</button>  
  </div>
</div>
