---
layout: home
title: Hiking. With friends.
skip_search: true
---

{% for page in site.pages %} {% if page.public%}
  {% include blurb.html %}
{% endif %} {% endfor %}
<br class="clear">
