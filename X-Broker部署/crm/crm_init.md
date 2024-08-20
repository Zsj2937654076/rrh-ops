# crm

## 一、部署前置准备

### 1.购买服务器 获得服务器IP 设置安全组

```shell
103.179.243.121/32	开放22、3306、15672端口

117.24.0.0/16		开放22、3306、15672端口

0.0.0.0/0			开放80、443端口
```

### 2.运营部域名解析

```shell
#获得如下域名：
用户端：client.shangdingfinance.com
管理端：admin.shangdingfinance.com
```

### 3.运维部域名解析

1. 在  https://dash.cloudflare.com/login  进行域名解析

   <img src="C:\Users\rrh\AppData\Roaming\Typora\typora-user-images\image-20240718135829385.png" alt="image-20240718135829385" style="zoom: 50%;" />

### 4.阿里云白名单添加

这一步需要在脚本运行前完成，否则无法wget

## 二、config.ini 模板修改

```shell
admin_domain="admin.shangdingfinance.com"	#运营部获得的后端域名
user_url="https://client.shangdingfinance.com/"	#运营部获得的客户端端域名
hostname=shangding	#客户名称
guard="https://mtproxy-shangding.voov.cc"	#更换中间的客户名称
mt_host="http://mtproxy-shangding.voov.cc"	#更换中间的客户名称
email="2508030819@qq.com"	#更换为客户邮箱
mymate_ack="TjFkGtRpMpMAzhgi"	#请求获取
mymate_sck="345011fdda4dac8692d0caf78b470ac5"	#请求获取
mymate_url="https://api.haame.com:9443"
crm_directory="/workspace/websites/crm"
script_directory="/workspace/scripts/"
jar_directory="${crm_directory}/jar"
release_directory="${crm_directory}/release"
static_directory="${crm_directory}/static"
log_directory="${crm_directory}/logs"
sql_directory="/workspace/mysql_backup/"
image_directory="${crm_directory}/jar/projects/static"
cssd_directory="${crm_directory}/jar/projects/static/cssd"
program_log_directory="/workspace/logs"
certbot_directory="${crm_directory}/.well-known"
user_domain=`echo ${user_url}|sed 's/https:\/\/\|http:\/\///'|sed 's/\///'`
```

mymate_ack和mymate_sck两个通过curl请求获取

```shell
http://39.108.186.19:8000/register
{
        "owner": "shangding",
        "mt_domain": "mtproxy-shangding.voov.cc"
}
```

## 三、上传config.ini 和 部署脚本

config.ini模板已经修改为：

```shell
admin_domain="admin.shangdingfinance.com"	#运营部获得的后端域名
user_url="https://client.shangdingfinance.com/"	#运营部获得的客户端端域名
hostname=shangding	#客户名称
guard="https://mtproxy-shangding.voov.cc"	#更换中间的客户名称
mt_host="http://mtproxy-shangding.voov.cc"	#更换中间的客户名称
email="2508030819@qq.com"	#更换为客户邮箱
mymate_url="https://api.haame.com:9443"
crm_directory="/workspace/websites/crm"
script_directory="/workspace/scripts/"
jar_directory="${crm_directory}/jar"
release_directory="${crm_directory}/release"
static_directory="${crm_directory}/static"
log_directory="${crm_directory}/logs"
sql_directory="/workspace/mysql_backup/"
image_directory="${crm_directory}/jar/projects/static"
cssd_directory="${crm_directory}/jar/projects/static/cssd"
program_log_directory="/workspace/logs"
certbot_directory="${crm_directory}/.well-known"
user_domain=`echo ${user_url}|sed 's/https:\/\/\|http:\/\///'|sed 's/\///'`
```

简化了mymate_ack、mymate_sck、app_id、app_key,这些由手动输入换成脚本自动生成

增加了email（为了实现数据库user表的修改）

其他有注释的参数需要根据每个客户的信息进行修改填写

## 四、运行部署脚本

将`config.ini`和`crm_install_aws_new.sh`上传到要部署的服务器的根目录

然后`sh crm_install_aws_new.sh`

## 五、查看服务

```shell
supervisorctl status #查看服务，需要4个都在running
```

## 六、ssl证书

需要先把`/etc/nginx/vhost`路径下的admin.xxxxxxx.com.conf备份

```shell
mv admin.<xxxxxxxx>.com.conf admin.<xxxxxxxx>.com.conf.bak
mv client.<xxxxxxxx>.com.conf client.<xxxxxxxx>.com.conf.bak
touch test.com.conf
vim test.com.conf
```

```shell
#在test.com.conf写入
server{
        listen 80;
        server_name admin.<xxxxxxxx>.com client.<xxxxxxxx>.com.conf;
        location /.well-known {
            root /workspace/websites/crm/;
        }
}
```

```shell
nginx -t
nginx -s reload
```

然后执行命令获取证书

```shell
#请求admin和client的证书
certbot certonly --webroot -d admin.shangdingfinance.com -w /workspace/websites/crm --register-unsafely-without-email
certbot certonly --webroot -d client.shangdingfinance.com -w /workspace/websites/crm --register-unsafely-without-email
```

```shell
#成功之后把备份的改回来
mv admin.<xxxxxxxx>.com.conf.bak admin.<xxxxxxxx>.com.conf
mv client.<xxxxxxxx>.com.conf.bak client.<xxxxxxxx>.com.conf
rm -f test.com.conf
nginx -t
nginx -s reload
```

## 查看日志是否中文乱码

```shell
#乱码解决
yum  install kde-l10n-Chinese -y
yum reinstall glibc-common -y

#可以查看当前使用的系统语言
echo$LANG

#修改
vim /etc/locale.conf
LANG="zh_CN.utf8"

#重启服务器  慎重！！！
reboot
```

## 重启服务

```shell
#查看服务是否running
supervisorctl status all

#没有就启动
supervisorctl start all
```

