import{_ as l}from"./plugin-vue_export-helper-DlAUqK2U.js";import{r as a,o as s,c as o,a as e,b as n,d as i,e as d}from"./app-DlOHg9Xr.js";const r={},c=e("h1",{id:"rust-development-setup-installation",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#rust-development-setup-installation"},[e("span",null,"Rust Development Setup Installation")])],-1),u=e("h3",{id:"follow-the-sui-installation",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#follow-the-sui-installation"},[e("span",null,"Follow the Sui installation")])],-1),p={href:"https://docs.sui.io/build/install#prerequisites",target:"_blank",rel:"noopener noreferrer"},m=e("h3",{id:"clone-dtp",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#clone-dtp"},[e("span",null,"Clone DTP")])],-1),h={href:"https://github.com/mario4tier/dtp",target:"_blank",rel:"noopener noreferrer"},v=d(`<h3 id="initialize-localnet" tabindex="-1"><a class="header-anchor" href="#initialize-localnet"><span>Initialize localnet</span></a></h3><p>Just run the DTP &quot;init-localnet&quot; and it will initialize the whole DTP setup and (re)start the &quot;sui&quot; localnet process as needed.</p><p>The localnet will be re-initialized with always the same configuration, address and funding. (it uses its own configuration file at genesis for a deterministic setup).</p><p>From this point use &quot;lsui&quot; and &quot;dsui&quot; shell scripts (as a direct replacement of &quot;sui&quot;) to access localnet and devnet respectively.</p><p>Output example:</p><div class="language-text line-numbers-mode" data-ext="text" data-title="text"><pre class="language-text"><code>~/dtp$ ./dtp/script/init-localnet
Output location = /home/user/dtp-dev
Stopping running localnet (sui process pid 1317)
Building localnet using latest Sui devnet branch...
    Finished dev [unoptimized + debuginfo] target(s) in 1.29s
Removing existing /home/user/dtp-dev/localnet directory
Starting new localnet process (may take up to 30 secs)
.........
New localnet started (sui 0.20.0, process pid 6798)
========
localnet =&gt; http://0.0.0.0:9000 (active)
devnet =&gt; https://fullnode.devnet.sui.io:443
========
All addresses with coins:
Showing 5 results.
0x267d4904898cbc15f165a18541154ec8c5732fcb
0x68db58b41d97e4cf1ea7d9327036ebd306a7930a
0x99d821380348ee02dd685a3af6d7123d92db0d3c
0xbbd8d0695c369b04e9207fca4ef9f5f15b2c0de7
0xe7f134729591f52cf0638c2500a7ed228033a9e7
========
All coins owned by 0xe7f134729591f52cf0638c2500a7ed228033a9e7 (active):
                 Object ID                  |  Gas Value
----------------------------------------------------------------------
 0x0b162ef4f83118cc0ad811de35ed330ec3441d7b | 100000000000000
 0x2d43245a6af1f65847f7c18d5f6aabbd8e11299b | 100000000000000
 0x9811c29f1dadb67aadcd59c75693b4a91b347fbb | 100000000000000
 0xc8381677d3c213f9b0e9ef3d2d14051458b6af8a | 100000000000000
 0xd0b2b2227244707bce233d13bf537af7a6710c01 | 100000000000000
========

Remember:
  Use &quot;dsui&quot; to access devnet
  Use &quot;lsui&quot; to access your localnet

Success. Try it by typing &quot;lsui client gas&quot;
host:~/$
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div><h3 id="publish-dtp-package-localnet" tabindex="-1"><a class="header-anchor" href="#publish-dtp-package-localnet"><span>Publish DTP Package (localnet)</span></a></h3><p>~/dtp$ publish-localnet</p><h3 id="run-dtp-integration-test-localnet" tabindex="-1"><a class="header-anchor" href="#run-dtp-integration-test-localnet"><span>Run DTP Integration Test (localnet)</span></a></h3><p>~/dtp$ cargo test</p><p>When running integration tests, the test setup makes sure a localnet (sui process) and a peer DTP service Daemon (dtp process) simulate interacting with a remote peer.</p><p>This allows to automate your own client/server integration test of your own application on a single machine (Just need to make sure to use a different set of object coin, client address and localhost:port. More on this later).</p>`,12);function b(f,g){const t=a("ExternalLinkIcon");return s(),o("div",null,[c,u,e("p",null,[e("a",p,[n("https://docs.sui.io/build/install#prerequisites"),i(t)])]),m,e("p",null,[e("a",h,[n("https://github.com/mario4tier/dtp"),i(t)])]),v])}const w=l(r,[["render",b],["__file","full_setup.html.vue"]]),y=JSON.parse('{"path":"/how-to/full_setup.html","title":"Rust Development Setup Installation","lang":"en-US","frontmatter":{"editLink":true,"description":"Rust Development Setup Installation Follow the Sui installation https://docs.sui.io/build/install#prerequisites Clone DTP https://github.com/mario4tier/dtp Initialize localnet J...","head":[["meta",{"property":"og:url","content":"https://dtp.dev/how-to/full_setup.html"}],["meta",{"property":"og:site_name","content":"Decentralized Transport Protocol"}],["meta",{"property":"og:title","content":"Rust Development Setup Installation"}],["meta",{"property":"og:description","content":"Rust Development Setup Installation Follow the Sui installation https://docs.sui.io/build/install#prerequisites Clone DTP https://github.com/mario4tier/dtp Initialize localnet J..."}],["meta",{"property":"og:type","content":"article"}],["meta",{"property":"og:locale","content":"en-US"}],["meta",{"property":"og:updated_time","content":"2024-02-14T03:11:10.000Z"}],["meta",{"property":"article:author","content":"dtp.dev"}],["meta",{"property":"article:modified_time","content":"2024-02-14T03:11:10.000Z"}],["script",{"type":"application/ld+json"},"{\\"@context\\":\\"https://schema.org\\",\\"@type\\":\\"Article\\",\\"headline\\":\\"Rust Development Setup Installation\\",\\"image\\":[\\"\\"],\\"dateModified\\":\\"2024-02-14T03:11:10.000Z\\",\\"author\\":[{\\"@type\\":\\"Person\\",\\"name\\":\\"dtp.dev\\",\\"url\\":\\"https://dtp.dev\\"}]}"]]},"headers":[{"level":3,"title":"Follow the Sui installation","slug":"follow-the-sui-installation","link":"#follow-the-sui-installation","children":[]},{"level":3,"title":"Clone DTP","slug":"clone-dtp","link":"#clone-dtp","children":[]},{"level":3,"title":"Initialize localnet","slug":"initialize-localnet","link":"#initialize-localnet","children":[]},{"level":3,"title":"Publish DTP Package (localnet)","slug":"publish-dtp-package-localnet","link":"#publish-dtp-package-localnet","children":[]},{"level":3,"title":"Run DTP Integration Test (localnet)","slug":"run-dtp-integration-test-localnet","link":"#run-dtp-integration-test-localnet","children":[]}],"git":{"createdTime":1707880270000,"updatedTime":1707880270000,"contributors":[{"name":"mario4tier","email":"mario4tier@users.noreply.github.com","commits":1}]},"readingTime":{"minutes":0.97,"words":291},"filePathRelative":"how-to/full_setup.md","localizedDate":"February 14, 2024","autoDesc":true}');export{w as comp,y as data};