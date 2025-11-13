---
layout: default
title: Home
---
# Curiosity first.

Keep the main thing the main thing.

Ekagrit Ventures is a personal archive of inquiry. Notes, questions, and investigations across finance, companies, and ideas. No narrative. No positioning. Just work done out of curiosity.

## Sections
- [Notes](/notes)
- [Research](/research)
- [Questions](/questions)
- [Archive](/archive)

## Latest
{% for post in site.posts limit:10 %}
- [{{ post.title }}]({{ post.url }})
{% endfor %}


