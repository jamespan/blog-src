{% if page.no_header %}
{% else %}
  <header>
    {% if index %}
      <h2 class="post-title"><a href="{{ root_url }}{{ url_for(post.path) }}">{% if site.titlecase %}{{ post.title | title }}{% else %}{{ post.title }}{% endif %}</a></h2>
    {% else %}
      <h1 class="post-title">{% if site.titlecase %}{{ page.title | title }}{% else %}{{ page.title }}{% endif %}</h1>
    {% endif %}
    {% if page.meta == false %}
    {% else %}
      <p class="post-meta">
        {% include 'post/date.html' %}{{ time }}
        {% if site.disqus_short_name and page.comments != false and post.comments != false and site.disqus_show_comment_count == true %}
         | <a href="{% if index %}{{ root_url }}{{ post.url }}{% endif %}#disqus_thread">Comments</a>
        {% endif %}
      </p>
    {% endif %}
  </header>
{% endif %}
{% if index %}
  {% set excerpted = 'false' %}
  {% if post.excerpt %}
    {% set excerpted = 'true' %}
    <div class="post-content">{{ post.excerpt }}</div>
  {% else %}
    <div class="post-content">{{ post.excerpt }}</div>
  {% endif %}
  {% if excerpted == 'true' %}
    <footer>
      <a rel="full-article" href="{{ root_url }}{{ post.url }}">{{ site.excerpt_link }}</a>
    </footer>
  {% endif %}
{% else %}
<div class="post-content">{{ content }}</div>
{% endif %}
