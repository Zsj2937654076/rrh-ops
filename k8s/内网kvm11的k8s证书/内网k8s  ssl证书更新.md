# 内网k8s  ssl证书更新



```shell
#1.将宿主机的ssl证书所在路径以卷的形式挂载到k8s的nginx-ingress容器中

#2.将容器内的nginx配置cp出来进行修改
docker ps|grep  nginx-ingress

docker cp <容器id>:/etc/nginx/conf.d/xbroker-xbroker-ingress.conf /etc/kubernetes

#3.将修改后的nginx配置cp回去覆盖

# ssl_certificate /etc/letsencrypt/live/hcs55.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/hcs55.com/privkey.pem;


kubectl cp /etc/kubernetes/xbroker-xbroker-ingress.conf <容器id>:/etc/nginx/conf.d/

#4.重启nginx
nginx -t
nginx -s reload
```

注意：宿主机的ssl证书所在路径至少要有 读的权限
