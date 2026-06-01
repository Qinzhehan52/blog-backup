# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A [Hexo](https://hexo.io/) static blog (v8.1.1) using the NexT theme, deployed to GitHub Pages at `qinzhehan52.github.io`. Pushing to `master` triggers a GitHub Actions workflow that generates the site and pushes the output to the external repo `Qinzhehan52/qinzhehan52.github.io`.

## Common Commands

```bash
npm ci                   # install dependencies
npx hexo clean           # remove generated files in public/
npx hexo generate        # build static site into public/
npx hexo server          # local dev server at http://localhost:4000
npx hexo new "Post Title" # scaffold a new post in source/_posts/
```

## Architecture

- **`_config.yml`** — main Hexo config (site URL, permalink format, theme selection, etc.)
- **`themes/next/_config.yml`** — NexT theme config; controls scheme (currently Muse), dark mode, sidebar, TOC, third-party integrations
- **`source/_posts/`** — blog posts as Markdown files with YAML front-matter
- **`source/{categories,tags}/`** — index pages for category/tag listings
- **`.github/workflows/`** — CI/CD: on push to `master`, installs deps, runs `hexo clean && hexo generate`, deploys `./public` to the external GitHub Pages repo using `PERSONAL_TOKEN` secret

## Deployment

The site has two independent deploy targets:

1. **GitHub Pages** (`qinzhehan52.github.io`) — **automatic**. Pushing to `master` runs the GitHub Actions workflow, which builds with the default `_config.yml` and pushes `public/` to the external `Qinzhehan52/qinzhehan52.github.io` repo.
2. **nerdhan.top** (self-hosted nginx mirror) — **manual**. Run `./deploy-nerdhan.sh`, which builds with a URL override (`--config _config.yml,_config.nerdhan.yml`) and rsyncs `public/` to the server's nginx web root over SSH (host alias `racknerd` in `~/.ssh/config`). GitHub Actions does **not** touch this target, so run the script after any content change you want mirrored there.

`_config.nerdhan.yml` only overrides `url` (to `https://nerdhan.top`) so canonical/sitemap/RSS point at the right domain; the GitHub Pages build keeps using the unmodified `_config.yml`.

## Post Front-Matter Format

```yaml
---
title: Post Title
date: YYYY-MM-DD HH:mm:ss
tags:
  - tag1
categories:
  - category
---
```

## Theme Customization

The NexT theme is the modern version (using `.njk` Nunjucks templates, not the legacy `.swig` files). Custom overrides should go in `source/_data/` (e.g., `styles.styl`, `head.njk`) and be referenced via the `custom_file_path` section in `themes/next/_config.yml` — this avoids merge conflicts when the theme is updated.
