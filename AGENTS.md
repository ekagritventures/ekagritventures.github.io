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

## Custom Plugin: Auto-Slug (`_plugins/auto-slug.rb`)

Derives a clean URL slug from each post's `title` at build time, so authoring
in Obsidian only requires writing a `title:` — the URL becomes `/slugified-title/`
automatically.

- Slug missing / blank / a bare `YYYY-MM-DD` date → generated from the title.
- An explicit word slug (e.g. `slug: my-url`) is always respected.
- No title and no slug → falls back to the post date (never an empty slug, which
  would collide with the homepage `/`).

**Collision-proof.** The plugin keeps a per-build "guest list" of every slug it
hands out and forces uniqueness: if a slug is already taken it appends the post
date (`a-slow-day-2026-07-23`), then a counter (`-2`) if needed. Posts are
processed in path order, so the first/oldest post keeps the clean slug and
existing URLs never shift. Two notes with the same title therefore never share a
URL — e.g. daily notes titled "A Slow Day" on different days become `/a-slow-day/`
and `/a-slow-day-<date>/`.

Runs as a Generator at `:highest` priority so slugs are normalized before the
wikilinks mapper (`:high`) computes any `.url`. This also permanently prevents
the "unquoted date slug" build crash (`slugify` receiving a Ruby `Date`).

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

**Template file:** `_templates/obsidian-daily-note-template.md`

**Obsidian Settings → Core Plugins → Daily Notes:**

| Setting | Value |
|---------|-------|
| Date format | `YYYY/MM-MMMM/YYYY-MM-DD-` |
| New file location | `_posts` |
| Template file location | `_templates/obsidian-daily-note-template` |

> **Note:** The core Daily Notes plugin does **not** interpolate `{{date}}` tokens in the "New file location" field. To get year/month subfolders, put the path in the **Date format** field and keep "New file location" as the flat `_posts` folder.
>
> The **trailing `-`** in the date format is required: Jekyll only recognizes posts named `YYYY-MM-DD-something.md`. A file named `2026-06-30.md` (no trailing dash) is silently ignored, while `2026-06-30-.md` builds correctly. The clean URL comes from the `slug:` field in the template's front matter, so the trailing dash never shows up in the live link.

**What this does:**
Obsidian automatically creates daily notes in the correct Jekyll folder structure (`_posts/2026/06-June/2026-06-30.md`). The numeric prefix (`06-June`) keeps months in chronological order in Obsidian's file explorer; it does not affect URLs, which come from the `slug:` field. When you later flip `published: true` and push to Git, Jekyll builds it automatically.

**Template front matter creates:**
- `layout: post`
- `title: Daily Note YYYY-MM-DD`
- `slug: daily-note-YYYY-MMM-DD-Do` (clean URL)
- `published: false` (default — flip to `true` when ready to publish)
- `categories:` for year and month (useful for archives)

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
- `subscribe.js` — Progressive enhancement for the footer email form (see Email Capture)

---

## Email Capture (Kit / ConvertKit)

A newsletter signup box lives in the footer of every page (`_layouts/default.html`),
styled in `assets/styles.css` (`.subscribe*`, Flexoki, light/dark aware).

**Toggle:** the whole form is gated on `kit_form_action` in `_config.yml`. Paste the
Kit form's HTML action URL (e.g. `https://app.kit.com/forms/9717135/subscriptions`)
to switch it on; blank it to hide the form entirely. Field name is Kit's
`email_address`.

**Behaviour** (`assets/subscribe.js`, progressive enhancement):
- With JS: the form posts into a hidden iframe so the visitor never leaves the page,
  then an inline `.subscribe-status` message tells them to confirm and check
  spam/Promotions. The message is optimistic — it can't read Kit's cross-origin
  response, so it assumes success once the (validated) email is submitted.
- Without JS: falls back to `target="_blank"`, opening Kit's confirmation page in a
  new tab.

**Copy:** the promise line ("I only send long-form pieces and a monthly summary")
is the `.subscribe-note` paragraph in the layout.

**Double opt-in is intentional** (kept for deliverability). That means Kit sends a
confirmation email, which is why the on-page message mentions checking spam. Two
open, optional improvements:
- The confirmation email's wording/branding is plain — customise it in Kit
  (form → Settings → confirmation email) if desired. Cosmetic only.
- Emails land in spam/Promotions because sending is from Kit's shared, unauthenticated
  domain. The real fix is a **custom domain + DKIM/SPF authentication in Kit** — a
  ~$10–15/yr project, deferred until there's a custom domain.

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

**Deploy gotchas:**
- GitHub occasionally fails to create a workflow run for a push. If a push doesn't
  deploy, trigger it manually: `gh workflow run "Deploy Jekyll with Plugins" --ref main`.
- Only **one** GitHub Pages deployment can run at a time. Don't fire a manual
  `workflow_dispatch` while a push-triggered run is still going — the second deploy
  fails with "in progress deployment … cancel X first". Let one finish before starting
  another.
- Verify a deploy against the **commit SHA**, not just "latest run"
  (`gh run list --commit <sha>`) — watching the wrong run gives false confidence.
- Jekyll skips **future-dated** posts (date after today) unless `--future`.

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
- **Custom domain + email authentication** — Point a custom domain at Pages and
  authenticate a Kit sending subdomain (DKIM/SPF) so newsletter + confirmation emails
  reach the main inbox instead of spam/Promotions. (See Email Capture.)
- **Nicer Kit confirmation email** — Customise its wording/branding in Kit's dashboard.
- **Backlinks display** — Show "pages that link to this page" at bottom of posts
- **RSS feed** — Already configured (`jekyll-feed` plugin), may want to customize
- **Search** — No search currently; could add client-side search (Lunr.js)
- **Tags page** — Front matter supports tags, but no tag index page exists
- **Reading time** — Could add estimated reading time to posts
- **Last updated date** — Show when content was last modified
