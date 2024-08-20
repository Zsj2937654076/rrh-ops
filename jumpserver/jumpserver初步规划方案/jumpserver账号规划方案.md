# jumpserver 资产权限用户管理

## 一、资产整理

[TOC]

### 1.资产明细

**Windows and Linux (登记在册66台资产)**

|            IP             |      资产       |     备注     | 系统                                                         |
| :-----------------------: | :-------------: | :----------: | :----------------------------------------------------------- |
|  AliSZ-XFund-Release001   | 119.23.220.185  |    CentOS    | XFund的体验环境     redis     mysqld     定时：sysstat       |
|        ZunHK-PROXY        | 103.179.243.121 |    CentOS    | 外网代理，JumpServer公网节点     xray     stunnel     squid     定时：sysstat |
| itn-portal-saas-test-230  | 192.168.199.230 |    Debian    | 虚拟机@itn-kvm-11，主要用于haame saas的官网和用户中心的前端项目测试环境部署 |
|      AliHK-WEB-fx123      |  8.218.116.101  |    Linux     | rabbitmq     fx123.com     rrh123.com     定时：sitemap_monthly、sysstat |
|   AliHK-WEB-pamm-haame    |   8.210.4.190   |    Linux     | mysqld     redis-server     kafka     BotsCDC     MTInfoStatis     haame     pamm |
|      AliHK-WS-haame       |  47.75.44.159   |    Linux     | geoip     MyMate     haame                                   |
|     AliSZ-OP-manager      |  39.108.186.19  |    Linux     | redis     定时：sysstat、uptime-kuma                         |
|      AliSZ-WEB-00123      |  119.23.175.4   |    Linux     | redis     rabbitmq     mysqld     定时：logrotate、fx123-monitor、haaaami、sysstat |
|   AliSZ-WEB-crmps-zhzc    |   120.79.22.1   |    Linux     | mysql     abrt-dbus     crmps     gssproxy     dnsmasq     定时：raid-check、saas_mysqlbackup、mysqlbackup、sysstat |
|       AliSZ-WEB-elk       |  47.107.94.88   |    Linux     | elastalert     kibana     redis     定时：sysstat、xmam      |
|  AliSZ-WEB-rrh-services   | 120.78.222.215  |    Linux     | redis     mysqld     定时：fx123-error、sysstat、clean-log、fx123-monitor |
|   AliSZ-WEB-xmam-admin    | 47.112.204.244  |    Linux     | XMAM应用，同时兼有mymate服务     redis     rabbitmq     mongodb     mysql     定时：nutty、xmam、sysstat |
|    AliSZ-WEB-xmam-saas    |  120.79.171.70  |    Linux     | xmam-saas     xmam-saas     mysqld     定时：log_clean、saas_mysqlbackup、sysstat |
|    bandwagon-us-proxy     | 173.242.115.116 |    Linux     | xray     squid     stunnel                                   |
|         FXCRM-BKS         |  35.154.108.39  |    Linux     |                                                              |
|     FXCRM-castel-new      | 165.232.166.197 |    Linux     |                                                              |
|       FXCRM-Castle        |  103.131.65.5   |    Linux     |                                                              |
|      FXCRM-Cudrania       |  43.198.164.71  |    Linux     |                                                              |
|     FXCRM-Cudrania-db     |  18.167.45.157  |    Linux     |                                                              |
|       FXCRM-Fengye        | 149.30.255.124  |    Linux     |                                                              |
|       FXCRM-Fintab        |  3.29.191.151   |    Linux     |                                                              |
|      FXCRM-Fintab-db      |   3.29.36.126   |    Linux     |                                                              |
|       FXCRM-Fomoso        | 18.166.114.110  |    Linux     |                                                              |
|        FXCRM-Fubo         |  47.76.148.37   |    Linux     |                                                              |
|        FXCRM-Glory        | 18.167.158.247  |    Linux     |                                                              |
|      FXCRM-Goldennz       |  47.75.106.33   |    Linux     |                                                              |
|      FXCRM-imytrader      |  18.163.32.74   |    Linux     |                                                              |
|       FXCRM-Jump17        |  34.155.61.135  |    Linux     |                                                              |
|       FXCRM-Lakefox       | 16.162.240.212  |    Linux     |                                                              |
|     FXCRM-Lakefox-new     | 18.162.170.226  |    Linux     |                                                              |
|      FXCRM-mingtakfn      |  203.86.233.71  |    Linux     |                                                              |
|        FXCRM-Rvfx         |  13.214.99.34   |    Linux     |                                                              |
|      FXCRM-shangding      |  43.199.13.87   |    Linux     |                                                              |
|       FXCRM-spring        |  43.198.10.187  |    Linux     |                                                              |
|        FXCRM-Time         |  8.217.196.15   |    Linux     |                                                              |
|      FXCRM-uniwealth      | 139.180.188.102 |    Linux     |                                                              |
|     FXCRM-Westifield      |  45.207.47.87   |    Linux     |                                                              |
|       FXCRM-wisdom        |  103.131.65.7   |    Linux     |                                                              |
|     FXCRM-wisdom-new      |  45.32.116.67   |    Linux     |                                                              |
|         FXCRM-Wns         |  103.131.65.8   |    Linux     |                                                              |
|       FXCRM-yingtou       | 198.11.168.109  |    Linux     |                                                              |
|      FXCRM-zhonghong      | 18.163.232.238  |    Linux     |                                                              |
|        FXCRM-zixu         |  16.162.113.86  |    Linux     |                                                              |
| Google-HK-XBroker-release |  34.150.40.244  |    Linux     | XBroker在GCP上的体验环境     crm     redis     mysqld     定时：mysqlbackup、sqlclean |
|       Google-LA-AI        |  34.94.192.185  |    Linux     |                                                              |
|     itn-crm-test-233      | 192.168.199.233 |    Linux     | MFD     mysqld     crm     rrh-api     third-auth     redis  |
|      itn-crm-use-234      | 192.168.199.234 |    Linux     | crm     saas     redis                                       |
|    itn-crmfx-saas-231     | 192.168.199.231 |    Linux     | 下线                                                         |
|    itn-crmps-test-236     | 192.168.199.236 |    Linux     | 下线                                                         |
|   itn-datanav-test-238    | 192.168.199.238 |    Linux     | elasticsearch     redis     rabbitmq-server     mysqld       |
|      itn-jenkins-218      | 192.168.199.218 |    Linux     | jenkins     crm     rabbitmq-server     redis     mysqld.service     定时：crm-base、raid-check、xmam-mysql、nginx、xmam-base |
|    itn-jumpserver-209     | 192.168.199.209 |    Linux     | - keyclock     - vladp     - falcon-agent                    |
|        itn-kvm-11         | 192.168.199.11  |    Linux     | 物理机                                                       |
|    itn-oa-document-240    | 192.168.199.240 |    Linux     | eolinker                                                     |
|   itn-oa-repository-239   | 192.168.199.239 |    Linux     |                                                              |
|     itn-xmam-test-235     | 192.168.199.235 |    Linux     | RabbitMQ     Redis     xmam     mysqld                       |
|        PAMM-Orient        | 18.166.165.210  |    Linux     |                                                              |
|         PAMM-theo         |   13.234.6.71   |    Linux     |                                                              |
|       PAMM-theo-db        | 13.235.212.125  |    Linux     |                                                              |
|        PAMM-Vatee         |  18.162.102.60  |    Linux     |                                                              |
| AliHK-XBroker-MTProxy001  |  47.242.18.117  | Windows-2016 | xbroker的mtproxy服务，47.242.18.117（BGP（多线））           |
|     AliHK-XMAM-OC001      |  47.75.218.251  | Windows-2016 | XMAM生产环境跟单引擎的资产                                   |
|     AliHK-XMAM-OC002      |  47.244.158.40  | Windows-2016 | XMAM生产环境的跟单引擎                                       |
| AliHK-XBroker-MTProxy002  |  47.56.182.74   | Windows-2019 | XBroker生产环境的mtproxy资产                                 |
|       AliSZ-MTProxy       |  120.79.163.4   | Windows-2019 | XBroker的mtproxy备用服务器，并可做为mtpryx的备份服务器       |
|       ZunHK-MTProxy       | 103.179.242.90  | Windows-2019 | XBroker的mtproxy备用服务器，并可做为mtpryx的备份服务器       |

### 2.资产对接jms的权限类型划分

1. 客户服务器

   | 资产              | IP              |
   | ----------------- | --------------- |
   | FXCRM-BKS         | 35.154.108.39   |
   | FXCRM-castel-new  | 165.232.166.197 |
   | FXCRM-Castle      | 103.131.65.5    |
   | FXCRM-Cudrania    | 43.198.164.71   |
   | FXCRM-Cudrania-db | 18.167.45.157   |
   | FXCRM-Fengye      | 149.30.255.124  |
   | FXCRM-Fintab      | 3.29.191.151    |
   | FXCRM-Fintab-db   | 3.29.36.126     |
   | FXCRM-Fomoso      | 18.166.114.110  |
   | FXCRM-Fubo        | 47.76.148.37    |
   | FXCRM-Glory       | 18.167.158.247  |
   | FXCRM-Goldennz    | 47.75.106.33    |
   | FXCRM-imytrader   | 18.163.32.74    |
   | FXCRM-Jump17      | 34.155.61.135   |
   | FXCRM-Lakefox     | 16.162.240.212  |
   | FXCRM-Lakefox-new | 18.162.170.226  |
   | FXCRM-mingtakfn   | 203.86.233.71   |
   | FXCRM-Rvfx        | 13.214.99.34    |
   | FXCRM-shangding   | 43.199.13.87    |
   | FXCRM-spring      | 43.198.10.187   |
   | FXCRM-Time        | 8.217.196.15    |
   | FXCRM-uniwealth   | 139.180.188.102 |
   | FXCRM-Westifield  | 45.207.47.87    |
   | FXCRM-wisdom      | 103.131.65.7    |
   | FXCRM-wisdom-new  | 45.32.116.67    |
   | FXCRM-Wns         | 103.131.65.8    |
   | FXCRM-yingtou     | 198.11.168.109  |
   | FXCRM-zhonghong   | 18.163.232.238  |
   | FXCRM-zixu        | 16.162.113.86   |

   

2. 内网服务器

   | 资产                     | IP              |
   | ------------------------ | --------------- |
   | itn-crmfx-saas-231       | 192.168.199.231 |
   | itn-crmps-test-236       | 192.168.199.236 |
   | itn-crm-test-233         | 192.168.199.233 |
   | itn-crm-use-234          | 192.168.199.234 |
   | itn-datanav-test-238     | 192.168.199.238 |
   | itn-jenkins-218          | 192.168.199.218 |
   | itn-jumpserver-209       | 192.168.199.209 |
   | itn-kvm-11               | 192.168.199.11  |
   | itn-oa-document-240      | 192.168.199.240 |
   | itn-oa-repository-239    | 192.168.199.239 |
   | itn-portal-saas-test-230 | 192.168.199.230 |
   | itn-xmam-test-235        | 192.168.199.235 |

3. 外网服务器

   | 资产                      | IP              |
   | ------------------------- | --------------- |
   | AliHK-WEB-fx123           | 8.218.116.101   |
   | AliHK-WEB-pamm-haame      | 8.210.4.190     |
   | AliHK-WS-haame            | 47.75.44.159    |
   | AliHK-XBroker-MTProxy001  | 47.242.18.117   |
   | AliHK-XBroker-MTProxy002  | 47.56.182.74    |
   | AliHK-XMAM-OC001          | 47.75.218.251   |
   | AliHK-XMAM-OC002          | 47.244.158.40   |
   | AliSZ-MTProxy             | 120.79.163.4    |
   | AliSZ-OP-manager          | 39.108.186.19   |
   | AliSZ-WEB-00123           | 119.23.175.4    |
   | AliSZ-WEB-crmps-zhzc      | 120.79.22.1     |
   | AliSZ-WEB-elk             | 47.107.94.88    |
   | AliSZ-WEB-rrh-services    | 120.78.222.215  |
   | AliSZ-WEB-xmam-admin      | 47.112.204.244  |
   | AliSZ-WEB-xmam-saas       | 120.79.171.70   |
   | AliSZ-XFund-Release001    | 119.23.220.185  |
   | bandwagon-us-proxy        | 173.242.115.116 |
   | Google-HK-XBroker-release | 34.150.40.244   |
   | Google-LA-AI              | 34.94.192.185   |
   | PAMM-Orient               | 18.166.165.210  |
   | PAMM-theo                 | 13.234.6.71     |
   | PAMM-theo-db              | 13.235.212.125  |
   | PAMM-Vatee                | 18.162.102.60   |
   | ZunHK-MTProxy             | 103.179.242.90  |
   | ZunHK-PROXY               | 103.179.243.121 |

4. 其他服务器



## 二、账号规划

### 1.账号类型

1. 管理员账号
   - 禁止密码认证方式
   - 仅允许SSH密钥登陆
2. 应用账号
   - 禁止一切方式登陆
   - 限制文件访问权限
3. 功能账号
   - 主要使用SSH密钥登陆
   - 特殊场景允许密码认证登陆
   - 只允许执行特定功能

### 2.账号分组

1. 管理员组
   - 仅分配管理员账号
2. 开发组
   - 分配开发人员
3. 测试组
   - 分配测试人员
4. 运维组
   - 分配运维人员

## 三、账号与资产关联

### 1.用户、用户组、系统用户 三者的关联

eg：

用户**ops001** 属于 运维组

系统用户 **sys001** 绑定服务器 **web01** **web02** **web03**

资产授权时  1.绑定了用户组：运维组    2.绑定了系统用户：**sys001**    3.资产授权的服务器为 **web02 web03 web04**

那么用户**ops001**在登陆jumpserver后能ssh访问的服务为**web02** **web03** **web04**  但是 **web04** 因为没有与系统用户绑定所以访问会失败

同时，系统用户 **sys001** 绑定服务器**web01 web02 web03** ，又在资产授权时绑定了**web02 web03 web04** 所以**sys001**所拥有的服务器访问权限有**web01 web02 web03 web04** 这四台服务器     会取 **系统用户授权** 和 **资产授权** 两者的并集

### 2.根据关联性设计权限分配

<img src="/Users/zsj/Documents/rrh/jumpserver/jumpserver账号规划方案.assets/jumpserver.png" alt="jumpserver" style="zoom: 25%;" />

## 四、资产使用人员分组

- 开发人员 dev-
  1. 只读 read
  2. 读写 write
  3. 特定 
- 测试人员 test-
  1. 只读 read
  2. 读写 write
  3. 特定
- 运维人员 ops-
  1. 只读 read
  2. 读写 write
  3. 特定
- 其他

## 五、落地实施测试

```shell
#使用useradd命令创建一个新的用户账号
sudo useradd <username>
#设置用户密码
passwd <username>
#创建组
groupadd <groupname>
#添加用户到组
usermod -aG <group_name> <username>
#删除用户
userdel <username>

#查看用户
cat /etc/passwd
#查看组
cat /etc/group


#it-read用户创建
useradd it-read
passwd it-read

#it-common用户创建
useradd it-common
passwd it-common

#it-ops用户创建
useradd it-ops
passwd it-ops
usermod -aG root it-ops
```

<img src="/Users/zsj/Documents/rrh/jumpserver/jumpserver账号规划方案.assets/jumpserver2.png" alt="jumpserver2" style="zoom:25%;" />





