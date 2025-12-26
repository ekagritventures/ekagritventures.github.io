---
layout: default
title: Home
permalink: /
---

<div class="hero">
  <h1 class="hero-title">Curiosity first.</h1>
  <p class="hero-subtitle">Keep the main thing the main thing.</p>
  <p class="hero-desc">Ekagrit Ventures is a personal archive of inquiry. Notes, questions, and investigations across finance, companies, and ideas. No narrative. No positioning. Just work done out of curiosity.</p>
</div>

<div class="latest-notes">
  <h2>Latest Notes</h2>
  <ul class="notes-list">
    {% for post in site.posts limit:5 %}
    <li><a href="{{ post.url }}">{{ post.title }}</a><span class="muted"> · {{ post.date | date: "%b %d" }}</span></li>
    {% endfor %}
  </ul>
  <p><a href="/archive/">View all notes →</a></p>
</div>

---

[Research](/research/) · [Questions](/questions/) · [Resources](/resources/) · [About](/about/)
