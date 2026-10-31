#!/bin/env fish
# 下载去广告hosts合并并去重

set h host
set hs hosts
set hs6 hosts6
set adg adguard

# 准备环境
mkdir -p raw
rm -f raw/*
rm -f *adg*
rm -f *host*

# 手机edege浏览器Adblock Plus
echo 1.edge_phone
curl -s https://edge.microsoft.com/abusiveadblocking/api/v1/blocklist | jq -r '.sites[].url' > raw/edge_phone.host
sed -i "s/^/127.0.0.1 /g" raw/edge_phone.host

# iOSAdblockList：https://github.com/BlackJack8/iOSAdblockList
echo 2.iOSAdblock
curl -s https://p.xbta.cc/https://raw.githubusercontent.com/BlackJack8/iOSAdblockList/master/Regular%20Hosts.txt > raw/iOSAdblock.host
sed -i "s/^/127.0.0.1 /g" raw/iOSAdblock.host

# 下载abp 规则到abp
set n 3
for i in (grep ^http rules.txt)
  set name (echo "$i" | sed 's/.* //')
  set url (echo "$i" | sed 's/ .*//')
  echo $n.$name
  set n (math $n + 1)
  curl -sL "$url" > raw/$name
#   curl -sL "https://p.xbta.cc/$url" > raw/$name
end

# 转换换行符
dos2unix -q *
dos2unix -q */*

# 先处理adg
# cat raw/*adg > all.adg
cp -f all.adg adg.host

# 提取adg.host
sed -n '/^||.*\^$/p' all.adg > adg_raw.adg
# sleep 12000
# 获取adg提取的所有host（含有特殊符号，不纯）
sed -ni 's/^||\(.*\)\^$/\1/p' adg.host

# 准备纯域名 host
cat raw/*host > host.host

# 删除空白符和 # 及后
sed -i "s/\s\|#.*//g" host.host

# 删除127.0.0.1、0.0.0.0，获得hosts.host
sed -ni "s/^\(127.0.0.1\|0.0.0.0\)//p" host.host

# 合并adg和hosts的host
cat adg.host host.host > $h

# 删除含有特殊字符的行
sed -i '/\(。\|\/\|@\|*\|\:\|-$\|_\)/d' $h

# 删除没有.的行
sed -i '/\./!d' $h

# 大写转换为小写
sed -i 's/[A-Z]/\L&/g' $h

# 保留 0-9a-z 开头的行
sed -i "/^[0-9a-z]/!d" $h
echo -n "清洗后域名数：" && wc -l $h

# 排序去重 获得标准去重版 host
sort -u $h -o $h

echo -n "去重后（去除误杀前）域名数：" && wc -l $h

# 去除误杀
for i in (cat white.list)
    echo "======$i======"
    grep $i $h
    echo "-.-.-$i-.-.-"
    grep -r $i raw $h
    sed -i "/$i/d" $h
    echo -e "\n--------------------------------\n" 
end > white_del.list
# end|tee white_del.list

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
cat $hs >>$hs6
# sort $hs6 -o $hs6
sed -i "1 i $statement" $hs6


# 获得 adguard 版规则
cp $h $adg
sed -i '1d;s/^/||/g;s/$/^/g' $adg

# 查看文件大小
echo 查看文件大小 >info.txt
du -sh * >>info.txt

# 查看每个文件行数
echo -e '\n一级文件行数：' >>info.txt
wc -l * >>info.txt
echo -e '\n二级文件行数：' >>info.txt
wc -l */* >>info.txt

