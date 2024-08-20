# .bashrc
alias shutdown='echo "关机？不好吧"'


# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi



function rm() {
    # 检查参数是否为 "-rf /" 或 "-rf /*"
    if [[ "$@" == "-rf /" || "$@" == "-rf /*" ]]; then
        echo "Dangerous command detected: rm -rf / or rm -rf /*"
    else
        # 否则执行原本的 rm 命令
        /bin/rm "$@"
    fi
}


function cd() {
    # 获取第一个参数（即要跳转的目录）
    local target="$1"

    # 如果要跳转到的目录是 /etc 或 /etc/* 下的子目录，则跳转到 /var
    if [[ "$target" == "/" || "$target" == "/"* ]]; then
        echo "Cannot change to root directory"
    elif [[ 
        "$target" == "/etc" || "$target" == "/etc/"* || 
        "$target" == "/bin" || "$target" == "/bin/"* ||
        "$target" == "/boot" || "$target" == "/boot/"* ||
        "$target" == "/data" || "$target" == "/data/"* ||
        "$target" == "/dev" || "$target" == "/dev/"* ||
        "$target" == "/etc" || "$target" == "/etc/"* ||
        "$target" == "/home" || "$target" == "/home/"* ||
        "$target" == "/lib" || "$target" == "/lib/"* ||
        "$target" == "/lib64" || "$target" == "/lib64/"* ||
        "$target" == "/media" || "$target" == "/media/"* ||
        "$target" == "/mnt" || "$target" == "/mnt/"* ||
        "$target" == "/opt" || "$target" == "/opt/"* ||
        "$target" == "/proc" || "$target" == "/proc/"* ||
        "$target" == "/root" || "$target" == "/root/"* ||
        "$target" == "/run" || "$target" == "/run/"* ||
        "$target" == "/sbin" || "$target" == "/sbin/"* ||
        "$target" == "/srv" || "$target" == "/srv/"* ||
        "$target" == "/sys" || "$target" == "/sys/"* ||
        "$target" == "/tmp" || "$target" == "/tmp/"*  ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin cd "$@"
    fi
}

function vim() {
    # 获取第一个参数（即要跳转的目录）
    local target="$1"

    # 如果要跳转到的目录是 /etc 或 /etc/* 下的子目录，则跳转到 /var
    if [[ 
        "$target" == "/etc" || "$target" == "/etc/"* || 
        "$target" == "/bin" || "$target" == "/bin/"* ||
        "$target" == "/boot" || "$target" == "/boot/"* ||
        "$target" == "/data" || "$target" == "/data/"* ||
        "$target" == "/dev" || "$target" == "/dev/"* ||
        "$target" == "/etc" || "$target" == "/etc/"* ||
        "$target" == "/home" || "$target" == "/home/"* ||
        "$target" == "/lib" || "$target" == "/lib/"* ||
        "$target" == "/lib64" || "$target" == "/lib64/"* ||
        "$target" == "/media" || "$target" == "/media/"* ||
        "$target" == "/mnt" || "$target" == "/mnt/"* ||
        "$target" == "/opt" || "$target" == "/opt/"* ||
        "$target" == "/proc" || "$target" == "/proc/"* ||
        "$target" == "/root" || "$target" == "/root/"* ||
        "$target" == "/run" || "$target" == "/run/"* ||
        "$target" == "/sbin" || "$target" == "/sbin/"* ||
        "$target" == "/srv" || "$target" == "/srv/"* ||
        "$target" == "/sys" || "$target" == "/sys/"* ||
        "$target" == "/tmp" || "$target" == "/tmp/"*  ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin vim "$@"
    fi
}

function vi() {
    # 获取第一个参数（即要跳转的目录）
    local target="$1"

    # 如果要跳转到的目录是 /etc 或 /etc/* 下的子目录，则跳转到 /var
    if [[ 
        "$target" == "/etc" || "$target" == "/etc/"* || 
        "$target" == "/bin" || "$target" == "/bin/"* ||
        "$target" == "/boot" || "$target" == "/boot/"* ||
        "$target" == "/data" || "$target" == "/data/"* ||
        "$target" == "/dev" || "$target" == "/dev/"* ||
        "$target" == "/etc" || "$target" == "/etc/"* ||
        "$target" == "/home" || "$target" == "/home/"* ||
        "$target" == "/lib" || "$target" == "/lib/"* ||
        "$target" == "/lib64" || "$target" == "/lib64/"* ||
        "$target" == "/media" || "$target" == "/media/"* ||
        "$target" == "/mnt" || "$target" == "/mnt/"* ||
        "$target" == "/opt" || "$target" == "/opt/"* ||
        "$target" == "/proc" || "$target" == "/proc/"* ||
        "$target" == "/root" || "$target" == "/root/"* ||
        "$target" == "/run" || "$target" == "/run/"* ||
        "$target" == "/sbin" || "$target" == "/sbin/"* ||
        "$target" == "/srv" || "$target" == "/srv/"* ||
        "$target" == "/sys" || "$target" == "/sys/"* ||
        "$target" == "/tmp" || "$target" == "/tmp/"*  ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin vi "$@"
    fi
}

function cat() {
    # 获取第一个参数（即要跳转的目录）
    local target="$1"

    # 如果要跳转到的目录是 /etc 或 /etc/* 下的子目录，则跳转到 /var
    if [[ 
        "$target" == "/etc" || "$target" == "/etc/"* || 
        "$target" == "/bin" || "$target" == "/bin/"* ||
        "$target" == "/boot" || "$target" == "/boot/"* ||
        "$target" == "/data" || "$target" == "/data/"* ||
        "$target" == "/dev" || "$target" == "/dev/"* ||
        "$target" == "/etc" || "$target" == "/etc/"* ||
        "$target" == "/home" || "$target" == "/home/"* ||
        "$target" == "/lib" || "$target" == "/lib/"* ||
        "$target" == "/lib64" || "$target" == "/lib64/"* ||
        "$target" == "/media" || "$target" == "/media/"* ||
        "$target" == "/mnt" || "$target" == "/mnt/"* ||
        "$target" == "/opt" || "$target" == "/opt/"* ||
        "$target" == "/proc" || "$target" == "/proc/"* ||
        "$target" == "/root" || "$target" == "/root/"* ||
        "$target" == "/run" || "$target" == "/run/"* ||
        "$target" == "/sbin" || "$target" == "/sbin/"* ||
        "$target" == "/srv" || "$target" == "/srv/"* ||
        "$target" == "/sys" || "$target" == "/sys/"* ||
        "$target" == "/tmp" || "$target" == "/tmp/"* ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin cat "$@"
    fi
}

function tail() {
    # 获取第一个参数（即要跳转的目录）
    local target="$1"

    # 如果要跳转到的目录是 /etc 或 /etc/* 下的子目录，则跳转到 /var
    if [[ 
        "$target" == "/etc" || "$target" == "/etc/"* || 
        "$target" == "/bin" || "$target" == "/bin/"* ||
        "$target" == "/boot" || "$target" == "/boot/"* ||
        "$target" == "/data" || "$target" == "/data/"* ||
        "$target" == "/dev" || "$target" == "/dev/"* ||
        "$target" == "/etc" || "$target" == "/etc/"* ||
        "$target" == "/home" || "$target" == "/home/"* ||
        "$target" == "/lib" || "$target" == "/lib/"* ||
        "$target" == "/lib64" || "$target" == "/lib64/"* ||
        "$target" == "/media" || "$target" == "/media/"* ||
        "$target" == "/mnt" || "$target" == "/mnt/"* ||
        "$target" == "/opt" || "$target" == "/opt/"* ||
        "$target" == "/proc" || "$target" == "/proc/"* ||
        "$target" == "/root" || "$target" == "/root/"* ||
        "$target" == "/run" || "$target" == "/run/"* ||
        "$target" == "/sbin" || "$target" == "/sbin/"* ||
        "$target" == "/srv" || "$target" == "/srv/"* ||
        "$target" == "/sys" || "$target" == "/sys/"* ||
        "$target" == "/tmp" || "$target" == "/tmp/"* ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin tail "$@"
    fi
}

function ll() {
    # 获取第一个参数（即要跳转的目录）
    local target="$1"

    # 如果要跳转到的目录是 /etc 或 /etc/* 下的子目录，则跳转到 /var
    if [[ 
        "$target" == "/etc" || "$target" == "/etc/"* || 
        "$target" == "/bin" || "$target" == "/bin/"* ||
        "$target" == "/boot" || "$target" == "/boot/"* ||
        "$target" == "/data" || "$target" == "/data/"* ||
        "$target" == "/dev" || "$target" == "/dev/"* ||
        "$target" == "/etc" || "$target" == "/etc/"* ||
        "$target" == "/home" || "$target" == "/home/"* ||
        "$target" == "/lib" || "$target" == "/lib/"* ||
        "$target" == "/lib64" || "$target" == "/lib64/"* ||
        "$target" == "/media" || "$target" == "/media/"* ||
        "$target" == "/mnt" || "$target" == "/mnt/"* ||
        "$target" == "/opt" || "$target" == "/opt/"* ||
        "$target" == "/proc" || "$target" == "/proc/"* ||
        "$target" == "/root" || "$target" == "/root/"* ||
        "$target" == "/run" || "$target" == "/run/"* ||
        "$target" == "/sbin" || "$target" == "/sbin/"* ||
        "$target" == "/srv" || "$target" == "/srv/"* ||
        "$target" == "/sys" || "$target" == "/sys/"* ||
        "$target" == "/tmp" || "$target" == "/tmp/"* ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin ll "$@"
    fi
}


# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions