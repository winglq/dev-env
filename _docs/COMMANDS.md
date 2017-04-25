## Commands table
|COMMAND             |DESCRIPTION                     |RPM package           |
|:-------------------|:-------------------------------|:---------------------|
|netstat -anpt       |check listening port            |net-tools             |
|yum whatprovides pkg|find pkg name                   |                      |

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
