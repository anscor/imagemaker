#!/usr/bin/env bash

set +e

name=$1
remote_branch=$2
plugin_path="/app/Miao-Yunzai/plugins/${name}"

GreenBG="\\033[42;37m"
YellowBG="\\033[43;37m"
BlueBG="\\033[44;37m"
Font="\\033[0m"

Version="${BlueBG}[版本]${Font}"
Info="${GreenBG}[信息]${Font}"
Warn="${YellowBG}[提示]${Font}"

HOME="/root"

echo -e "\n ================ \n ${Info} ${GreenBG} 拉取 ${name}插件 更新 ${Font} \n ================ \n"

cd $plugin_path

if [[ -n $(git status -s) ]]; then
    echo -e " ${Warn} ${YellowBG} 当前工作区有修改，尝试暂存后更新。${Font}"
    git add .
    git stash
    git pull origin $remote_branch --allow-unrelated-histories --rebase
    git stash pop
else
    git pull origin $remote_branch --allow-unrelated-histories
fi
