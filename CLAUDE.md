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
