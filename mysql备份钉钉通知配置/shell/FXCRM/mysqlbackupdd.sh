#!/bin/bash

# 钉钉机器人webhook地址
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=b8bc0260632207df51627108f29fdddcbed4ce6a0e707db2f91e6add589e1057"

# 要监控的目录路径
WATCH_DIR="/workspace/mysql_backup/"

# 事件列表（包括 create、modify、delete）
EVENTS="create"

#备份文件


# 获取主机名和IP
HOSTNAME=$(hostname)
IP=$(hostname -I)

# 记录文件变化和文件数量
record_change() {
    local file=$1
    local event=$2
    local log_file="/usr/local/bin/logs/changes_$(date +"%Y-%m-%d").log"
    local count=$(grep -c "文件变化告警" "$log_file")
    if [[ $count -eq 0 ]]; then
        echo "今天发生create的文件的数量:$count" >> "$log_file"
    fi

    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    CURRENT_TIME2=$(date +"%Y%m%d")
    FILE_LOCAL="/workspace/mysql_backup/crm-$CURRENT_TIME2.tar.gz"
    HOWBIG=$(stat --format="%s" "$FILE_LOCAL")
    EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 发生变化的文件：<code>${file}</code>
>- inotify事件类型：<font color=#FF0000> <code>${event}</code> </font>
"
    echo -e "$EVENT_MESSAGE" >> "$log_file"  # 记录变化信息到日志文件
}

# 运行 inotifywait 并处理事件循环
inotifywait -m -r --format '%w%f %e' --event $EVENTS $WATCH_DIR | while read file event; do 
        if [[ "$file" == *.tar.gz ]]; then
            record_change "$file" "$event"
            break
        fi
    done
