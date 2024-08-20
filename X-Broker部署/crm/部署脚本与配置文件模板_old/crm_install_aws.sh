#!/bin/bash

# config.ini
# admin_domain=""
# user_url=""
# guard=""
# mt_host=""
# mymate_url=""
# mymate_ack=""
# mymate_sck=""
# app_id=""
# app_key=""

source ./config.ini

create_user()
{
    useradd fxsage -s /sbin/nologin;
    setfacl -m u:fxsage:r /bin/sh;
    setfacl -m u:fxsage:r /bin/bash;
    setfacl -m u:fxsage:r /bin/setfacl;
    setfacl -m u:fxsage:r /bin/getfacl;
    setfacl -m u:fxsage:r /bin/curl;
    setfacl -m u:fxsage:r /bin/wget;
}

create_directory()
{
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
    [[ ! -d ${jar_directory} ]]&& mkdir -p ${jar_directory}
    [[ ! -d ${script_directory} ]]&& mkdir -p ${script_directory}
    [[ ! -d ${release_directory} ]]&& mkdir -p ${release_directory}
    [[ ! -d ${static_directory} ]]&& mkdir -p ${static_directory}
    [[ ! -d ${log_directory} ]]&& mkdir -p ${log_directory}
    [[ ! -d ${sql_directory} ]]&& mkdir -p ${sql_directory}
    [[ ! -d ${image_directory} ]]&& mkdir -p ${image_directory}
    [[ ! -d ${cssd_directory} ]]&& mkdir -p ${cssd_directory}
    [[ ! -d ${program_log_directory} ]]&& mkdir -p ${program_log_directory}
    [[ ! -d ${certbot_directory} ]]&& mkdir -p ${certbot_directory}
    chown -R fxsage: ${crm_directory}
    chown -R fxsage: ${program_log_directory}
}

hosts_config()
{
    echo "47.107.54.108 iZh3xa0sw7mx31Z" >> /etc/hosts
}

crm_get()
{
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/crm/crm-admin.jar -O /workspace/websites/crm/jar/crm-admin.jar
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/crm/crm-client.jar -O /workspace/websites/crm/jar/crm-client.jar
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/crm/crm-rebate.jar -O /workspace/websites/crm/jar/crm-rebate.jar
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/crm/crm-scheduled.jar -O /workspace/websites/crm/jar/crm-scheduled.jar
    cd /workspace/websites/crm/static
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/crm/crm-fx-vue.zip
    unzip crm-fx-vue.zip >/dev/null 2>&1
    chown -R fxsage: /workspace/websites/crm/
    rm -rf /workspace/websites/crm/static/crm-fx-vue.zip
    cp /workspace/websites/crm/static/cssd/config.css /workspace/websites/crm/jar/projects/static/cssd/
}

install_mysql() 
{
    cd /usr/local/src
    wget -q -i -c https://crm-fx.oss-cn-hongkong.aliyuncs.com/mysql57-community-release-el7-10.noarch.rpm
    wget -q -i -c https://crm-fx.oss-cn-hongkong.aliyuncs.com/sql/crm_base.sql
    yum -q -y install mysql57-community-release-el7-10.noarch.rpm >/dev/null 2>&1
    sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/mysql-community.repo >/dev/null 2>&1
    yum -q -y install mysql-community-server >/dev/null 2>&1
    systemctl -q start  mysqld.service
    systemctl -q enable mysqld.service
    grep "password" /var/log/mysqld.log > /root/mysqlinitialpasswd
    # get mysql initial password
    sql_password=`cat /root/mysqlinitialpasswd |head -1 |awk '{print $NF}'`
    # modify global variables
    new_sql_passwd=`mkpasswd -s 0`
    echo "${new_sql_passwd}" > /root/newsqlpasswd
    sed -i "/\[mysqld\]/a\sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" /etc/my.cnf
    sed -i "/\[mysqld\]/a\validate_password_length=6" /etc/my.cnf
    sed -i "/\[mysqld\]/a\validate_password_policy=LOW" /etc/my.cnf
    sed -i "/\[mysqld\]/a\skip_ssl" /etc/my.cnf
    sed -i "/\[mysqld\]/a\max_length_for_sort_data=8096" /etc/my.cnf
    sed -i "/\[mysqld\]/a\innodb_sort_buffer_size=8M" /etc/my.cnf
    sed -i "/\[mysqld\]/a\innodb_buffer_pool_size=512M" /etc/my.cnf
    sed -i "/\[mysqld\]/a\sort_buffer_size=2M" /etc/my.cnf
    sed -i "/\[mysqld\]/a\join_buffer_size=2M" /etc/my.cnf
    sed -i "/\[mysqld\]/a\max_allowed_packet=8M" /etc/my.cnf
    sed -i "/\[mysqld\]/a\innodb_flush_log_at_trx_commit=2" /etc/my.cnf
    systemctl -q restart mysqld

    mysqladmin -uroot -p${sql_password} password ${new_sql_passwd}
    # Initialize database crm_v1
    mysql -uroot -p${new_sql_passwd} -se 'create database  if not exists crm_v1 default charset utf8 collate utf8_general_ci;'
    mysql -uroot -p${new_sql_passwd} -se 'create user `hcs_crm`@`%` identified by "ZNjkzMR2";'
    mysql -uroot -p${new_sql_passwd} -se 'grant all privileges on crm_v1.* to `hcs_crm`@`%`;'
    mysql -uroot -p${new_sql_passwd} -se 'grant replication slave,replication client on *.* to `hcs_crm`@`%`;'
    mysql -uroot -p${new_sql_passwd} -se 'flush privileges;'
    mysql -uhcs_crm -p'ZNjkzMR2' crm_v1 < crm_base.sql

    # modify table sys_config
    echo "update crm_v1.sys_config set config_value='${admin_domain}' where config_name='vohst';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${guard}' where config_name='guard url';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${user_url}' where config_name='前端地址';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${mt_host}' where config_name='mt host';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${mymate_url}' where config_name='mymate url';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${mymate_ack}' where config_name='mymate accessKeyId';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${mymate_sck}' where config_name='mymate secretKey';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='https://${admin_domain}/' where config_key='sys.admin.url';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${user_url}ib-application' where config_key='sys.crmConfig.agencySetting.registerUrl';" >> config_update.sql
    echo "update crm_v1.sys_spread_link_config set link_addr='${user_url}ib-application' where link_type=2;" >> config_update.sql
    echo "update crm_v1.sys_spread_link_config set link_addr='${user_url}regist-real' where link_type=1;" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${app_id}' where config_key='sys.app.id';" >> config_update.sql
    echo "update crm_v1.sys_config set config_value='${app_key}' where config_key='sys.app.key';" >> config_update.sql

    mysql -uroot -p${new_sql_passwd} -se 'source config_update.sql'

    # mysql backup cron
    cat > /workspace/scripts/mysql_backup.sh << EOF
    #!/bin/bash
    cd /workspace/mysql_backup/
    /usr/bin/mysqldump -uroot -p'${new_sql_passwd}' --opt -R crm_v1 > crm-\$(date +"%Y%m%d").sql
    /usr/bin/tar -czf crm-\$(date +"%Y%m%d").tar.gz crm-\$(date +"%Y%m%d").sql --remove-files
EOF
    
    chmod 700 /workspace/scripts/mysql_backup.sh
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/monitor/sql_clean.sh -O /workspace/scripts/sql_clean.sh
    chmod +x /workspace/scripts/sql_clean.sh
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/monitor/mysqlbackup -O /etc/cron.d/mysqlbackup
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/monitor/sqlclean -O /etc/cron.d/sqlclean
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/monitor/sql_update.sh -O /workspace/scripts/sql_update.sh
    chmod 700 /workspace/scripts/sql_update.sh
    systemctl -q restart crond
}

install_rabbitmq()
{
    # install erlang
    cd /usr/local/src
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/otp_src_22.1.tar.gz
    tar -zxf otp_src_22.1.tar.gz 
    cd otp_src_22.1 
    ./otp_build autoconf >/dev/null 2>&1
    ./configure >/dev/null 2>&1 && make -s -j4 >/dev/null 2>&1 && make -s install >/dev/null 2>&1
    
    # install rabbitmq
    cd /usr/local/src
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/rabbitmq-server-generic-unix-3.8.0.tar
    tar -xf rabbitmq-server-generic-unix-3.8.0.tar 
    mv rabbitmq_server-3.8.0 /usr/local/rabbitmq-server
    echo "export PATH=$PATH:/usr/local/lib/erlang/bin:/usr/local/rabbitmq-server/sbin" >> /etc/profile
    source /etc/profile
    
    # system service configuration
    cat > /usr/lib/systemd/system/rabbitmq-server.service << EOF
    [Unit]
    Description=RabbitMQ broker
    After=syslog.target network.target
    
    [Service]
    User=root
    Group=root
    ExecStart=/usr/local/rabbitmq-server/sbin/rabbitmq-server
    ExecStop=/usr/local/rabbitmq-server/sbin/rabbitmqctl shutdown
    
    [Install]
    WantedBy=multi-user.target
EOF
    
    systemctl -q daemon-reload
    systemctl -q start rabbitmq-server
    systemctl -q enable rabbitmq-server
    # creat admin accout and delete default accout
    cd /usr/local/rabbitmq-server/plugins
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/rabbitmq_delayed_message_exchange-3.8.0.ez;
    rabbitmq-plugins enable rabbitmq_management >/dev/null 2>&1 && \
    rabbitmq-plugins enable rabbitmq_delayed_message_exchange >/dev/null 2>&1 && \
    rabbitmq-plugins enable rabbitmq_prometheus >/dev/null 2>&1 && \
    rabbitmqctl list_users >/dev/null 2>&1 && \
    rabbitmqctl add_user admin hcs123 >/dev/null 2>&1 && \
    rabbitmqctl set_user_tags admin administrator >/dev/null 2>&1 && \
    rabbitmqctl delete_user guest >/dev/null 2>&1 && \
    rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" >/dev/null 2>&1;
    systemctl -q restart rabbitmq-server
}

install_redis()
{
    #yum -q -y install redis >/dev/null 2>&1
    #sed -i "s/^# requirepass.*/requirepass dsocredis/" /etc/redis.conf
    amazon-linux-extras install redis6
    sed -i "s/^# requirepass.*/requirepass dsocredis/" /etc/redis/redis.conf
    systemctl -q start redis >/dev/null 2>&1
    systemctl -q enable redis >/dev/null 2>&1
}

install_nginx()
{
    #yum -q -y install nginx >/dev/null 2>&1
    amazon-linux-extras install nginx1
    mkdir -p /etc/nginx/vhost
    wget https://crm-fx.oss-cn-hongkong.aliyuncs.com/nginx/nginx.conf -O /etc/nginx/nginx.conf
    # configuration of nginx
    systemctl -q start nginx >/dev/null 2>&1
    systemctl -q enable nginx >/dev/null 2>&1
}

nginx_configuration()
{
    # admin nginx conf file
    cat > /etc/nginx/vhost/${admin_domain}.conf << EOF
    server{
        listen 80;
        server_name ${admin_domain};
        location /.well-known {
            root /workspace/websites/crm/;
        }
        location / {
            rewrite ^(.*)$ https://${admin_domain}\$1 permanent;
        }
    }
    server {
        listen 443 ssl;
        autoindex off;
        server_name ${admin_domain} ;
        access_log /var/log/nginx/crm-admin.log;
        ssl_certificate /etc/letsencrypt/live/${admin_domain}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${admin_domain}/privkey.pem;
        error_page 404 504 502 403 500 /404.html;
        gzip on;
        gzip_buffers 32 4K;
        gzip_comp_level 6;
        gzip_min_length 50K;
        gzip_types *;
        gzip_vary on;
        location = /404.html {
            root ${static_directory}/404;
        }
        location /  {
            proxy_pass http://127.0.0.1:8088;
            add_header 'Access-Control-Allow-Origin' '*';
            add_header Access-Control-Allow-Headers 'Content-Type';
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, PATCH, OPTIONS';
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$clientRealIp;
            proxy_set_header REMOTE-HOST \$clientRealIp;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header X-Forwarded-Proto  \$scheme;
            proxy_read_timeout 300s; 
        }
        location /rebatelog {
            proxy_pass http://127.0.0.1:8087/log;
        }
        location /wslog/ {
            proxy_pass http://127.0.0.1:8087/wslog/;
            add_header 'Access-Control-Allow-Origin' '*';
            add_header Access-Control-Allow-Headers 'Content-Type';
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, PATCH, OPTIONS';
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$clientRealIp;
            proxy_set_header REMOTE-HOST \$clientRealIp;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header X-Forwarded-Proto  \$scheme;
            proxy_read_timeout 300s; 
        }
        location /supervisor {
            proxy_pass http://127.0.0.1:9001;
        }
    }
EOF
    
    # user nginx conf file
    cat > /etc/nginx/vhost/${user_domain}.conf << EOF
    server{
        listen 80;
        server_name ${user_domain};
        location /.well-known {
            root /workspace/websites/crm/;
        }
        location / {
            rewrite ^(.*)$ https://${user_domain}\$1 permanent;
        }
    }
    server {
        listen 443 ssl;
        autoindex off;
        server_name ${user_domain};
        root ${static_directory};
        access_log /var/log/nginx/crm-user.log;
        ssl_certificate /etc/letsencrypt/live/${user_domain}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${user_domain}/privkey.pem;
        gzip on;
        gzip_buffers 32 4K;
        gzip_comp_level 6;
        gzip_min_length 50K;
        gzip_types *;
        gzip_vary on;
        index index.html index.htm index.jsp index.php;
        if ( \$query_string ~* ".*[\;'\<\>].*" ){
            return 404;
        }
        error_page 404 504 502 403 /404.html;
        location = /404.html {
            root ${static_directory}/404;
        }
        location / {
            index  index.html index.htm;
            root ${static_directory};
            try_files \$uri \$uri/ /index.html;
        }
        location ^~ /cssd/ {
            alias /workspace/websites/crm/jar/projects/static/cssd/;
    
        }
        location /picupload {       
            proxy_pass   http://127.0.0.1:8088/common/upload;
            proxy_http_version 1.1;
            proxy_method POST;
            proxy_set_header Connection "";
            proxy_set_header Host "${admin_domain}";
            proxy_set_header X-Real-IP \$clientRealIp;
            proxy_set_header REMOTE-HOST \$clientRealIp;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto  \$scheme;
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'POST,GET,PUT,DELETE,OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Content-Length,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since';
            add_header 'Access-Control-Allow-Credentials' 'true';
        }
        location ^~ /crm_static/ {
            proxy_pass http://127.0.0.1:8088/crm_static/;
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'POST,GET,PUT,DELETE,OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Content-Length,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since';
            add_header 'Access-Control-Allow-Credentials' 'true';
        }
        location ~ /(spread|user|server|trade|common|position|deal|fund|wallet|deposit|msg|withdraw|userBank|statistic|appdownload|interTrans|websocket|system|rebate|accountGroup|work)/ {
            proxy_pass   http://127.0.0.1:8089;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$clientRealIp;
            proxy_set_header REMOTE-HOST \$clientRealIp;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
        location /log {
            proxy_pass   http://127.0.0.1:8087;
            add_header 'Access-Control-Allow-Origin' '*';
            add_header Access-Control-Allow-Headers 'Content-Type';
            add_header Access-Control-Allow-Methods 'GET, POST, PUT, DELETE, PATCH, OPTIONS';
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$clientRealIp;
            proxy_set_header REMOTE-HOST \$clientRealIp;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
EOF
}

install_certbot()
{
    # 亚马逊安装
    amazon-linux-extras install epel
    yum -y -q install epel-release >/dev/null 2>&1
    yum -y -q install certbot python2-certbot-nginx >/dev/null 2>&1
    
    certbot >/dev/null 2>&1
    cat > /etc/letsencrypt/renewal-hooks/post/nginx.sh << EOF
    #!/bin/bash
    /sbin/nginx -s reload
EOF
    
    chmod +x /etc/letsencrypt/renewal-hooks/post/nginx.sh
    echo "0 0 * * * root /usr/bin/certbot renew" >> /etc/crontab
    systemctl restart crond
}

install_supervisor()
{
    # install supervisor by python2
    cd /usr/local/src
    wget -q https://crm-fx.oss-cn-hongkong.aliyuncs.com/supervisor-3.1.3.tar.gz
    tar zxf supervisor-3.1.3.tar.gz
    cd supervisor-3.1.3
    python setup.py install >/dev/null 2>&1
    mkdir -p /etc/supervisord.d/
    touch /etc/supervisord.conf
    touch /usr/lib/systemd/system/supervisord.service

# supervisor configuration file
cat > /etc/supervisord.conf << EOF
[unix_http_server]
file=/var/run/supervisor.sock   ; the path to the socket file

[supervisord]
logfile=/var/log/supervisord.log ; main log file; default /supervisord.log
logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
logfile_backups=10           ; # of main logfile backups; 0 means none, default 10
loglevel=info                ; log level; default info; others: debug,warn,trace
pidfile=/var/run/supervisord.pid ; supervisord pidfile; default supervisord.pid
nodaemon=false               ; start in foreground if true; default false
minfds=1024000                  ; min. avail startup file descriptors; default 1024
minprocs=200                 ; min. avail process descriptors;default 200

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket

[include]
files = /etc/supervisord.d/*.ini
EOF
    
# supervisor systemd service
cat > /usr/lib/systemd/system/supervisord.service << EOF
[Unit]
Description=supervisord - Supervisor process control system for UNIX
Documentation=http://supervisord.org
After=network.target

[Service]
LimitNPROC=65535
LimitNOFILE=65535
Type=forking
ExecStart=/bin/supervisord -c /etc/supervisord.conf
ExecReload=/bin/supervisorctl reload
ExecStop=/bin/supervisorctl shutdown
User=root

[Install]
WantedBy=multi-user.target
EOF
    
# /etc/supervisord.d/crm-*.ini 
cat > /etc/supervisord.d/crm.ini << EOF
[group:crm]
programs = admin, client, rebate, scheduled

[program:admin]
command=java -jar /workspace/websites/crm/jar/crm-admin.jar --spring.profiles.active=prod --jasypt.encryptor.password=hcs-jasypt
stdout_logfile=/workspace/websites/crm/logs/8088_out.log
autostart=true
autorestart=true
user=fxsage
group=fxsage
[program:client]
command=java -jar /workspace/websites/crm/jar/crm-client.jar --spring.profiles.active=prod --jasypt.encryptor.password=hcs-jasypt
stdout_logfile=/workspace/websites/crm/logs/8089_out.log
autostart=true
autorestart=true
user=fxsage
group=fxsage
[program:rebate]
command=java -jar /workspace/websites/crm/jar/crm-rebate.jar --spring.profiles.active=prod --jasypt.encryptor.password=hcs-jasypt
stdout_logfile=/workspace/websites/crm/logs/8087_out.log
autostart=true
autorestart=true
user=fxsage
group=fxsage
[program:scheduled]
command=java -jar /workspace/websites/crm/jar/crm-scheduled.jar --spring.profiles.active=prod --jasypt.encryptor.password=hcs-jasypt
stdout_logfile=/workspace/websites/crm/logs/8086_out.log
autostart=true
autorestart=true
user=fxsage
group=fxsage
EOF

    systemctl -q daemon-reload && \
    systemctl -q stop supervisord && \
    systemctl -q start supervisord && \
    systemctl -q enable supervisord >/dev/null 2>&1
}

install_check()
{
    if [[ -f /etc/crm_version ]];then
        echo "CRM already installed on this machine"
        exit -1
    fi
}

hardware_check()
{
    cpu_cores=$(cat /proc/cpuinfo |grep processor|wc -l)
    mem_total=$(cat /proc/meminfo |grep "MemTotal"|awk '{print $2}')

    [[ "${cpu_cores}" -lt "2" ]] && echo "cpu 核心数不满足基础要求" && exit -1
    [[ "${mem_total}" -lt "15728640" ]] && echo "内存容量不满足基础要求" && exit -1
}

version_record()
{
    echo `date +%s` > /etc/crm_version
}

install_dependencies()
{
    yum -q -y install epel-release mkpasswd gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-* git wget expect unzip tar vim net-tools python-pip>/dev/null 2>&1
    yum -q -y update >/dev/null 2>&1
    yum -q -y remove mysql* mariadb* >/dev/null 2>&1
    cd /usr/local/src/
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
    python get-pip.py
    python -m pip install meld3 >/dev/null 2>&1
}

add_ssh_keys()
{
    cat > /root/.ssh/authorized_keys << EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1YSQk2bB0U9cVhX7Woq3upURMQ54ppbvWWaGNhn3ELruhX4mXWzEm9DlLyp99Ld/PDs8n6t0ufmNILSse3evty24XBnNWkAqb+coeHow51wBeYdV1pn0VLae095MxLaT2cH0rGQWt2LvJPa5Vlc2K3OUJyqWBoaCbEtHWNBd0jHBzOeob2DUROCXbyWlbOoLieyOJB1sb+mfTvor5yTo9SmRHgBILylhMgxxnwBFd/+oF5zoxvx/CF1bpWRxT0jnGIE42DCDGNhg29YJbtpriLNPLFp0M1MXn51yFC+OZMyX1pGtpU6CdnRM20CyDUnd5QYOlsEBd8RNEAr9eqHwN root@itn-jumpserver-209
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChOnNgFcfX/bJ3htwcBdzO7yHCnA52TEeNZOAGIC6Q7PSHVgmxUq07NOqM2Km2gfxhSBfvyeXMOLAlbhdYGbdWm9WMLwkEwzkiVKNLI2BVbNi9istb00FZwsaAjjSPaW4fucAA3oywGUylP3dHbrJBk1hnM9tD00q5vAs/l1t6GM8eiqWgmNS9jCF7ATI78oDewFfmy9qQ6F5QaUgw8Dr+BcZLW2zXGz6w18gtCiolR4+MbIDI3WdrKbNC55kfEaCw9Zf/vJfbAsmltMOiPEuRCKZDZ7nThfuFLU6cgRheyw/VWIxCS4teRX3a2j8V6ikT/Ujj8VSrP0++fabBdxHb root@ZunHK-PROXY
EOF
    
    chmod 700 /root/.ssh/
    chmod 600 /root/.ssh/authorized_keys
}

modify_hostname()
{
    hostnamectl set-hostname --static ${hostname}
}

download_clean()
{
    rm -rf /usr/local/src/*
}

main()
{
    install_check
    hardware_check
    echo "CRM installation start"
    echo "Environment initialization"
    install_dependencies
    create_user
    create_directory 
    echo "Program initialization"
    [[ ! -f "/bin/redis-cli" ]] && install_redis
    [[ ! -f "/usr/local/rabbitmq-server/sbin/rabbitmqctl" ]] && install_rabbitmq
    [[ ! -f "/usr/bin/mysql" ]] && install_mysql
    [[ ! -f "/usr/sbin/nginx" ]] && install_nginx
    [[ ! -f "/etc/nginx/vhost/${admin_domain}.conf" ]] && nginx_configuration
    [[ ! -f "/bin/certbot" ]] && install_certbot
    [[ ! -f "/bin/supervisorctl" ]] && install_supervisor
    [[ ! -f "/workspace/websites/crm/jar/crm-admin.jar" ]] && crm_get
    add_ssh_keys
    modify_hostname
    hosts_config
    version_record
    echo
    download_clean
    echo "CRM installation finish"
}

main
