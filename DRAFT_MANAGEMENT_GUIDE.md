# Draft Management Guide

## How to Manage Drafts and Research Notes

### **Option 1: Use `_drafts/` Folder (Recommended)**
Place files in `_drafts/` folder - they won't be published by GitHub Pages:

```
_drafts/
├── research-ideas.md
├── market-analysis-draft.md
├── company-research-notes.md
```

**Pros:**
- Never published to GitHub Pages
- Easy to organize
- Can use same Jekyll front matter

**Cons:**
- Still committed to Git (visible in repo)

### **Option 2: Use `published: false` Front Matter**
Add to any file to prevent publishing:

```markdown
---
layout: default
title: "Research Notes"
date: 2025-11-13
published: false
---
```

**Pros:**
- File can stay in `_posts/` folder
- Easy to publish (just remove the line)

**Cons:**
- Still visible in GitHub repository

### **Option 3: Keep Outside Repository (Most Secure)**
Keep drafts in a separate folder outside your Git repo:

```
~/Documents/Obsidian-Drafts/
├── daily-notes/
├── research/
└── ideas/
```

**Pros:**
- Completely private
- Not tracked by Git
- Can organize however you want

**Cons:**
- Manual copy/move when ready to publish

### **Option 4: Use Git Branches (Advanced)**
Keep drafts in a separate Git branch:

```bash
git checkout -b drafts
echo "Your draft content" > _posts/draft-note.md
git add .
git commit -m "Add draft note"
```

When ready to publish:
```bash
git checkout main
git merge drafts
```

**Pros:**
- Version control for drafts
- Can collaborate on drafts
- Clean separation

**Cons:**
- More complex Git workflow

## **Recommended Workflow**

For your use case, I recommend **Option 3** (separate folder) + **Option 1** (_drafts/):

1. **Daily writing**: Use Obsidian in `~/Documents/Obsidian-Drafts/daily-notes/`
2. **Ready to publish**: Copy to `_drafts/` folder in your repo
3. **Final review**: Move from `_drafts/` to `_posts/` when ready
4. **Auto-publish**: Git plugin pushes to GitHub Pages

## **Quick Commands**

```bash
# Create a new draft
cp ~/Documents/Obsidian-Drafts/daily-notes/2025-11-13.md _drafts/

# Publish a draft
mv _drafts/2025-11-13.md _posts/
git add _posts/2025-11-13.md
git commit -m "Publish daily note"
```

## **Git Ignore Setup**
Your `.gitignore` is already configured to exclude:
- `_drafts/` folder
- Obsidian workspace files (`*.base`, `*.canvas`)
- Development files (`{% raw %}{{.md{% endraw %}`, `create a link.md`)

This keeps your repository clean and focused on published content!

<!-- Note: The pattern {% raw %}{{.md{% endraw %} is excluded in .gitignore to prevent Obsidian link files from being committed -->