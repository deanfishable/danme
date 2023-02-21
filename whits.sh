#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN='\033[0m'

red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}

clear
echo "#############################################################"
echo -e "#               ${RED} onekey${PLAIN}                 #"
echo "#############################################################"
echo ""

read -rp "是否安装脚本？ [Y/N]：" yesno

if [[ $yesno =~ "Y"|"y" ]]; then
    kill -9 $(ps -ef | grep web | grep -v grep | awk '{print $2}') >/dev/null 2>&1
    rm -f web config.json
    yellow "开始安装..."
    wget -O temp.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
    unzip temp.zip xray
    RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
    mv xray web
    wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
    wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
    read -rp "请设置UUID（如无设置则使用脚本默认的）：" uuid
    if [[ -z $uuid ]]; then
        uuid="54f87cfd-6c03-45ef-bb3d-9fdacec80a9a"
    fi
    cat <<EOF > config.json
{
    "log": {
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"warning"
    },
    "dns": {
        "servers": [
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "inbounds": [
        {
            "port": 8080,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "54f87cfd-6c03-45ef-bb3d-9fdacec80a9a"
                    }
                ],
                "decryption": "none" 
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/app"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct",
            "settings": {
                "domainStrategy": "UseIPv4"
            }
        }
    ]
}
EOF
    nohup ./web -config=config.json &>/dev/null &
    green "ok！"
    echo ""
    yellow "再见"
else
    red "已取消安装，脚本退出！"
    exit 1
fi
