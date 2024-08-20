## **yum方式安装inotify-tools**

```shell
sudo yum install epel-release
yum install inotify-tools -y


cd /usr/local/bin/

#上传 mysqlbackupdd.sh 和 send_logs.sh 两个脚本，然后赋执行权限
chmod 777 /usr/local/bin/mysqlbackupdd.sh
chmod 777 /usr/local/bin/send_logs.sh


#编写systemctl服务文件
vim /etc/systemd/system/file-monitor.service

[Unit]
Description=File Monitor Service for Directory Changes Notification via DingTalk

[Service]
Type=simple
ExecStart=/usr/local/bin/mysqlbackupdd.sh

# Restart service on failure to ensure it keeps running.
Restart=on-failure 
RestartSec=5s 

# Environment variables can be set here if needed.
# Example:
# Environment="VAR_NAME=value"

[Install]
WantedBy=multi-user.target



systemctl daemon-reload



#上传 dd_mysqlbackup 定时任务脚本
cd /etc/cron.d
```

