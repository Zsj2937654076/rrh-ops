GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.188.1' IDENTIFIED BY 'root' WITH GRANT OPTION;


set global validate_password.policy=LOW;
set global validate_password_length=1;

#查看当前的密码策略
SHOW VARIABLES LIKE 'validate_password%';

#创建用户并授权
CREATE USER 'slave'@'%' IDENTIFIED BY 'Slave@123';

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
change master to master_host='192.168.188.66',master_user='root',master_password='root',master_port=3306,master_log_file='mysql-bin.000004',master_log_pos=1697,master_connect_retry=30;

*参数说明：
master_host: 主数据库的IP地址；
master_port: 主数据库运行的端口；
master_user: 在主数据库创建的用于同步数据的用户账号；
master_password: 在主数据库创建的用于同步数据的用户密码；
master_log_file: 指定从数据库要复制数据的日志文件，通过查看主数据状态，获取file参数；
master_log_pos: 指定从数据库从哪个位置开始复制数据，通过查看主数据的状态，获取position参数；
master_connect_retry: 链接失败重试的时间间隔，单位为秒。
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

#停止主从同步的IO和SQL线程
STOP SLAVE IO_THREAD FOR CHANNEL '';
#查看主库的状态
show master status;
#查看从库的状态
show slave status \G;
#启动从库
start slave;
#授权root用户远程登录
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;

mysql -uroot  -proot

create database db01;
use db01;
create table t1 (id int,name varchar(10));
insert into t1 values(1,'z3');
select * from t1;

#dump全量备份
mkdir -p /data/backup

/usr/bin/mysqldump -uroot -proot  --lock-all-tables --flush-logs test > /home/backup.sql
/usr/bin/mysqldump -uroot -proot --lock-all-tables --flush-logs --all-databases > /home/backup.sql

