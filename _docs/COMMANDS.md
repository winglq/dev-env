## Commands table
|COMMAND             |DESCRIPTION                     |
|:-------------------|:-------------------------------|
|yum whatprovides cmd|find pkg name
|netstat -anpt       |check listening port            |
|git reflog          |list all refs|
|git reset --hard commit_id   | reset to commit_id|
|rpm2cpio filename &verbar;  cpio -idmv|find files in rpm pkg| 
|yumdownloader --urls pkg_name | get package url|
|yumdownloader --resolve pkg_name | download package|
|yum --disablerepo="*" --enablerepo="repo" install pkg|yum use repo to install|
|lsblk -d -o name,rota | find all disk and whether they are ssd|
|du -s /path/to/dir | list physical file size in dir|
|patch -p1 < patch_name | patch file|
|vim -c 'goto 20' |goto byte 20|
|vim +linenum filename | goto linenum|
|cat /proc/pid/limits|check process resource limit|
|prlimit -p pid|check process resource limit|
|/lib/udev/scsi_id --page '0x83' --whitelisted path|get disk uuid|
|echo 1 > /sys/bus/scsi/drivers/sd/x:x:x:x/delete|delete disk
|echo '- - -' > /sys/class/scsi_host/hba_host_dev/scan|rescan fc device
|systool -c fc_host -v|check fibre channel device info


---

## Configure or big command

### Add pip repo
编辑/创建文件/etc/pip.conf，填入下面内容：
```
[global]
index-url = http://pypi.douban.com/simple
extra-index-url = https://pypi.python.org/simple

[install]
trusted-host = pypi.douban.com
```

#### Repos
- index-url = http://pypi.douban.com/simple  豆瓣
- index-url = http://mirrors.aliyun.com/pypi/simple 阿里云

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
---

### Remove interface(qvocd4f9cc5-e8) and add to another ovs br
```shell
ovs-vsctl del-port br-int qvocd4f9cc5-e8
ovs-vsctl add-port br-flat qvocd4f9cc5-e8
ovs-ofctl dump-flows br-int
```

---

### glance image upload example
```shell
glance image-create --name centos2 --disk-format raw --container-format bare \
    --file name.img --progress
```

### push tag to repo
```shell
git tag -am "2016.3.RC1" 2016.3.RC1
git push gerrit 2016.3.RC1
```
### sql update cinder service table
```sql
mysql -e "update services set deleted = 1 where host like 'controller%' and disabled = 1 " cinder -u cinder -p
```

---

### OoO network setting
change the following config
```
vim /etc/neutron/plugins/ml2/linuxbridge_agent.ini
```
firewall_driver = noop
prevent_arp_spoofing = False

remove flows
```shell
iptables -F
```

### debug network by tcpdump
```shell
tcpdump -i tap3692138a-69 -exx -n
```

---

### alter RETENTION 
```
ALTER RETENTION POLICY default ON stackwatch DURATION 60d REPLICATION 1 DEFAULT
```

---

### enable cinder notification /etc/cinder/cinder.conf
```
[oslo_messaging_notifications]
driver=messaging
```
