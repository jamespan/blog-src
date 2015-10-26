server:
	hexo server --draft

publish:
	hexo clean
	hexo g
	hexo d

backup:
	hexo clean
	tar -czf ~/百度云同步盘/Backup/blog.`date +%s`.tar.gz ./

clean:
	hexo clean
