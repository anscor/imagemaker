#!/usr/bin/env bash

set +e

GreenBG="\\033[42;37m"
YellowBG="\\033[43;37m"
BlueBG="\\033[44;37m"
Font="\\033[0m"

Version="${BlueBG}[版本]${Font}"
Info="${GreenBG}[信息]${Font}"
Warn="${YellowBG}[提示]${Font}"

WORK_DIR="/app/Miao-Yunzai"
DEFAULT_PATH="/app/Miao-Yunzai/config/default_plugins"

if [ ! -z $GITHUB_PROXY ]; then
    git config --global http.https://github.com.proxy $GITHUB_PROXY
fi

if [[ ! -d "$HOME/.ovo" ]]; then
    mkdir ~/.ovo
fi

echo -e "\n ================ \n ${Info} ${GreenBG} 拉取 Miao-Yunzai 更新 ${Font} \n ================ \n"

cd $WORK_DIR

if [[ -z $(git status -s) ]]; then
    echo -e " ${Warn} ${YellowBG} 当前工作区有修改，尝试暂存后更新。${Font}"
    git add .
    git stash
    git pull origin master --allow-unrelated-histories --rebase
    git stash pop
else
    git pull origin master --allow-unrelated-histories
fi

if [[ ! -f "$HOME/.ovo/yunzai.ok" ]]; then
    set -e
    echo -e "\n ================ \n ${Info} ${GreenBG} 更新 Miao-Yunzai 运行依赖 ${Font} \n ================ \n"
    pnpm install -P
    touch ~/.ovo/yunzai.ok
    set +e
fi

echo -e "\n ================ \n ${Version} ${BlueBG} Miao-Yunzai 版本信息 ${Font} \n ================ \n"

git log -1 --pretty=format:"%h - %an, %ar (%cd) : %s"

echo -e "\n ================ \n ${Info} ${GreenBG} 加载插件 ${Font} \n ================ \n"
python $DEFAULT_PATH"/load_plugin.py"

set -e

cd $WORK_DIR

echo -e "\n ================ \n ${Info} ${GreenBG} 初始化 Docker 环境 ${Font} \n ================ \n"

if [ -f "./config/config/redis.yaml" ]; then
    sed -i 's/127.0.0.1/redis/g' ./config/config/redis.yaml
    echo -e "\n  修改Redis地址完成~  \n"
fi

echo -e "\n ================ \n ${Info} ${GreenBG} 启动 Miao-Yunzai ${Font} \n ================ \n"

set +e
node app
EXIT_CODE=$?

if [[ $EXIT_CODE != 0 ]]; then
    echo -e "\n ================ \n ${Warn} ${YellowBG} 启动 Miao-Yunzai 失败 ${Font} \n ================ \n"
    tail -f /dev/null
fi
