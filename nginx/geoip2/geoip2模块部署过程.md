# nginx使用geoip2

[TOC]

### 目录规划

```shell
#源代码
/usr/src
	libmaxminddb-1.5.2
	ngx_http_geoip2_module
	openssl-1.1.1j
	pcre-8.44
	zlib-1.2.11
	nginx-1.20.1
#配置文件
/etc/nginx
```

## 第一步：检查需要的依赖

### 安装[libmaxminddb](https://github.com/maxmind/libmaxminddb)

```shell
#源文件的路径规划
cd /usr/src

#下载安装包
wget https://github.com/maxmind/libmaxminddb/releases/download/1.5.2/libmaxminddb-1.5.2.tar.gz

#解压文件，进入目录
tar zxvf libmaxminddb-1.5.2.tar.gz
cd libmaxminddb-1.5.2/

#编译安装
./configure
make
make check
make install
ldconfig
```

## 第二步：下载 pcre 、 zlib 和 openssl

### 下载解压

```shell
#源文件的路径规划
cd /usr/src

#下载下载 pcre 、 zlib 和 openssl
wget https://sourceforge.net/projects/pcre/files/pcre/8.44/pcre-8.44.tar.gz
wget https://www.openssl.org/source/openssl-1.1.1j.tar.gz
wget https://zlib.net/fossils/zlib-1.2.11.tar.gz
tar zxvf pcre-8.44.tar.gz
tar zxvf openssl-1.1.1j.tar.gz
tar zxvf zlib-1.2.11.tar.gz
```

## 第三步：nginx添加模块的相关前置操作

### 检查nginx

```shell
#检查nginx带有哪些modules以及版本
nginx -V
```

### 下载 nginx 源码

```shell
#源文件的路径规划
cd /usr/src

#根据原本的nginx的版本去下载，这里使用的是 1.20.1 版本
wget https://nginx.org/download/nginx-1.20.1.tar.gz
tar zxvf nginx-1.20.1.tar.gz
```

### 下载ngx_http_geoip2_module

```shell
#下载groip2模块
wget https://github.com/leev/ngx_http_geoip2_module/archive/3.3.tar.gz
tar zxvf 3.3.tar.gz
#修改名称
mv ngx_http_geoip2_module-3.3 ngx_http_geoip2_module
```

### 开始进行编译

```shell
#进入源码目录
cd nginx-1.20.1/

#建议再次查看modules
nginx -V

#检查nginx中所需要的modules
./configure                                             \
--with-pcre=/usr/src/pcre-8.44                       \
--with-zlib=/usr/src/zlib-1.2.11                     \
--with-openssl=/usr/src/openssl-1.1.1j               \
--add-dynamic-module=/usr/src/ngx_http_geoip2_module \
--with-stream                                           \
--with-http_ssl_module                                \
--with-compat

#复制 configure arguments 的值，当前所带有的modules如下：

--prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-compat --with-debug --with-file-aio --with-google_perftools_module --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_degradation_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_perl_module=dynamic --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_xslt_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-threads --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic' --with-ld-opt='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E'

#在上述modules的基础上添加geoip2所需的modules
./configure --with-pcre=/usr/src/pcre-8.44 --with-zlib=/usr/src/zlib-1.2.11 --with-openssl=/usr/src/openssl-1.1.1j --add-dynamic-module=/usr/src/ngx_http_geoip2_module --with-stream --with-compat --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-debug --with-file-aio --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_degradation_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-threads

#make一下
make
```

## 第四步：加载模块

```shell
#创建一个存放模块的地方
mkdir /etc/nginx/dynamic-modules

#把/usr/src/nginx-1.20.1/objs路径下的*.so文件放到/etc/nginx/dynamic-modules/
cd objs
mv *.so /etc/nginx/dynamic-modules/
cd /etc/nginx
```

## 第五步：新创建一个存放模块的配置文件

```shell
#可以在 /etc/nginx下创建modules.conf

# Maxmind GeoIP2
load_module dynamic-modules/ngx_http_geoip2_module.so;
load_module dynamic-modules/ngx_stream_geoip2_module.so;

#在nginx.conf中加载这个配置文件
include modules.conf
```

## 注意事项：

### nginx的版本为1.20.x的默认路径不同

```shell
#nginx默认路径不是/etc/nginx，所以软链接过去
ln -sf /etc/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf

#停止旧的nginx
ps aus|grep nginx
kill -9 xxxx

#更换nginx执行文件
mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.old
mv objs/nginx /usr/local/nginx/sbin/nginx

#启动新的nginx
cd /sbin
./nginx

#检查nginx是否替换成功
nginx -V
```























