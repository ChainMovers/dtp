import { sidebar } from "vuepress-theme-hope";

export const enSidebar = sidebar({
  "/": [
    "",
    {
      text: "Getting Started",
      link: "intro.md",
      children: [
        {
          text: "What is DTP?",
          link: "intro.md",
        },
        {
          text: "Installation",
          link: "how-to/install.md",
        },
        {
          text: "FAQ",
          link: "faq.md",
        },
      ],
    },
    {
      text: "Use Cases",
      link: "examples/README.md",
      children: [
        {
          text: "Examples/Ideas",
          link: "examples/README.md",
        },
        {
          text: "RPC Firewall",
          link: "examples/rpc_firewall.md",
        },
        {
          text: "Rust Backend",
          link: "examples/web3_rust.md",
        },
      ],
    },
    {
      text: "Docs",
      link: "docs/README.md",
      children: [
        {
          text: "Basic Concepts",
          link: "docs/README.md",
        },
        {
          text: "API",
          collapsible: true,
          prefix: "docs/",
          children: [
            {
              text: "Rust",
              link: "api_rust.md",
            },
            {
              text: "Typescript",
              link: "api_typescript.md",
            },
            {
              text: "'dtp' Command Line",
              link: "scripts.md",
            },
          ],
        },
        {
          text: "Design",
          link: "docs/design.md",
        },
        {
          text: "Future Work",
          link: "docs/future_work.md",
        },
      ],
    },
    {
      text: "Community",
      link: "community/",
      children: [
        {
          text: "Forums / Contacts",
          link: "community/",
        },
        {
          text: "Become an Editor",
          link: "community/editors.md",
        },
      ],
    },
  ],
});
