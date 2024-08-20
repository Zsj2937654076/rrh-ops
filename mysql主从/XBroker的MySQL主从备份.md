# XBroker的MySQL主从备份

[TOC]

## 名词解释

- **REPL服务器**：指用于备份数据库的服务器，是Haame提供的共享服务器
- **TENANT服务器**：指租户的服务器，可以是租户自购的，也可以是Haame提供的，往往都是一个租户一台独立服务器，部署有独立的数据库


## 架构设计

租户的环境大部分是在独立的服务器上部署一个数据库，而主从备份的数据库都将以容器的方式部署在Haame的某台服务器上，往往一台服务器上会部署有多个不同租户**独立的备份从库**，同时也会为每个备份从库**独立分配一块磁盘**，并将磁盘挂载给对应租户的备份从库容器实例上。

![size:800,1000](http://192.168.199.209:88/storage/2024/08-14/H2izPV40jOlxccMnGRFtAnzOtReNrJlLnB8N826S.png)



## 过程

- 准备工作
	- Repl服务器环境配置（仅新机情况）
	- Tenant服务器配置
	- Repl服务器分配租户资源
- Tenant服务器上的主库
	- 在`my.cnf`文件中配置主从同步
	- 创建`'repl_<tenant>'@'<repl_ip>'`账号
	- 停止XBroker服务（推荐）
	- 锁定数据库
	- 获取当前的二进制日志文件的名称和位置
	- Dump数据库快照
	- 解锁数据库
	- 压缩快照文件
- Repl服务器上的从库
	- 从Tenant服务器拉取快照文件
	- 创建`mysql-<tenant>-slave`容器（此步骤开始可以直接使用自动化脚本）
	- 设置从库root账号密码
	- 导入数据库快照
	- 配置同步信息
	- 启动同步
- Repl服务器上的备份和监控
	- 本地每天全量备份
	- 磁盘监控（未实现）
	- 同步异常监控（未实现）
- 健康审计
	- 检查验证
		- 同步是否正常
		- Binlog文件
		- Dump文件
		- CRM测试验证
	- 结尾清理
- 扩容
	- 停机操作
	- 启动操作
	- 调整磁盘大小



## 部署步骤

配置一个已经有数据的 MySQL 数据库的主从同步，你需要按照以下步骤操作：

#### 准备工作

###### REPL服务器新机环境

如果是非新机环境可以跳过该步骤。

在云平台上（如GCP），购买新REPL服务器实例时，需要注意以下几点：
- 操作系统：默认Debian
- 命名：`instance-<yyyymmdd>-xbroker-repl`
- 参考类型：**e2-standard-4**
- 可用区：根据实际需求
- 标签：
	- `instance-for` : `repl`
	- `instance-product` : `xbroker`
	- `instance-type` : `mysql`
- 预留静态IP
- **网络标记**（类似于安全组）：`xbroker-tenant-db-repl-ssh`
- 启动盘：100G
- 租户盘：每个租户独立拥有一个100G的SSD挂载盘
	- 设备名称：`disk-<tenant>`
	- 类型：SSD 永久性磁盘
	- 大小：100G
	- 标签：
		- `disk-for` : `repl`
		- `disk-tenant` : `<tenant>`

实例创建好后，登录到服务器进行以下操作：
0. 登录，在授权的电脑上生成SSH密钥，然后将公钥配置到GCP的repl虚拟机实例中，并防火墙放行IP
```shell
# 生成ssh密钥
ssh-keygen -t rsa -C <tenant>@xbroker.com -b 4096
# PW：为密钥文件设置一个密码

# 将公钥添加到GCE上
cat .ssh/id_rsa.pub

# 获取公网IP，并在GCE上repl实例防火墙施行该ip访问ssh
curl ipinfo.io
```


1. 安装Dockers环境
```shell
# Centos
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
#
# Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
更多参考：[[Docker 常用命令#docker安装]]

2. xbroker-mysql-slave镜像制作：[[XBroker部署-Docker方案]]
```shell
umask 077
mkdir /workspace/data/xbroker-mysql-slave
cd /workspace/data/xbroker-mysql-slave
#
# 添加文件
nano Dockerfile
nano my.cnf
nano start.sh
nano base.sql
#
# 构建镜像
docker build -t xbroker-mysql-slave .
```

相关文件内容，查阅`op-project-script`项目下的`CRM-FX/docker/docker-mysql-slave`目录内容。



###### TENANT服务器（此处操作尽可能由客户完成）

1. 为REPL服务器创建一个用于全量数据拷贝的临时账号
```shell
adduser xbrepl-<tenant>
passwd xbrepl-<tenant>
```
2. 安全组设置
	1. **SSH端口**：对`34.126.144.115`IP临时放行
	2. **MySQL端口**：对`34.126.144.115`IP长期放行，直至不再使用同步备份服务，或发生IP变更为止

###### REPL服务器分配租户资源

1. 挂载磁盘：将在云平台上购买的云磁盘挂载到服务器中，参见[[Linux常用命令#磁盘挂载]]
2. repl服务器为租户分配用户账号和专用磁盘
```shell
# 创建用户账号
useradd -m -s /usr/sbin/nologin <tenant>
#
# 分配专用磁盘
cd /mnt/disk-<tenant>/
chown <tenant>:<tenant> /mnt/disk-<tenant>/
su -s /bin/bash -c "umask 077 && mkdir mysql" <tenant>
su -s /bin/bash -c "umask 077 && mkdir data" <tenant>
su -s /bin/bash -c "umask 077 && mkdir scripts" <tenant>
```


#### 在主库服务器上

在主库的操作极其重要，务必严格按顺序执行，不可想当然的随意操作。

1. 你需要确保你的 `my.cnf` 文件中已经设置了 `server-id` 和 `log-bin` 选项，并且 `binlog-do-db` 选项设置为你想要同步的数据库。你已经有了这些设置，所以你可以跳过这一步。
```my.cnf
server-id=1
log-bin=mysql-bin
binlog-do-db=crm_v1
# 另外是否要排除个别日志表？
```

然后，重启mysql
```shell
systemctl restart mysqld
```

2. 创建账号
- 获取主库root账号
```shell
# 获取root密码
cd /workspace/scripts/
read -r u p <<< $(grep -oP '(?<=mysqldump -u)\S+|(?<=-p)\S+' mysql_backup.sh)
p="${p#\'}"
p="${p%\'}"
#
# 登录mysql
mysql -u"$u" -p"$p"
```

- 创建Dump用户（如果原来使用的是root账号进行备份的情况，则要做这一步）
```mysql
GRANT SELECT, LOCK TABLES, SHOW VIEW ON `crm_v1`.* TO 'crmdbdump'@'127.0.0.1' IDENTIFIED BY '<passwordB>';
```

- 创建复制用户，并给它赋予 `REPLICATION SLAVE` 权限：
```mysql
GRANT REPLICATION SLAVE ON *.* TO 'repl_<tenant>'@'34.126.144.115' IDENTIFIED BY '<passwordB>';
FLUSH PRIVILEGES;
```

3. 停止XBroker服务（推荐）

4. 锁定你想要同步的数据库，以防止在你创建数据快照时数据发生变化。例如：
```mysql
FLUSH TABLES WITH READ LOCK;
```

5. 查看当前的二进制日志文件的名称和位置。你将在从服务器上使用这些信息来开始复制。例如：
```mysql
SHOW MASTER STATUS;
```

> [!tip] 重要
> 记下 `File` 和 `Position` 的值。

6. 创建你想要同步的数据库的数据快照。例如，你可以使用 `mysqldump` 命令：
```shell
cd ~
mysqldump -u root -p --opt crm_v1 > crm-$(date +"%Y%m%d")-<tenant>.sql
```

在这里，`root` 是你的 MySQL 用户名，`crm_v1` 是你想要同步的数据库的名称，`crm_v1.sql` 是数据快照的文件名。

7. 解锁主数据库
```mysql
UNLOCK TABLES;
```

8. 压缩SQL文件
```shell
# 压缩SQL文件
tar -zcf crm-<YYYYmmdd>-<tenant>.tar.gz crm-<YYYYmmdd>-<tenant>.sql
```


#### 在从库服务器上

0. 传输SQL文件
```shell
umask 077
cd /mnt/disk-<tenant>/data
#
# 复制文件
scp -P <tenant-ssh-port> xbrepl-<tenant>@<tenant-ssh-ip>:~/crm-<YYYYmmdd>-<tenant>.tar.gz /mnt/disk-<tenant>/data
#
# 解压出SQL文件
tar zxf crm-<YYYYmmdd>-<tenant>.tar.gz -C .
chmod +r crm-<YYYYmmdd>-<tenant>.sql
```

1. 启动一个名为`mysql-<tenant>-slave` 的**xbroker-mysql-slave**容器：[[XBroker部署-Docker方案]]
```shell
# Ports: 30601~30699
docker run --name mysql-<tenant>-slave -p <port>:3306 -v /mnt/disk-<tenant>/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=Ohc926Nw -e MYSQL_ONETIME_PASSWORD=yes -e MYSQL_DUMP_PASSWORD=<dp-passwd> -d xbroker-mysql-slave
```


2. **修改ROOT账号密码**
```shell
# 登录mysql
# 生成密码对应的密文，如果本机生成不了，可以先在内部mysql上生成一下
SELECT PASSWORD('<password>');
#
# 然后复制出密码的密文，再执行
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password AS '<encry_root_password>';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password AS '<encry_root_password>';
# 刷新
FLUSH PRIVILEGES;
```

注：为什么要在内部的mysql上生成一个密码密文，再变更root账号的密码，避免在容器或宿主服务器上留痕，避免root账号的明文密码存在于服务器上

3. 导入在主服务器上创建的数据快照。例如，你可以使用 `mysql` 命令：
```shell
# 进入容器
docker exec -it mysql-<tenant>-slave bash
```

进入容器后，执行导入SQL文件
```
# cd /workspace/data
mysql -uroot -p
mysql> USE crm_v1;
mysql> SOURCE crm-<YYYYmmdd>-<tenant>.sql

# mysql -u root -p crm_v1 < crm-<YYYYmmdd>-<tenant>.sql
```
在这里，`root` 是你的 MySQL 用户名，`crm_v1` 是你想要同步的数据库的名称，`crm-<YYYYmmdd>.sql` 是数据快照的文件名。

过程如何比较久，可能会话会断开，这时可以通过以下命令确认导入进程是否还在工作：
```shell
ps aux | grep crm_v1
```


5. 配置复制（**注意替换变量**）。例如：
```mysql
CHANGE MASTER TO MASTER_HOST='master_host', MASTER_USER='repl_user', MASTER_PASSWORD='password', MASTER_LOG_FILE='file', MASTER_LOG_POS=position;
```
在这里，`master_host` 是主服务器的主机名，`repl_user` 和 `password` 是在主服务器上创建的复制用户的名称和密码，`file` 和 `position` 是在主服务器上查看到的二进制日志文件的名称和位置。

6. 开始复制：
```mysql
START SLAVE;
```

7. 查看复制的状态，以确保它正在正常工作：
```mysql
SHOW SLAVE STATUS\G
```
确保 `Slave_IO_Running` 和 `Slave_SQL_Running` 的值都是 `Yes`。

请注意，这些操作需要 `RELOAD`、`REPLICATION SLAVE`、`REPLICATION CLIENT` 和 `SUPER` 权限。如果你的 MySQL 服务器没有给你这些权限，你可能无法执行这些操作。



#### 备份

- 配置主库本地Dump定时任务
```shell
vi mysql_backup.sh
# 将账号和密码更换为crmdbdump账号密码
```

- 在从库
```shell
su - <tenant>
# 添加计划
echo "15 0 * * * <tenant> /mnt/disk-<tenant>/scripts/mysql_slave_backup.sh" | sudo tee -a /etc/crontab
```


#### 监控

- 磁盘空间监控
	- `df -h | grep /mnt/disk-` 查看磁盘占用比例，80%阈值告警
	- 超出阈值，需要对/mnt/data路径下的文件做清理，保留最近7个非0文件
- 同步异常监控
	- 监测relay文件数：检查 `slave-relay-bin.nnnnnn` 文件的个数和日期，正常只有两个文件，且日期为最近两天的，如果这两个数据超出正常值，则可能出现同步异常或效率问题
	- 检查同步状态：通过mysql命令`show slave status\G`，查看是否有error信息、SQL和IO状态是否为**Yes**

#### 结尾清理

- 主库
	- 清除`repl-<tenant>`账号
	- 清除对Repl服务器IP的SSH端口放行规则
- 从库
	- 清除账号密码痕迹，比如临时文件
	- 清除账号权限
		- 登录权限
		- 文件夹访问权限
		- 执行权限
	- 清除安全组IP规则
	- 清除history痕迹




## 扩容

### 停机操作

- 停止从库同步：`stop slave;`
- 停止容器运行：`docker stop mysql-<tenant>-slave`

### 启动操作

- 启动窗口运行：`docker start mysql-<tenant>-slave`
- 启动从库同步：`start slave;`


### 调整磁盘大小

1. 在GCP上，找到对应的磁盘，在**管理磁盘**页点击**修改**按钮
2. 将磁盘的**大小**字段修改成需要的大小数值，然后保存
3. 参考[[Linux常用命令#调整磁盘大小]]进行操作，关键指令：
```shell
sudo resize2fs /dev/<DEVICE_NAME>
```

注：可能需要等等若干分钟后，再查看磁盘大小是否更新。