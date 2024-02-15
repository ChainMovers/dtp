import{_ as c}from"./plugin-vue_export-helper-DlAUqK2U.js";import{r as n,o as p,c as d,a as e,d as t,b as o,w as a,e as r}from"./app-DmICp2Ou.js";const u={},h=e("p",null,"DTP provides networking building blocks that can be applied in many ways.",-1),m=e("p",null,"You will find on this page a few inspiring ideas.",-1),w={href:"../how-to/install?url"},g=r('<h2 id="which-layer-do-you-need-to-work-with" tabindex="-1"><a class="header-anchor" href="#which-layer-do-you-need-to-work-with"><span>Which layer do you need to work with?</span></a></h2><p>DTP features are available in roughly 3 layers (by increasing level of difficulty):</p><ul><li><p><b>DTP Services Daemon</b> Similar to NGINX, Cloudflare, HAProxy... These are for proxy/forward/firewall services. You will simply be <em>configuring</em> how your data flows between your apps and servers. Your existing apps just use standard TCP/IP sockets (e.g. &quot;localhost:port&quot; URL) to interface with the DTP services daemon.</p></li><li><p><b>DTP Protocols</b> Think &quot;TCP&quot;. The DTP/Sui SDKs allows developers to have more control for connecting any mix of web2 apps (webapp, client/servers...). You will need to write Rust and/or Typescript apps. This is also the solution to eliminate having to install the DTP Services Daemon on your end-users&#39; devices.</p></li><li><p><b>DTP Sui Move Packages</b> Innovations particular to Sui, such as RPC escrows, new traffic policies, coins&amp;call equivocation mitigation, metering etc... you will likely be deeply involve into web3 development at this point.</p></li></ul><p>For most users, you will deal only with the &quot;easiest&quot; layer, the &quot;DTP Services Daemon&quot;.</p>',4),y={href:"https://discord.gg/Erb6SwsVbH",target:"_blank",rel:"noopener noreferrer"},f=e("h2",{id:"examples-ideas",tabindex:"-1"},[e("a",{class:"header-anchor",href:"#examples-ideas"},[e("span",null,"Examples/Ideas")])],-1),b=e("p",null,[e("strong",null,"Client/Server")],-1),v=e("p",null,[e("strong",null,"Encrypted Messaging")],-1),_=e("ul",null,[e("li",null,'Add traditional user/password login to a dApp. The goal is to allow access to the same "user account" even if done from a different wallet (client address). Implementation often requires "secret messaging" between a centralized server and the Web3 apps.'),e("li",null,"Any user-to-user data transfer "),e("li",null,"Anonymous Tips Line (with potential reward in return).")],-1),T=e("p",null,[e("strong",null,"Networking / Infrastructure")],-1),k=e("li",null,"Zookeeper, Consul, Serf-like services for discovery and consensus among off-chain servers.",-1),P=r("<p><strong>Firewall</strong></p><ul><li>Rate limit access to a back-end server (either bandwidth or request)</li><li>Allow/block origin (using authentication)</li></ul><p><strong>Crypto-Economics</strong></p><ul><li>Any service charging for content access (in addition to gas cost). DTP provides generic per byte and/or per request escrow service (to meter pre-agreed cost, limit and quantity... not quality).</li><li>Pre-paid subscription per day/month (epoch driven?).</li><li>Various escrow service that allows to shift the transport cost completely at the origin or destination (gas always paid by sender, but escrow service handles fair refund).</li></ul><p><strong>Public Broadcasting</strong></p><ul><li>Allow live broadcasting to automatically turn on/off upon enough fund contributed (thus saving the producer from any expense when no-one is listening).</li><li>Public broadcast performed upon enough ticket sold.</li><li>Tip/Request/Message/Audience participation line attach to a public event channel.</li></ul>",6);function D(x,S){const s=n("HopeIcon"),l=n("ExternalLinkIcon"),i=n("RouteLink");return p(),d("div",null,[h,m,e("p",null,[t("When ready "),e("a",w,[o(s,{icon:"arrow-right"}),t(" Go to choose your installation setup ...")]),t(".")]),g,e("p",null,[t("If not sure how to proceed for your specific need, then please open a discussion on "),e("a",y,[t("Discord"),o(l)]),t(".")]),f,b,e("ul",null,[e("li",null,[t("Web3 frontends connecting to a centralized JSON-RPC backend ("),o(i,{to:"/examples/rpc_firewall.html"},{default:a(()=>[t("More info")]),_:1}),t(")")]),e("li",null,[t("Rust/Typescript Web3 Client to centralized TCP Server ("),o(i,{to:"/examples/web3_rust.html"},{default:a(()=>[t("More info")]),_:1}),t(")")])]),v,_,T,e("ul",null,[k,e("li",null,[t("UDP, TCP, QUIC/UDP Tunneling: Transport IP protocols packets within a DTP connection for point-to-point applications (See "),o(i,{to:"/how-to/install.html#choice-1-of-3-simplified-dtp-services-deployment"},{default:a(()=>[t("DTP Services Daemon")]),_:1}),t(" for an alternative)")])]),P])}const I=c(u,[["render",D],["__file","index.html.vue"]]),A=JSON.parse('{"path":"/examples/","title":"Use Cases","lang":"en-US","frontmatter":{"title":"Use Cases","contributors":true,"editLink":true,"headerDepth":0,"description":"DTP provides networking building blocks that can be applied in many ways. You will find on this page a few inspiring ideas. When ready . Which layer do you need to work with? DT...","head":[["meta",{"property":"og:url","content":"https://dtp.dev/examples/"}],["meta",{"property":"og:site_name","content":"Decentralized Transport Protocol"}],["meta",{"property":"og:title","content":"Use Cases"}],["meta",{"property":"og:description","content":"DTP provides networking building blocks that can be applied in many ways. You will find on this page a few inspiring ideas. When ready . Which layer do you need to work with? DT..."}],["meta",{"property":"og:type","content":"article"}],["meta",{"property":"og:locale","content":"en-US"}],["meta",{"property":"og:updated_time","content":"2024-02-15T22:54:53.000Z"}],["meta",{"property":"article:author","content":"dtp.dev"}],["meta",{"property":"article:modified_time","content":"2024-02-15T22:54:53.000Z"}],["script",{"type":"application/ld+json"},"{\\"@context\\":\\"https://schema.org\\",\\"@type\\":\\"Article\\",\\"headline\\":\\"Use Cases\\",\\"image\\":[\\"\\"],\\"dateModified\\":\\"2024-02-15T22:54:53.000Z\\",\\"author\\":[{\\"@type\\":\\"Person\\",\\"name\\":\\"dtp.dev\\",\\"url\\":\\"https://dtp.dev\\"}]}"]]},"headers":[{"level":2,"title":"Which layer do you need to work with?","slug":"which-layer-do-you-need-to-work-with","link":"#which-layer-do-you-need-to-work-with","children":[]},{"level":2,"title":"Examples/Ideas","slug":"examples-ideas","link":"#examples-ideas","children":[]}],"git":{"createdTime":1707880270000,"updatedTime":1708037693000,"contributors":[{"name":"mario4tier","email":"mario4tier@users.noreply.github.com","commits":3}]},"readingTime":{"minutes":1.7,"words":509},"filePathRelative":"examples/README.md","localizedDate":"February 14, 2024","autoDesc":true}');export{I as comp,A as data};
