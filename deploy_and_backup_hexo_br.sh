python2 md_image_backup.py
echo "===================== Image backup success ====================="
hexo clean
git add .
git commit -m 'auto backup'
echo "===================== Local commit success ====================="
git push origin hexo_resource
echo "===================== Push to github success ====================="
git push coding hexo_resource
echo "===================== Push to tencent success ====================="
hexo d
echo "===================== Deploy to github and tencent success ====================="
