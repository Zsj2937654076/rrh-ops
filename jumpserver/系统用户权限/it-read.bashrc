# .bashrc
alias rm='echo "没权限"'
alias cp='echo "没权限"'
alias mv='echo "没权限"'
alias mkdir='echo "没权限"'
alias touch='echo "没权限"'
alias chmod='echo "没权限"'
alias chown='echo "没权限"'
alias chgrp='echo "没权限"'
alias ln='echo "没权限"'
alias sudo='echo "没权限"'
alias su='echo "没权限"'
alias reboot='echo "没权限"'
alias shutdown='echo "没权限"'
alias poweroff='echo "没权限"'
alias halt='echo "没权限"'
alias umount='echo "没权限"'
alias mount='echo "没权限"'
alias df='echo "没权限"'
alias du='echo "没权限"'
alias find='echo "没权限"'
alias tar='echo "没权限"'
alias zip='echo "没权限"'
alias unzip='echo "没权限"'
alias wget='echo "没权限"'
alias curl='echo "没权限"'
alias ping='echo "没权限"'
alias traceroute='echo "没权限"'
alias route='echo "没权限"'
alias ifconfig='echo "没权限"'
alias netstat='echo "没权限"'
alias nmap='echo "没权限"'
alias ssh='echo "没权限"'
alias scp='echo "没权限"'
alias rsync='echo "没权限"'
alias ssh-keygen='echo "没权限"'
alias ssh-keyscan='echo "没权限"'
alias ssh-agent='echo "没权限"'
alias ssh-add='echo "没权限"'
alias ssh-copy-id='echo "没权限"'
alias sshd='echo "没权限"'
alias sftp='echo "没权限"'
alias ftp='echo "没权限"'
alias telnet='echo "没权限"'
alias nc='echo "没权限"'
alias ncat='echo "没权限"'
alias netcat='echo "没权限"'
alias nslookup='echo "没权限"'
alias nano='echo "没权限"'



# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

cd /workspace

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
        "$target" == "/tmp" || "$target" == "/tmp/"* || 
        "$target" == "/usr" || "$target" == "/usr/"* ||
        "$target" == "/var" || "$target" == "/var/"* ]]; then
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
        "$target" == "/tmp" || "$target" == "/tmp/"* || 
        "$target" == "/usr" || "$target" == "/usr/"* ||
        "$target" == "/var" || "$target" == "/var/"* ]]; then
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
        "$target" == "/tmp" || "$target" == "/tmp/"* || 
        "$target" == "/usr" || "$target" == "/usr/"* ||
        "$target" == "/var" || "$target" == "/var/"* ]]; then
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
        "$target" == "/tmp" || "$target" == "/tmp/"* || 
        "$target" == "/usr" || "$target" == "/usr/"* ||
        "$target" == "/var" || "$target" == "/var/"* ]]; then
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
        "$target" == "/tmp" || "$target" == "/tmp/"* || 
        "$target" == "/usr" || "$target" == "/usr/"* ||
        "$target" == "/var" || "$target" == "/var/"* ]]; then
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
        "$target" == "/tmp" || "$target" == "/tmp/"* || 
        "$target" == "/usr" || "$target" == "/usr/"* ||
        "$target" == "/var" || "$target" == "/var/"* ]]; then
        builtin cd /workspace
    else
        # 否则，执行正常的 cd 命令
        builtin ll "$@"
    fi
}





# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions