# CONTEXT

Ekagrit Ventures is a personal finance research notebook authored in Obsidian
and published as a static Jekyll site on GitHub Pages.
Live site: https://ekagritventures.github.io

Operational how-to lives in `AGENTS.md` (Obsidian workflow, deploy gotchas,
email capture). This file is the domain map: concepts, vocabulary, and
invariants an agent should know before touching anything.

## The publish pipeline

```
Obsidian vault (source of truth)
  → git push to main (automated "vault backup" commits)
  → GitHub Actions: bundle exec jekyll build (custom plugins allowed)
  → GitHub Pages serves _site/
```

There is no manual publish step. If a push doesn't produce a live change,
either the build failed (check Actions) or the content was invisible to
Jekyll (see `published` below).

## Glossary

**Daily note** — a dated journal entry living at
`_posts/YYYY/MM-Month/YYYY-MM-DD-.md` (trailing dash required; Obsidian's
Daily Notes core plugin creates these). Becomes a **post** once visible to
Jekyll.

**Post** — any file under `_posts/` with front matter that Jekyll builds into
a page at `/:slug/`.

**published (front matter)** — `false` makes a post **invisible to the entire
build**: not rendered, not renamed, not in `site.posts.docs`. Verified
behaviour (2026-08): a bare-named `published: false` post passes CI while an
identical `published: true` one triggers the auto-slug rename path.

**Slug** — the URL segment for a post, owned by the auto-slug plugin. Derived
from `title:` (or explicit `slug:`, or date fallback); guaranteed unique
per build via a guest list (first/oldest post wins the bare slug).

**Rename** — the auto-slug plugin's side effect of renaming the source file
on disk (`YYYY-MM-DD-.md` → `YYYY-MM-DD-slug.md`) during the build's generate
phase. This means a crashed first build can mask its own cause locally:
renamed files skip the rename path on the next run. Fresh checkouts (CI) do
not get this healing — local green does not imply CI green.

**Wikilink** — `[[Target]]` / `[[Target|Label]]` syntax, converted at build
time by the wikilinks plugin (mapper builds title→URL dictionary, pre-render
hook rewrites links). Always author internal links as wikilinks, never as
markdown paths — wikilinks work in both Obsidian and the built site.

**Draft** — unpublished work. Either in `_drafts/` (gitignored) or
`published: false` in `_posts/`.

**Vault backup** — the automated Obsidian-git commit ("vault backup: <date>").
It pushes whatever is on disk, including build-induced renames.

## Collections & URLs

| Collection | Source | URL pattern |
|---|---|---|
| Posts | `_posts/YYYY/Month/` | `/:slug/` |
| Companies | `Companies/` | `/Companies/:title/` |
| People | `People/` | `/People/:title/` |

## Invariants

1. **Document paths are Strings.** Jekyll's renderer feeds `document.path`
   through `PathManager#sanitize_and_join`, which calls `.start_with?`. Never
   assign a `Pathname` (or any non-String) to a doc's `@path`. Violating this
   broke every CI build Aug 12 – Aug 26, 2026 while passing locally (see
   Rename above).
2. **Slugs are unique per build**, assigned at Generator priority `:highest`,
   before the wikilinks mapper (`:high`) reads `.url`.
3. **The site must build from a fresh checkout with bare daily notes present.**
   Guarded by `_internal/smoke-build.sh` (local-only; `_internal/` is
   gitignored), which archives HEAD, overlays current `_plugins/`, builds, and
   fails on any error. Run it after changing plugins or build config.
