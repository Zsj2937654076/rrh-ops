#!/bin/bash

# 钉钉机器人webhook地址
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=b8bc0260632207df51627108f29fdddcbed4ce6a0e707db2f91e6add589e1057"

# 日志文件路径
LOG_FILE="/usr/local/bin/changes.log"

# 函数：发送消息到钉钉
send_to_dingtalk() {
    local message=$1

    curl -s -X POST $DINGTALK_WEBHOOK \
        -H 'Content-Type: application/json' \
        -d "{
            \"msgtype\": \"markdown\",
            \"markdown\": {
                \"title\":\"文件变化告警\",
                \"text\":\"$message\"
            }
        }"
}

checkdd(){
    HOSTNAME=$(hostname)
    IP=$(hostname -I)
    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    CURRENT_DAY=$(date +"%Y%m%d")
    PREVIOUS_DAY=$(date -d "yesterday" +"%Y%m%d")
    DAY_BEFORE_YESTERDAY=$(date -d "2 days ago" +"%Y%m%d")

    CURRENTDAY_FILE="/workspace/mysql_backup/crm-$CURRENT_DAY.tar.gz"
    YESTERDAY_FILE="/workspace/mysql_backup/crm-$PREVIOUS_DAY.tar.gz"
    DAY_BEFORE_YESTERDAY_FILE="/workspace/mysql_backup/crm-$DAY_BEFORE_YESTERDAY.tar.gz"

    # 获取文件大小
        HOWBIG_YESTERDAY_FILE=$(stat --format="%s" "$YESTERDAY_FILE")
        HOWBIG_DAY_BEFORE_YESTERDAY_FILE=$(stat --format="%s" "$DAY_BEFORE_YESTERDAY_FILE")
        HOWBIG=$(stat --format="%s" "$CURRENTDAY_FILE")

        #今天-昨天
        SIZE_DIFF_TODAY=$(($HOWBIG - $HOWBIG_YESTERDAY_FILE))
        #昨天-前天
        SIZE_DIFF_PREVIOUS=$(($HOWBIG_YESTERDAY_FILE - $HOWBIG_DAY_BEFORE_YESTERDAY_FILE))

        # 计算前天与昨天的大小差异的10%
        ABS_SIZE_DIFF_PREVIOUS=$(echo "if ($SIZE_DIFF_PREVIOUS < 0) -$SIZE_DIFF_PREVIOUS else $SIZE_DIFF_PREVIOUS" | bc)
        TEN_PERCENT_PREVIOUS_DIFF=$(echo "scale=0; $ABS_SIZE_DIFF_PREVIOUS * 0.10" | bc)

        # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$SIZE_DIFF_TODAY > $TEN_PERCENT_PREVIOUS_DIFF" | bc)
        SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG < $HOWBIG_YESTERDAY_FILE" | bc)

        if [ "$SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$SIZE_DIFF_TODAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 发生变化的文件：<code>${CURRENTDAY_FILE}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$SIZE_DIFF_PREVIOUS</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$TEN_PERCENT_PREVIOUS_DIFF</font>
            "
            echo -e "$EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $CURRENTDAY_FILE"
    fi
}

checkdd
# 读取日志文件内容并发送到钉钉
if [ -f "$LOG_FILE" ]; then
    CONTENT=$(cat "$LOG_FILE")
    send_to_dingtalk "$CONTENT"
    rm "$LOG_FILE"  # 发送完毕后删除日志文件
else
    echo "No log file found for today."
fi

