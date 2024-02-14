---
title: "How to propose fix/change to the website?"
order: 2
headerDepth: 0
contributors: true
editLink: true
---

Anyone with a Github account can participate.

The website is built from markdown files (.md) and served directly from [github](https://github.com/chainmovers/dtp/tree/main/docs).

## Editing on Github (recommended for easy/quick changes)

Open the editor with the "Edit this pages on Github" link at the bottom.

When ready to propose your changes just select "Create a **new branch**" and give it a name:<br>
<img src="/assets/images/propose-change.png?url" alt="Propose Changes"><br>

Your proposed changes will be merged after review.

## Editing the website on your machine (advanced contributors)
If you prefer to preview exactly your change, then you need to run vuepress on your machine and modify the markdown files with an editor (e.g. VSCode).

Prerequisites:
   * NodeJS (>= 16.4) ( [https://nodejs.dev/en/learn/how-to-install-nodejs/](https://nodejs.dev/en/learn/how-to-install-nodejs/) )
   * pnpm ( [https://pnpm.io/installation](https://pnpm.io/installation) )
   * DTP and Suibase ( [https://dtp.dev/how-to/install](https://dtp.dev/how-to/install) )

For the one-time vuepress installation do:
```shell
$ cd ~/suibase/workdirs/common/extensions/dtp/docs
$ pnpm install
```

To start vuepress (the server) do:
```shell
$ cd ~/suibase/workdirs/common/extensions/dtp/docs
$ pnpm start
...
Open your browser at http://localhost:8080
```

The browser updates as you change files under docs/src

See [https://theme-hope.vuejs.press/guide/](https://theme-hope.vuejs.press/guide/) for advanced markdown features.

Submit your changes as a pull request, just ask as needed (not as hard as it seems once you do it once).