#!/bin/bash
#
# source codes upload to github
# website files upload to qiniu

python2 md_image_backup.py
echo "===================== Image backup success ====================="

hexo clean

git add .
git commit -m 'auto backup'
echo "===================== Local commit success ====================="

git push origin hexo_resource
echo "===================== Push resource to github success ====================="

echo "===================== Generate website files ====================="
hexo generate

echo "===================== Push website files to Qiniu ====================="
qshell qupload qiniu.conf

# No need deploy to github
# hexo d
# echo "===================== Deploy to github success ====================="
