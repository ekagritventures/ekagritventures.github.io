---
layout: default
title: Home
---
# Curiosity first.

Keep the main thing the main thing.

Ekagrit Ventures is a personal archive of inquiry. Notes, questions, and investigations across finance, companies, and ideas. No narrative. No positioning. Just work done out of curiosity.

## Sections
- [Daily Notes](/notes/)
- [Research](/research/)
- [Questions](/questions/)
- [Archive](/archive/)

---

[Resources](/resources/) · [About](/about/)

## Latest Daily Notes
[View all daily notes →](/notes/)

{% for post in site.posts limit:5 %}
<li><a href="{{ post.url }}">{{ post.title }}</a> - {{ post.date | date: "%B %d, %Y" }}</li>
{% endfor %}


