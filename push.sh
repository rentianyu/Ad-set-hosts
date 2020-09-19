# 推送到Git
sed -i -e "1i \# `date '+%Y-%m-%d %T'`" ./hosts && git add . && git commit -m " `date '+%Y-%m-%d %T'` add my ad hosts " && git push && echo -e " `date '+%Y-%m-%d %T' ` push成功"
