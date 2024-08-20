#!/bin/bash

# 钉钉机器人webhook地址
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=c713f4edcee44abc77de9b27c17d6de46e77c115bcb28deff9749a18fbbc2792"

# 要监控的目录路径
WATCH_DIR1="/workspace/websites/mysqlbackup/"
INCLUDE_PATHS=(
    "/workspace/websites/mysqlbackup/xmam_imytrader.fx00.com/"
    "/workspace/websites/mysqlbackup/xmam_lakefox.fx00.com/"
    "/workspace/websites/mysqlbackup/xmam_mam.fx00.com/"
    "/workspace/websites/mysqlbackup/xmam_rvfx.fx00.com/"
    "/workspace/websites/mysqlbackup/xmam_vatee.fx00.com/"
    "/workspace/websites/mysqlbackup/xmam_xmam.fx00.com/"
)

# 事件列表（包括 create、modify、delete）
EVENTS="CREATE"

# 获取主机名和IP
HOSTNAME=$(hostname)
IP=$(hostname -I)

# 记录文件变化和文件数量
record_change() {
    local file=$1
    local event=$2
    local log_file="/usr/local/bin/changes.log"
    local count=$(grep -c "文件变化告警" "$log_file")
    if [[ $count -eq 0 ]]; then
        echo "今天发生create的文件的数量" >> "$log_file"
    fi

    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    HOWBIG=$(stat --format="%s" "$file")
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
inotifywait -m -r --format '%w%f %e' --event $EVENTS $WATCH_DIR1 | while read file event; do 
    for include_path in "${INCLUDE_PATHS[@]}"; do
        if [[ "$file" == "$include_path"* && "$file" == *.tar.gz ]]; then
            record_change "$file" "$event"
            break
        fi
    done
done
