#!/bin/bash

# 钉钉机器人webhook地址
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=c713f4edcee44abc77de9b27c17d6de46e77c115bcb28deff9749a18fbbc2792"

# 日志文件路径
LOG_FILE="/usr/local/bin/changes.log"
send_file="/usr/local/bin/ddsend.txt"
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
# 整合通知消息
checkdd(){
    # 记录有文件变化的log
    file_path="/usr/local/bin/changes.log"
    # 要发送的文件路径
    send_file="/usr/local/bin/ddsend.txt"
    # 主机名
    HOSTNAME=$(hostname)
    # ip
    IP=$(hostname -I)
    # 当前时间
    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    # 当前日期
    CURRENT_DAY=$(date +"%Y%m%d")
    # 前一天日期
    PREVIOUS_DAY=$(date -d "yesterday" +"%Y%m%d")
    # 前两天日期
    TWO_DAYS_AGO=$(date -d "2 days ago" +"%Y%m%d")

#-----------------#imytrader------------------------------------------------
    imytrader_CURRENTDAY="/workspace/websites/mysqlbackup/xmam_imytrader.fx00.com/xmam_imytrader.fx00.com_$CURRENT_DAY.tar.gz"
    imytrader_YESTERDAY="/workspace/websites/mysqlbackup/xmam_imytrader.fx00.com/xmam_imytrader.fx00.com_$PREVIOUS_DAY.tar.gz"
    imytrader_TWO_DAYS_AGO="/workspace/websites/mysqlbackup/xmam_imytrader.fx00.com/xmam_imytrader.fx00.com_$TWO_DAYS_AGO.tar.gz"

    HOWBIG_imytrader_CURRENTDAY=$(stat --format="%s" "$imytrader_CURRENTDAY")
    HOWBIG_imytrader_YESTERDAY=$(stat --format="%s" "$imytrader_YESTERDAY")
    HOWBIG_imytrader_TWO_DAYS_AGO=$(stat --format="%s" "$imytrader_TWO_DAYS_AGO")

    #今天-昨天
    imytrader_SIZE_DIFF_TODAY_YESTERDAY=$(($HOWBIG_imytrader_CURRENTDAY - $HOWBIG_imytrader_YESTERDAY))
    #昨天-前天
    imytrader_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(($HOWBIG_imytrader_YESTERDAY - $HOWBIG_imytrader_TWO_DAYS_AGO))
    # 计算前天与昨天的大小差异的10%
    imytrader_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(echo "if ($SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO < 0) -$SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO else $SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
    imytrader_TEN_DIFF=$(echo "scale=0; $ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO * 0.10" | bc)

    # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        imytrader_SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$SIZE_DIFF_TODAY_YESTERDAY > $SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
        imytrader_SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG_imytrader_CURRENTDAY < $HOWBIG_imytrader_YESTERDAY" | bc)
        if [ "$SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            imytrader_EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG_imytrader_CURRENTDAY</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$imytrader_SIZE_DIFF_TODAY_YESTERDAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 异常变化的文件：<code>${imytrader_CURRENTDAY}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$imytrader_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$imytrader_TEN_DIFF</font>
            "
            echo -e "$imytrader_EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $imytrader_CURRENTDAY"
    fi
#-----------------------------------------------------------------
#-----------------------------------------------------------------

#-------------------#lakefox----------------------------------------------
    lakefox_CURRENTDAY="/workspace/websites/mysqlbackup/xmam_lakefox.fx00.com/xmam_lakefox.fx00.com_$CURRENT_DAY.tar.gz"
    lakefox_YESTERDAY="/workspace/websites/mysqlbackup/xmam_lakefox.fx00.com/xmam_lakefox.fx00.com_$PREVIOUS_DAY.tar.gz"
    lakefox_TWO_DAYS_AGO="/workspace/websites/mysqlbackup/xmam_lakefox.fx00.com/xmam_lakefox.fx00.com_$TWO_DAYS_AGO.tar.gz"

    HOWBIG_lakefox_CURRENTDAY=$(stat --format="%s" "$lakefox_CURRENTDAY")
    HOWBIG_lakefox_YESTERDAY=$(stat --format="%s" "$lakefox_YESTERDAY")
    HOWBIG_lakefox_TWO_DAYS_AGO=$(stat --format="%s" "$lakefox_TWO_DAYS_AGO")

    #今天-昨天
    lakefox_SIZE_DIFF_TODAY_YESTERDAY=$(($HOWBIG_imytrader_CURRENTDAY - $HOWBIG_imytrader_YESTERDAY))
    #昨天-前天
    lakefox_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(($HOWBIG_imytrader_YESTERDAY - $HOWBIG_imytrader_TWO_DAYS_AGO))
    # 计算前天与昨天的大小差异的10%
    lakefox_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(echo "if ($lakefox_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO < 0) -$lakefox_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO else $lakefox_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
    lakefox_TEN_DIFF=$(echo "scale=0; $lakefox_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO * 0.10" | bc)

    # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        lakefox_SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$lakefox_SIZE_DIFF_TODAY_YESTERDAY > $lakefox_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
        lakefox_SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG_imytrader_CURRENTDAY < $HOWBIG_imytrader_YESTERDAY" | bc)
        if [ "$lakefox_SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$lakefox_SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            lakefox_EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG_lakefox_CURRENTDAY</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$lakefox_SIZE_DIFF_TODAY_YESTERDAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 异常变化的文件：<code>${lakefox_CURRENTDAY}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$lakefox_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$lakefox_TEN_DIFF</font>
            "
            echo -e "$lakefox_EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $lakefox_CURRENTDAY"
    fi
#-----------------------------------------------------------------

#-------------------#mam----------------------------------------------
    mam_CURRENTDAY="/workspace/websites/mysqlbackup/xmam_mam.fx00.com/xmam_mam.fx00.com_$CURRENT_DAY.tar.gz"
    mam_YESTERDAY="/workspace/websites/mysqlbackup/xmam_mam.fx00.com/xmam_mam.fx00.com_$PREVIOUS_DAY.tar.gz"
    mam_TWO_DAYS_AGO="/workspace/websites/mysqlbackup/xmam_mam.fx00.com/xmam_mam.fx00.com_$TWO_DAYS_AGO.tar.gz"

    HOWBIG_mam_CURRENTDAY=$(stat --format="%s" "$mam_CURRENTDAY")
    HOWBIG_mam_YESTERDAY=$(stat --format="%s" "$mam_YESTERDAY")
    HOWBIG_mam_TWO_DAYS_AGO=$(stat --format="%s" "$mam_TWO_DAYS_AGO")

    #今天-昨天
    mam_SIZE_DIFF_TODAY_YESTERDAY=$(($HOWBIG_imytrader_CURRENTDAY - $HOWBIG_imytrader_YESTERDAY))
    #昨天-前天
    mam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(($HOWBIG_imytrader_YESTERDAY - $HOWBIG_imytrader_TWO_DAYS_AGO))
    # 计算前天与昨天的大小差异的10%
    mam_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(echo "if ($mam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO < 0) -$mam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO else $mam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
    mam_TEN_DIFF=$(echo "scale=0; $mam_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO * 0.10" | bc)

    # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        mam_SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$mam_SIZE_DIFF_TODAY_YESTERDAY > $mam_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
        mam_SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG_imytrader_CURRENTDAY < $HOWBIG_imytrader_YESTERDAY" | bc)
        if [ "$mam_SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$mam_SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            mam_EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG_mam_CURRENTDAY</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$mam_SIZE_DIFF_TODAY_YESTERDAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 异常变化的文件：<code>${mam_CURRENTDAY}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$mam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$mam_TEN_DIFF</font>
            "
            echo -e "$mam_EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $mam_CURRENTDAY"
    fi
#-----------------------------------------------------------------
#-----------------------------------------------------------------

#---------------------#rvfx--------------------------------------------
    rvfx_CURRENTDAY="/workspace/websites/mysqlbackup/xmam_rvfx.fx00.com/xmam_rvfx.fx00.com_$CURRENT_DAY.tar.gz"
    rvfx_YESTERDAY="/workspace/websites/mysqlbackup/xmam_rvfx.fx00.com/xmam_rvfx.fx00.com_$PREVIOUS_DAY.tar.gz"
    rvfx_TWO_DAYS_AGO="/workspace/websites/mysqlbackup/xmam_rvfx.fx00.com/xmam_rvfx.fx00.com_$TWO_DAYS_AGO.tar.gz"

    HOWBIG_rvfx_CURRENTDAY=$(stat --format="%s" "$rvfx_CURRENTDAY")
    HOWBIG_rvfx_YESTERDAY=$(stat --format="%s" "$rvfx_YESTERDAY")
    HOWBIG_rvfx_TWO_DAYS_AGO=$(stat --format="%s" "$rvfx_TWO_DAYS_AGO")

    #今天-昨天
    rvfx_SIZE_DIFF_TODAY_YESTERDAY=$(($HOWBIG_imytrader_CURRENTDAY - $HOWBIG_imytrader_YESTERDAY))
    #昨天-前天
    rvfx_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(($HOWBIG_imytrader_YESTERDAY - $HOWBIG_imytrader_TWO_DAYS_AGO))
    # 计算前天与昨天的大小差异的10%
    rvfx_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(echo "if ($rvfx_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO < 0) -$rvfx_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO else $rvfx_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
    rvfx_TEN_DIFF=$(echo "scale=0; $rvfx_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO * 0.10" | bc)

    # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        rvfx_SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$rvfx_SIZE_DIFF_TODAY_YESTERDAY > $rvfx_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
        rvfx_SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG_imytrader_CURRENTDAY < $HOWBIG_imytrader_YESTERDAY" | bc)
        if [ "$rvfx_SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$rvfx_SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            rvfx_EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG_rvfx_CURRENTDAY</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$rvfx_SIZE_DIFF_TODAY_YESTERDAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 异常变化的文件：<code>${rvfx_CURRENTDAY}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$rvfx_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$rvfx_TEN_DIFF</font>
            "
            echo -e "$rvfx_EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $rvfx_CURRENTDAY"
    fi
#-----------------------------------------------------------------
#-----------------------------------------------------------------

#-------------------#vatee----------------------------------------------
    vatee_CURRENTDAY="/workspace/websites/mysqlbackup/xmam_vatee.fx00.com/xmam_vatee.fx00.com_$CURRENT_DAY.tar.gz"
    vatee_YESTERDAY="/workspace/websites/mysqlbackup/xmam_vatee.fx00.com/xmam_vatee.fx00.com_$PREVIOUS_DAY.tar.gz"
    vatee_TWO_DAYS_AGO="/workspace/websites/mysqlbackup/xmam_vatee.fx00.com/xmam_vatee.fx00.com_$TWO_DAYS_AGO.tar.gz"

    HOWBIG_vatee_CURRENTDAY=$(stat --format="%s" "$vatee_CURRENTDAY")
    HOWBIG_vatee_YESTERDAY=$(stat --format="%s" "$vatee_YESTERDAY")
    HOWBIG_vatee_TWO_DAYS_AGO=$(stat --format="%s" "$vatee_TWO_DAYS_AGO")

    #今天-昨天
    vatee_SIZE_DIFF_TODAY_YESTERDAY=$(($HOWBIG_imytrader_CURRENTDAY - $HOWBIG_imytrader_YESTERDAY))
    #昨天-前天
    vatee_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(($HOWBIG_imytrader_YESTERDAY - $HOWBIG_imytrader_TWO_DAYS_AGO))
    # 计算前天与昨天的大小差异的10%
    vatee_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(echo "if ($vatee_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO < 0) -$vatee_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO else $vatee_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
    vatee_TEN_DIFF=$(echo "scale=0; $vatee_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO * 0.10" | bc)

    # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        vatee_SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$vatee_SIZE_DIFF_TODAY_YESTERDAY > $vatee_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
        vatee_SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG_imytrader_CURRENTDAY < $HOWBIG_imytrader_YESTERDAY" | bc)
        if [ "$vatee_SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$vatee_SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            vatee_EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG_vatee_CURRENTDAY</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$vatee_SIZE_DIFF_TODAY_YESTERDAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 异常变化的文件：<code>${vatee_CURRENTDAY}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$vatee_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$vatee_TEN_DIFF</font>
            "
            echo -e "$vatee_EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $vatee_CURRENTDAY"
    fi
#-----------------------------------------------------------------
#-----------------------------------------------------------------

#--------------------#xmam---------------------------------------------
    xmam_CURRENTDAY="/workspace/websites/mysqlbackup/xmam_xmam.fx00.com/xmam_xmam.fx00.com_$CURRENT_DAY.tar.gz"
    xmam_YESTERDAY="/workspace/websites/mysqlbackup/xmam_xmam.fx00.com/xmam_xmam.fx00.com_$PREVIOUS_DAY.tar.gz"
    xmam_TWO_DAYS_AGO="/workspace/websites/mysqlbackup/xmam_xmam.fx00.com/xmam_xmam.fx00.com_$TWO_DAYS_AGO.tar.gz"

    HOWBIG_xmam_CURRENTDAY=$(stat --format="%s" "$xmam_CURRENTDAY")
    HOWBIG_xmam_YESTERDAY=$(stat --format="%s" "$xmam_YESTERDAY")
    HOWBIG_xmam_TWO_DAYS_AGO=$(stat --format="%s" "$xmam_TWO_DAYS_AGO")

    #今天-昨天
    xmam_SIZE_DIFF_TODAY_YESTERDAY=$(($HOWBIG_imytrader_CURRENTDAY - $HOWBIG_imytrader_YESTERDAY))
    #昨天-前天
    xmam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(($HOWBIG_imytrader_YESTERDAY - $HOWBIG_imytrader_TWO_DAYS_AGO))
    # 计算前天与昨天的大小差异的10%
    xmam_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO=$(echo "if ($xmam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO < 0) -$xmam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO else $xmam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
    xmam_TEN_DIFF=$(echo "scale=0; $xmam_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO * 0.10" | bc)

    # 判断条件：
        # 1. 今天的大小差异是否大于前天与昨天的差异的10%
        # 2. 今天的大小是否小于昨天的大小
        xmam_SIZE_DIFF_TODAY_GT_THRESHOLD=$(echo "$xmam_SIZE_DIFF_TODAY_YESTERDAY > $xmam_ABS_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO" | bc)
        xmam_SIZE_TODAY_LT_YESTERDAY=$(echo "$HOWBIG_imytrader_CURRENTDAY < $HOWBIG_imytrader_YESTERDAY" | bc)
        if [ "$xmam_SIZE_DIFF_TODAY_GT_THRESHOLD" -eq 1 ] || [ "$xmam_SIZE_TODAY_LT_YESTERDAY" -eq 1 ]; then
            xmam_EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【文件大小】:</font><font color=#FF0000>$HOWBIG_xmam_CURRENTDAY</font>
> ##### <font color=#67C23A> 【大小差异】:</font><font color=#FF0000>$xmam_SIZE_DIFF_TODAY_YESTERDAY</font>
> ##### <font color=#67C23A> 【事件详情】:</font>
>- 异常变化的文件：<code>${xmam_CURRENTDAY}</code>
>- 前天与昨天的大小差异：<font color=#FF0000>$xmam_SIZE_DIFF_PREVIOUS_TWO_DAYS_AGO</font>
>- 前天与昨天的差异的10%：<font color=#FF0000>$xmam_TEN_DIFF</font>
            "
            echo -e "$xmam_EVENT_MESSAGE" >> "$LOG_FILE"  # 记录变化信息到日志文件
        fi
    else
        echo "当前文件不存在: $xmam_CURRENTDAY"
    fi
#-----------------------------------------------------------------

match_count=$(grep -o "inotify事件类型" "$file_path" | wc -l)
match_file=$(grep -oP '异常变化的文件：<code>\K[^<]+' "$file_path")
    EVENT_MESSAGE="
##### 文件变化告警
> ##### <font color=#67C23A> 【服务器名称】: </font> <font color=#FF0000>$HOSTNAME</font>
> ##### <font color=#67C23A> 【服务器IP】:</font><font color=#FF0000>$IP</font>
> ##### <font color=#67C23A> 【告警时间】:</font><font color=#FF0000>$CURRENT_TIME</font>
> ##### <font color=#67C23A> 【发生改变的文件个数】:</font><font color=#FF0000>$match_count</font>
> ##### <font color=#67C23A> 【异常的文件】:</font><font color=#FF0000>$match_file</font>
"
echo -e "$EVENT_MESSAGE" >> "$send_file"  # 记录变化信息到日志文件

}


# 读取日志文件内容并发送到钉钉
if [ -f "$LOG_FILE" ]; then
    checkdd
    CONTENT=$(cat "$send_file")
    send_to_dingtalk "$CONTENT"
    rm "$LOG_FILE"  # 发送完毕后删除日志文件
    rm "$send_file"
else
    echo "No log file found for today."
fi

