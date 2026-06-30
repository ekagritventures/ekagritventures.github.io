---
layout: default
title: Archive
permalink: /archive/
---

# Archive

{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% for year in posts_by_year %}
<section class="archive-year">
  <h2>{{ year.name }}</h2>
  <ul class="notes-list">
    {% for post in year.items %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      <span class="muted"> · {{ post.date | date: "%b %d" }}</span>
    </li>
    {% endfor %}
  </ul>
</section>
{% endfor %}
