#!/bin/env fish
# 下载去广告hosts合并并去重

set r raw
set h host
set hs hosts
set hs6 hosts6
set adg adguard

# 手机edege浏览器Adblock Plus
curl -s https://edge.microsoft.com/abusiveadblocking/api/v1/blocklist | jq -r '.sites[].url' > edge_phone/$hs
sed -i "s/^/127.0.0.1 /g" edge_phone/$hs

# iOSAdblockList：https://github.com/BlackJack8/iOSAdblockList
curl -s https://raw.githubusercontent.com/BlackJack8/iOSAdblockList/master/Regular%20Hosts.txt > iOSAdblock/$hs
sed -i "s/^/127.0.0.1 /g" iOSAdblock/$hs

# 下载abp 规则到ab
rm -f ab/$hs
for i in (grep ^http hosts-ab.list)
  curl -s "$i" >> ab/$hs
  echo $i
end

# 转换换行符
dos2unix */*

# 提取host
sed -ni 's/^||\(.*\)\^$/\1/p' ab/$hs

# 删除含有特殊字符的行
sed -i '/\(。\|\/\|@\|*\|\:\)/d' ab/$hs

# 去重
sort -u ab/$hs -o ab/$hs

# 变成标准host
sed -i "s/^/127.0.0.1 /g" ab/$hs

# 下载原始 hosts 到 raw
rm -f $r
for i in (grep ^http hosts.list)
  curl -s "$i" >> $r
  echo $i
end

# 合并整理的 host
cat */$hs >> $r
echo -n "只合并行数：" && wc -l $r

# 转换换行符
dos2unix *
dos2unix */*

# 准备纯域名 host
cp $r $h

# 删除空白符和 # 及后
sed -i "s/\s\|#.*//g" $h

# 保留 127.0.0.1、0.0.0.0 开头的行，
# sed -i "/^\(127.0.0.1\|0.0.0.0\)/!d" $h

# 删除127.0.0.1、0.0.0.0
sed -ni "s/^\(127.0.0.1\|0.0.0.0\)//p" $h

# 删除含有特殊字符的行
sed -i '/\(。\|\/\|@\|*\|\:\)/d' $h

# 删除没有.的行
sed -i '/\./!d' $h

# 保留 0-9a-zA-Z 开头的行
sed -i "/^[0-9a-zA-Z]/!d" $h
echo -n "清洗后域名数：" && wc -l $h

# 排序去重 获得标准去重版 host
sort -u $h -o $h

echo -n "去重后（去除误杀前）域名数：" && wc -l $h

# 去除误杀
for i in (cat white.list)
  sed -i "/$i/d" $h
end
echo -n "最终域名数：" && wc -l $h

# 使用声明
set statement "# "(date '+%Y-%m-%d %T')"\n# 小贝塔自用，请勿商用\n# 项目地址：https://github.com/rentianyu/Ad-set-hosts\n\n127.0.0.1 localhost\n127.0.0.1 localhost.localdomain\n127.0.0.1 local\n255.255.255.255 broadcasthost\n::1 localhost\n::1 ip6-localhost\n::1 ip6-loopback\nfe80::1 localhost\nff00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts\n"

# 获得标准版 hosts
cp $h $hs
sed -i "s/^/127.0.0.1 /g" $hs
sed -i "1 i $statement" $hs

# 获得ipv4、ipv6版 hosts
cp $h $hs6
sed -i "s/^/::1 /g" $hs6
cat $hs >> $hs6
# sort $hs6 -o $hs6
sed -i "1 i $statement" $hs6


# 获得 adguard 版规则
cp $h $adg
sed -i '1d;s/^/||/g;s/$/^/g' $adg

# 查看文件大小
echo 查看文件大小 > info.txt
du -sh * >> info.txt

# 查看每个文件行数
echo -e '\n一级文件行数：' >> info.txt
wc -l * >> info.txt
echo -e '\n二级文件行数：' >> info.txt
wc -l */* >> info.txt


