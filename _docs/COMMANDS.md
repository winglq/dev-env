## Commands table
|COMMAND             |DESCRIPTION                     |RPM package           |
|:-------------------|:-------------------------------|:---------------------|
|netstat -anpt       |check listening port            |net-tools             |
|yum whatprovides pkg|find pkg name

---

## Configure
### Add pip repo
编辑/创建文件/etc/pip.conf，填入下面内容：
```
[global]
index-url = http://pmo02.chinac.com:8001/simple
extra-index-url = https://pypi.python.org/simple

[install]
trusted-host = pmo02.chinac.com
```

#### Repos
- index-url = http://pypi.douban.com/simple  豆瓣
- index-url = http://mirrors.aliyun.com/pypi/simple

---

### Persistent mount point after reboot
$ cat /etc/fstab
```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
#UUID=c3699352-2b1d-43ca-9f75-82205697ef08 /               ext4    errors=remount-ro 0       1
/dev/vda1                               /               ext4    defaults        0       1
/dev/vdb1                               /mnt            ext4    defaults        0       1
```
