# AGENTS.md

## Project Overview

**Ekagrit Ventures** is a personal finance research notebook. Content is authored in Obsidian and published as a static Jekyll site on GitHub Pages.

**Live site:** https://ekagritventures.github.io

---

## Architecture

```
Obsidian (source of truth)
    ↓
Git push to main
    ↓
GitHub Actions (custom build with plugins)
    ↓
GitHub Pages (static hosting)
```

### Why Custom Build?

Standard GitHub Pages runs in "Safe Mode" and blocks custom plugins. This site uses a custom GitHub Actions workflow (`.github/workflows/jekyll.yml`) to:
1. Spin up an Ubuntu container
2. Install Ruby 3.3 and dependencies
3. Run Jekyll build with custom plugins
4. Deploy the finished HTML to GitHub Pages

This enables Obsidian-native features (wikilinks) to work seamlessly.

---

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `_posts/` | Published notes, organized by `year/month/` |
| `Companies/` | Company research pages (e.g., Groww, Meesho, Pine-Labs) |
| `People/` | People profiles (e.g., Alix Pasquet, Benedict Evans) |
| `pages/` | Static pages (index, about, research, questions, resources, archive) |
| `_drafts/` | Unpublished drafts (gitignored) |
| `_templates/` | Obsidian templates (e.g., daily note template) |
| `_internal/` | Internal docs and guides (excluded from build) |
| `_plugins/` | Custom Jekyll plugins |
| `_layouts/` | HTML templates (`default.html`, `post.html`) |
| `assets/` | CSS (`styles.css`), JS (`theme.js`, `external-links.js`) |

---

## Custom Plugin: Wikilinks (`_plugins/wikilinks.rb`)

Converts Obsidian `[[wikilinks]]` to standard Markdown links during build.

### How It Works

**Phase 1 — Mapper (Generator):**
- Runs early in build
- Scans all posts, pages, and collection docs
- Builds a global dictionary: `{ "Title" → "/url/", "filename" → "/url/" }`

**Phase 2 — Interceptor (Pre-Render Hook):**
- Runs just before HTML generation
- Finds `[[Target]]` or `[[Target|Label]]` patterns
- Replaces with `[Label](/url/)` using the dictionary

### Supported Syntax

| Obsidian | Renders As |
|----------|------------|
| `[[Groww]]` | Link to `/Companies/Groww/` |
| `[[Groww\|The App]]` | Link text shows "The App" |
| `[[2026]]` | Link to `/2026/` |

### Troubleshooting

If a wikilink doesn't resolve:
1. Ensure target file has YAML front matter (`---` block)
2. Ensure filename matches the text inside `[[brackets]]`

### Important: Always Use Wikilinks for Internal Links

**Use `[[wikilinks]]`, not `[text](/url/)` for internal links.**

- `[[AI]]` — Works in Obsidian AND converts to `/ai/` in Jekyll
- `[AI](/ai/)` — Works on the website but **breaks in Obsidian** (opens a new file instead)

This lets you navigate in Obsidian while the plugin handles URL conversion for the web.

---

## Obsidian Workflow

### Daily Notes

Template location: `_templates/obsidian-daily-note-template.md`

Template creates posts with:
- `layout: post`
- `title: Daily Note YYYY-MM-DD`
- `slug: daily-note-YYYY-MMM-DD-Do`
- `published: false` (default — flip to `true` when ready)

### Draft Management

Three options:
1. **`_drafts/` folder** — gitignored, never published
2. **`published: false`** in front matter — stays in repo but not built
3. **Separate folder outside repo** — completely private

Recommended: Write in Obsidian → move to `_drafts/` → move to `_posts/` when ready.

---

## Front Matter Requirements

All content files need YAML front matter to be processed by Jekyll:

```yaml
---
layout: default  # or 'post' for blog posts
title: "Page Title"
published: true  # set to false to hide
---
```

Files without front matter are treated as static assets (images, etc.) and won't generate pages.

---

## Styling

### Theme System

- **Light mode:** Warm paper tones (`--bg: #FFFCF0`)
- **Dark mode:** Deep charcoal (`--bg: #100F0F`)
- Toggle persists via `localStorage`
- Respects `prefers-color-scheme` on first visit

Color palette uses Flexoki-inspired variables: `--tx`, `--tx-2`, `--tx-3`, `--ui`, `--cy`, `--re`, etc.

### Typography

- System fonts: `-apple-system, BlinkMacSystemFont, Inter, Segoe UI, sans-serif`
- Max content width: `720px`
- Line height: `1.5`

### JS Features

- `theme.js` — Light/dark toggle with localStorage persistence
- `external-links.js` — Opens external links in new tab with `rel="noopener noreferrer"`

---

## Build & Deploy

### Local Development

```bash
bundle install
bundle exec jekyll serve
```

Site available at `http://localhost:4000`

### Production Deploy

Push to `main` branch → GitHub Actions builds and deploys automatically.

Workflow: `.github/workflows/jekyll.yml`

---

## Config (`_config.yml`)

Key settings:
- `theme: minima` (base theme, heavily customized)
- `permalink: /:slug/` (clean URLs)
- `google_analytics: G-8PRNH9GG8M`
- Excludes: `.obsidian`, `_internal`, `_templates`, `Gemfile`, etc.

---

## .gitignore Highlights

- `.obsidian/` — Obsidian workspace (local only)
- `_drafts/` — Unpublished drafts
- `*GUIDE*.md`, `OBSIDIAN_*.md` — Internal documentation
- `_site/`, `.jekyll-cache/` — Build artifacts
- Environment files, secrets, API keys

---

## Content Collections

| Collection | Location | URL Pattern |
|------------|----------|-------------|
| Posts | `_posts/YYYY/Month/` | `/:slug/` |
| Companies | `Companies/` | `/Companies/:title/` |
| People | `People/` | `/People/:title/` |

---

## When Making Changes

### Content Changes
- Edit in Obsidian, push to Git
- Structure is driven by Obsidian folder organization
- Don't restructure Jekyll to change content — restructure Obsidian

### Design/Presentation Changes
- Edit `assets/styles.css` for styling
- Edit `_layouts/*.html` for structure
- These don't affect content workflow

### Adding New Sections
1. Create folder in Obsidian (e.g., `Themes/`)
2. Add files with front matter
3. Wikilinks will auto-resolve after next build

---

## Potential Improvements

### Already Well-Executed
- Wikilink plugin is solid and handles edge cases (pipe character table bug)
- Theme toggle with system preference detection
- Clean, minimal design with good typography
- Proper gitignore for Obsidian artifacts

### Could Consider
- **Backlinks display** — Show "pages that link to this page" at bottom of posts
- **RSS feed** — Already configured (`jekyll-feed` plugin), may want to customize
- **Search** — No search currently; could add client-side search (Lunr.js)
- **Tags page** — Front matter supports tags, but no tag index page exists
- **Reading time** — Could add estimated reading time to posts
- **Last updated date** — Show when content was last modified
