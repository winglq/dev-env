# blkio sub system test.
The test script is as following. Proportional controll does not work on devices
which has LVs sitting on them.

```shell
#!/usr/bin/bash
mkdir -p /sys/fs/cgroup/blkio/test1/ /sys/fs/cgroup/blkio/test2
echo 1000 > /sys/fs/cgroup/blkio/test1/blkio.weight
echo 500 > /sys/fs/cgroup/blkio/test2/blkio.weight
#echo 252:1 20971520 > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
sync
echo 3 > /proc/sys/vm/drop_caches
dd if=/mnt/lvol0/zerofile of=/dev/null &
echo $! > /sys/fs/cgroup/blkio/test1/tasks
cat /sys/fs/cgroup/blkio/test1/tasks
echo "dd1 task written"
dd if=/mnt/lvol1/zerofile1 of=/dev/null &
echo $! > /sys/fs/cgroup/blkio/test2/tasks
cat /sys/fs/cgroup/blkio/test2/tasks
echo "dd2 task written"
```

[blkio cgroups controller doesn't work with LVM](https://www.redhat.com/archives/dm-devel/2016-February/msg00192.html)
