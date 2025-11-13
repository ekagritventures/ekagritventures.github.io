---
layout: default
title: Home
---
# Welcome
Write notes in Obsidian as Markdown. Jekyll will build and publish automatically.

## Latest
{% for post in site.posts limit:10 %}
- [{{ post.title }}]({{ post.url }})
{% endfor %}


