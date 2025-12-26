---
layout: default
title: Archive
permalink: /archive/
---
All posts.

{% for post in site.posts %}
<li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}


