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
  {% assign excerpt_text = post.excerpt | strip_html | replace: '[[', '' | replace: ']]', '' %}
  {{ excerpt_text | truncatewords: 36 }}

</div>
{% endfor %}

---

*All notes are work-in-progress and driven by curiosity. No investment advice.*


