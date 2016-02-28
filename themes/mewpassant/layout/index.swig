{% extends 'default.swig' %}

{% block content %}
  <div class="col-8" id="main">
    <div class="res-cons">
    {% set index = true %}
    {% for post in page.posts %}
    {% set content = post.content %}
      <article class="post">
        {% include '_partial/article.swig' %}
      </article>
    {% endfor %}
      <div class="page-navigator">
      {{
      paginator({
        prev_text: '&larr; Older',
        next_text: 'Newer &rarr;',
        mid_size: 1
      })
    }}
        
      </div>
     </div>
  </div>
 {% endblock %}

 {% block sidebar %}
  <aside id="secondary">
  
  </aside>
 {% endblock %}

  