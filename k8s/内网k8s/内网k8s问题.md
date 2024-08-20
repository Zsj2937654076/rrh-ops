# 内网k8s问题

## 一、saas网站的ssl证书问题

因为容器nginx-ingress的nginx默认配置文件是在容器中，所以容器自启的时候就会刷新我们修改过的内容，但是用挂载的方式将/etc/nginx路径挂载进去会造成容器无法启动，所以暂时的方法是设置定时任务cp文件去覆盖容器内部里面的配置文件。

```shell
# kvm-11 192.168.199.11 服务器
# 到配置文件的目录下  文件：xbroker-xbroker-ingress.conf
cd /etc/kubernetes

# 到定时任务下
# 定时任务文件：k8s_ssl
cd /etc/cron.d

#复制的脚本
/etc/kubernetes/k8s_ssl.sh
```

