import { defineUserConfig } from "vuepress";
import theme from "./theme.js";
import { viteBundler } from "@vuepress/bundler-vite";

export default defineUserConfig({
  base: "/",

  bundler: viteBundler({
    viteOptions: {},
    vuePluginOptions: {},
  }),

  lang: "en-US",
  title: "Decentralized Transport Protocol",
  description: "Adds Web3 features to existing Web2 data transfer apps",

  theme,

  // Enable it with pwa
  // shouldPrefetch: false,
});
