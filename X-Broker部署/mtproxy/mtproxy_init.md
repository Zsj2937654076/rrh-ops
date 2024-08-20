# mtproxy

## 一、检查资源

## 二、创建MTPROXY服务

复制 `C:\Workspace\mt-proxy` 路径下的 `MT-PROXY-template` 文件

### 修改配置

1. 修改复制的文件夹

2. 进入vhost -> running

   1. 把 `abc.com.tcf` 文件改名为 `admin.shangdingfinance.com.tcf`

   2. 修改案例如下：

      ```shell
      {"vhost":"admin.shangdingfinance.com","expireTime":"2024-10-18 23:59:59","expireNotice":true,"mapCrmInfo":{}}
      ```

      vhost：就是admin的域名

      expireTime：一般为部署时间往后推移3个月

3. 前往知识库查询接口

   1. `http://192.168.199.209:88/project/14?p=165`

4. 回到 `C:\Workspace\mt-proxy\MT-PROXY-xxxx`路径下

   1. 编辑修改 CrmGuard.ini  CrmMT.ini  CrmMT4.ini 三个文件内容

   CrmGuard.ini 配置模板修改地方

   ```shell
   [crmserver]
   crmhost=http://127.0.0.1:8088
   noticehost=https://tickets.voov.cc/
   noticeappid=G2F38CH0
   noticeappkey=Ulr0my8j1Dlj9jkuJdQEGvLyS5OHP3y1
   
   [crmguard]
   port=#知识库那边规划的端口  比如是47000-47999 那这里就填 47000#
   mtlistenip=127.0.0.1
   startport=#知识库那边规划的端口  比如是47000-47999 那这里就填 47001#
   endport=#知识库那边规划的端口  比如是47000-47999 那这里就填 47999#
   expiretime=7
   aeskey=bbe547317d210b6a3f0ec41fa4daec8d
   aesiv=KmSGWlDMmixhVEIA
   debuglog=0
   
   [redis]
   host=localhost:#redis的端口号#
   index=#redis的库
   pwd=#redis的密码 一般是 dsocredis
   
   [app]
   appid=CSMFF2TVBSVSDFGKFDGDF
   [manager]
   dingtoken=114894f45c7c9ce1fd73e55eeb0f7484d65e4fd5234a7fab115a4d6e0b8e8959
   generkey=b05b84d70b1a76d81ed035
   ```

   CrmMT.ini

   ```shell
   [serverinfo]
   vhost=#后端的admin域名  eg：admin.shangdingfinance.com#
   scode=1a2b3c
   
   [orderhub]
   host=127.0.0.1
   port=38010
   
   [redis]
   redisHost=127.0.0.1
   redisPort=#redis的端口号#
   redisPwd=#redis的密码 一般是 dsocredis
   redisIndex=#redis的库
   
   [sync]
   syncOneTime=10000
   compressLevel=2
   ```

   CrmMT4.ini

   ```shell
   [serverinfo]
   vhost=#后端的admin域名  eg：admin.shangdingfinance.com#
   scode=1a2b3c
   
   [orderhub]
   host=127.0.0.1
   port=38010
   
   [redis]
   redisHost=127.0.0.1
   redisPort=#redis的端口号#
   redisPwd=#redis的密码 一般是 dsocredis
   redisIndex=#redis的库
   
   [sync]
   syncOneTime=10000
   compressLevel=2
   ```

### 设置开机自启

切换到 `C:\Workspace\tools` 路径下 在该路径下以管理员身份启动 `cmd` 执行命令，生成系统服务（在资源管理器的服务中查看）

```shell
C:\Workspace\tools\instsrv.exe MT-PROXY-xxxx C:\Workspace\tools\srvany.exe
```

![size:800,1000](http://192.168.199.209:88/storage/2024/01-03/yOvVzoLzmAChFXdGgtTuKgSICJQBugmtB3szrhoA.png)

如图则成功！

然后在cmd中输入：`regedit`

\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services

ctrl+F，搜索 `MT-PROXY-xxxx`（之前自定义的服务名称）

然后新建项，名称为`Parameters`

​	在Parameters中新建几个字符串值

​		名称 Application 值：你要作为服务运行的程序地址。`C:\Workspace\mt-proxy\MT-PROXY-shangding\CrmGuard.exe`

​		名称 AppDirectory 值：你要作为服务运行的程序所在文件夹路径。`C:\Workspace\mt-proxy\MT-PROXY-shangding`

​		名称 AppParameters 值：你要作为服务运行的程序启动所需要的参数。`放空不填`

### 查看日志

查看日志`/workspace/mt-proxy/mtproxy-<CUSTOMER_SHORT_NAME>/logs/*-info.log`文件

## 三、生成ssl证书

1. 切换到 `C:\Workspace\Program Files\nginx-1.20.1\conf\vhost`
2. 复制一份conf文件，然后改名
3. 先把nginx的配置文件修改以及注释，让他先拿到证书
4. 
   <img src="C:\Users\rrh\AppData\Roaming\Typora\typora-user-images\image-20240718112503489.png" alt="image-20240718112503489" style="zoom: 67%;" />
5. 资源管理器杀掉nginx进程，然后重启nginx（nginx一般是只有两个进程）
6. `certbot certonly --webroot -d mtproxy-xxxxx.voov.cc -w "C:\Workspace\Program Files\nginx-1.20.1\certbot"`
7. 获取成功后，回去把nginx的配置改回来
   1. listen 443后面加上ssl
   2. 取消两个注释
8. 资源管理器杀掉nginx进程，然后重启nginx

