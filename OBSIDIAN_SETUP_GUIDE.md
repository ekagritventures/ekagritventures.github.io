---
published: false
---

# Obsidian to Jekyll Daily Notes Setup

## Quick Setup

### 1. Obsidian Daily Notes Plugin Settings
Go to Settings → Daily Notes and set:
- **Date format**: `YYYY-MM-DD`
- **File name format**: `YYYY-MM-DD`
- **Template location**: Use the template below

### 2. Daily Note Template for Obsidian
Create a new template file in your Obsidian templates folder:

```markdown
---
layout: default
title: "Daily Note - {{date:MMMM DD}}"
date: {{date:YYYY-MM-DD}}
tags: [daily-note, finance]
---

# {{date:MMMM DD, YYYY}}

## Market Focus
- 

## Key Research
- 

## Observations
- 

## Action Items
- 

---

*Created in Obsidian on {{date:MMMM DD, YYYY}}*
```

### 3. Folder Structure
- Set your daily notes location to `_posts/` in your Jekyll site
- Or keep them in a separate folder and move/copy to `_posts/` when ready to publish

### 4. Publishing Workflow
Since you're using GitHub Pages with automatic deployment:

1. Write your daily note in Obsidian
2. Save it to the `_posts/` folder (or move it there)
3. Your Git plugin will automatically commit and push to GitHub
4. GitHub Pages will automatically rebuild your site
5. Your daily note appears at `/notes/` automatically!

**Note**: You don't need to run `bundle exec jekyll build` manually - GitHub Pages handles the build process for you.

## Tips
- **Post titles**: The `title:` in front matter becomes the post title
- **Dates**: Use current or past dates (future dates won't publish)
- **Content**: Everything after the front matter becomes your post content
- **Formatting**: Use standard Markdown, it will be rendered by Jekyll

## Example Daily Note
See `_posts/2025-11-13-market-observations.md` for an example of how your Obsidian daily notes will look on the website.