# grafana+prometheus

```shell
grafana+prometheus   192.168.199.232
systemctl status prometheus
--------------------------------------------------------
#prometheus位置  端口：9090
#原promethues位置： /usr/local/prometheus
--------------------------------------------------------
Alertmanager 告警通知插件
192.168.199.232:9093
--------------------------------------------------------
Grafana
192.168.199.232:3000
--------------------------------------------------------
node1
ip：192.168.199.233:9101
--------------------------------------------------------
安装部署教程文档
https://www.cnblogs.com/JIKes/p/18183559
```



### node-exporter 部署

```shell
#拉取node-exporter安装包
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz

#下载慢可以换 wget https://githubfast.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar -zvxf node_exporter-1.4.0.linux-amd64.tar.gz   -C /usr/local/
cd /usr/local
mv node_exporter-1.4.0.linux-amd64 node_exporter


#systemctl 管理 node_exporter
vi /usr/lib/systemd/system/node_exporter.service
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
[Unit]
Description=node_exporter
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/node_exporter/node_exporter --web.listen-address=:9101
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


#热加载 prometheus 配置
curl  -X POST http://127.0.0.1:9090/-/reload
```

