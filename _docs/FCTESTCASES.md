# FC存储设备测试方案

-----------------------

1. Host端存储路径切换（模拟路径损坏）
  - 断开Host端的第一个FC PORT
  - 检查多路径的路径，有一半处于fail状态,[命令](#cmd)
  - [Openstack正常功能可用](#OpenstackTests)
  - 重新连接，恢复路径，所有路径变成active running状态,[命令](#cmd)
  - 断开Host端的第二个FC PORT
  - [Openstack正常功能可用](#OpenstackTests)
  - 检查多路径的路径，另一半处于fail状态,[命令](#cmd)
  - 重新连接，恢复路径，所有路径变成active running状态,[命令](#cmd)

2. Storage端存储路径切换（模拟存储单机头损坏）
  - 断开连接到存储（双机头存储）一个机头的所有路径
  - 检查多路径的路径，有一半处于fail状态,[命令](#cmd)
  - [Openstack正常功能可用](#OpenstackTests)
  - 重新连接，恢复路径，所有路径变成active running状态,[命令](#cmd)
  - 断开连接到存储（双机头存储）另外一个机头的所有路径
  - 检查多路径的路径，另一半处于fail状,[命令](#cmd)态
  - [Openstack正常功能可用](#OpenstackTests)
  - 重新连接，恢复路径，所有路径变成active running状态,[命令](#cmd)

3. Storage机头重启（模拟存储单机头损坏）**可选**
  - 关闭一个存储机头
  - 检查多路径的路径，有一半处于fail状态,[命令](#cmd)
  - [Openstack正常功能可用](#OpenstackTests)
  - 启动关闭的机头,所有路径变成active running状态,[命令](#cmd)
  - 关闭另一个存储机头
  - 检查多路径的路径，另一半处于fail状态,[命令](#cmd)
  - [Openstack正常功能可用](#OpenstackTests)
  - 启动关闭的机头,所有路径变成active running状态,[命令](#cmd)

------------------

<span id="OpenstackTests">Openstack正常功能可用</span>

- 创建删除新虚拟机
- 挂盘解挂
- hard reboot虚拟机
- 热迁移。 **如果多路径环境只有两条路径，不能跑这个test case， 原因见:** 
[热迁移失败BUG](http://jira.chinac.com/browse/PRIVATEC-3342)
- 冷迁移
- 故障恢复

<span id='cmd'>Multipath命令</span>
第一条为查看所有LUN的多路径状态，第二条为查看单个LUN的多路径状态
```
multipath -ll
multipath -ll UUID
```
