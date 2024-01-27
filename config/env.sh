#!/usr/bin/env bash

set +e

name=$1
script=$2

GreenBG="\\033[42;37m"
YellowBG="\\033[43;37m"
BlueBG="\\033[44;37m"
Font="\\033[0m"

Version="${BlueBG}[版本]${Font}"
Info="${GreenBG}[信息]${Font}"
Warn="${YellowBG}[提示]${Font}"

HOME="/root"

if [[ ! -f "$HOME/.ovo/$name.ok" ]]; then
    set -e
    echo -e "\n ================ \n ${Info} ${GreenBG} 更新 ${name} 插件运行依赖 ${Font} \n ================ \n"
    . $script
    touch "${HOME}/.ovo/${name}.ok"
    set +e
fi

echo -e "\n ================ \n ${Version} ${BlueBG} ${name} 插件版本信息 ${Font} \n ================ \n"

git log -1 --pretty=format:"%h - %an, %ar (%cd) : %s"
