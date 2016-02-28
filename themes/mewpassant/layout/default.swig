{% include '_partial/head.swig' %}
<body {% if page.body_id %} id="{{ page.body_id }}" {% endif %} {% if page.sidebar == false %} class="no-sidebar" {% endif %} {% if page.sidebar == 'collapse' or site.sidebar == 'collapse' %} class="collapse-sidebar sidebar-footer" {% endif %}>
  <header id="header" class="clearfix">{% include '_partial/header.swig' %}</header>
  <div id="body">
    <div class="container">
    	<div class="col-group">
			{% block content %}{% endblock %}
      	</div>
    </div>
  </div>
  <footer id="footer">
  	{% include '_partial/footer.swig' %}
  </footer>
  {% include '_partial/after_footer.swig' %}
</body>
</html>
