---
layout: default
title: Daily Notes
---
# Daily Notes

Daily research notes and observations from my finance and investment research.

## Recent Daily Notes
{% for post in site.posts limit:20 %}
<div class="daily-note-entry">
  <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
  <p class="date">{{ post.date | date: "%B %d, %Y" }}</p>
  {{ post.excerpt }}
</div>
{% endfor %}

---

*All notes are work-in-progress and driven by curiosity. No investment advice.*


