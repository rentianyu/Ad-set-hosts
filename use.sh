# 使用小贝塔hosts
su -c '
( mount --remount -w /system || mount --remount -w / )&&
rm /system/etc/hostsold
curl -L https://raw.githubusercontent.com/rentianyu/Ad-set-hosts/master/hosts > /system/etc/hosts &&
( mount --remount -r /system || mount --remount -r / )&&
echo "操作成功..."||echo "操作失败..."
'