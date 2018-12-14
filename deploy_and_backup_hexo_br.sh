python2 md_image_backup.py
hexo clean
git add .
git commit -m 'auto backup'
git push origin hexo_resource
hexo d
