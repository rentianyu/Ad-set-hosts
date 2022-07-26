# 复制hosts到手机系统
su -c 'mount -o rw,remount /system&&cp -f ./hosts /system/etc/hosts&&mount -o ro,remount /system&&echo "操作成功..."||echo "操作失败..."'