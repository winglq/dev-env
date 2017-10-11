# Python使用openssl制作的CA证书

## 证书制作

使用下面的脚本生成证书。运行成功会在当前路径下生成domain.key和domain.crt

```bash
generate_cert_file.sh ip1 ip2 ip3
```

**generate_cert_file.sh** 内容如下，需要先将req_distinguished_name section中的内容填完:

```bash
#!/usr/bin/bash

cat > openssl.conf << EOF
[req]
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req


[req_distinguished_name]
countryName = CN
stateOrProvinceName =
localityName =
organizationName =
organizationalUnitName =
commonName =

[v3_req]
basicConstraints = CA:TRUE
subjectAltName = @alt_names

[alt_names]
EOF

export i=1
for var in "$@"
do
  echo "IP.$i = $var" >> openssl.conf
  echo "DNS.$i = $var" >> openssl.conf
  i=$(($i + 1))
done

openssl req -newkey rsa:2048 -nodes -keyout domain.key \
            -config openssl.conf \
            -extensions v3_req \
            -x509 -days 3650 -out domain.crt

rm -f openssl.conf
```

subjectAltName 可以给host提供别名，以便多在同一个域名使用多个IP时可以一同验证IP地址。

## gunicorn使用CA认证

pastedeploy 配置如下
```
[server:main]
use = egg:gunicorn#main
keyfile = /path/to/domain.key
certfile = /path/to/domain.crt
```

## requests使用CA认证

```python
import requests
requests.get("https://127.0.0.1:4000/server",
             verify="/path/to/domain.crt")
```

