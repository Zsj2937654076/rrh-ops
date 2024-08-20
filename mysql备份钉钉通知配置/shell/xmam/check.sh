#!/bin/bash

# 要统计的文件路径
file_path="/usr/local/bin/changes.log"
send_file="/usr/local/bin/ddsend.txt"

HOSTNAME=$(hostname)
IP=$(hostname -I)
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
HOWBIG=$(stat --format="%s" "$file")
# 使用grep命令统计匹配次数
match_count=$(grep -o "文件大小" "$file_path" | wc -l)

# echo "文件中出现了 $match_count 次“文件大小”这几个字。"

EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【发生改变的文件个数】:</font><font color=#FF0000>$match_count</font>
"
echo -e "$EVENT_MESSAGE" >> "$send_file"  # 记录变化信息到日志文件