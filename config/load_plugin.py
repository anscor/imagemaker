import os
import yaml
import codecs

# 插件目录
PLUGINS_PATH = "/app/Miao-Yunzai/plugins"
# 自定义插件目录
CUSTOM_PATH = "/app/Miao-Yunzai/custom_plugins"

# 默认插件配置目录
DEFAULT_PATH = "/app/Miao-Yunzai/config/default_plugins"
# 插件配置目录
PLUGINS_CONFIG_PATH = "/app/Miao-Yunzai/config/plugins"
# 插件配置文件
PLUGINS_CONFIG_FILE = os.path.join(PLUGINS_CONFIG_PATH, "config.yaml")

skips = set()


class Plugin:
    def __init__(self, name: str, data: dict) -> None:
        # 插件名称
        self.name = name
        # 插件初始化脚本
        self.init = data.get("init", self.name + ".sh")
        # 当前插件目录
        self.plugin_path = os.path.join(CUSTOM_PATH, self.name)
        self.command = " ".join(
            [
                "git clone",
                ("--depth=%d" % int(data["depth"]))
                if data.get("depth")
                else "",
                data["url"],
                self.plugin_path,
            ]
        )
        # 远程分支名
        self.branch = data.get("branch", "master")
        # 更新插件脚本
        self.update_script = os.path.join(DEFAULT_PATH, "update.sh")
        # 配置环境脚本
        self.env_script = os.path.join(DEFAULT_PATH, "env.sh")

        self._clone_plugin()
        # 建立软链接到插件目录中
        if (
            not os.path.exists(os.path.join(PLUGINS_PATH, self.name))
            and self.name not in skips
        ):
            os.system(
                "ln -s %s %s"
                % (self.plugin_path, os.path.join(PLUGINS_PATH, self.name))
            )
        self._update_plugin()

    def _clone_plugin(self):
        # 如果当前插件目录不存在，则从远程克隆
        if not os.path.exists(self.plugin_path):
            os.system(self.command)

    def _update_plugin(self):
        # 更新插件
        os.system(" ".join([self.update_script, self.name, self.branch]))

        # 回到插件目录
        os.chdir(PLUGINS_PATH)
        # 初始化脚本文件
        init_file = os.path.join(PLUGINS_CONFIG_PATH, self.init)
        # 如果不存在尝试从默认配置中获取
        if not os.path.exists(init_file):
            os.system(
                "cp %s %s"
                % (os.path.join(DEFAULT_PATH, self.init), PLUGINS_CONFIG_PATH)
            )
        # 如果还是不存在，则跳过初始化
        if os.path.exists(init_file):
            os.system(" ".join([self.env_script, self.name, init_file]))


if __name__ == "__main__":
    # 从默认配置中取出配置文件
    if not os.path.exists(PLUGINS_CONFIG_FILE):
        os.system(
            "cp %s %s"
            % (os.path.join(DEFAULT_PATH, "config.yaml"), PLUGINS_CONFIG_PATH)
        )
    # 链接默认的插件
    for plugin in os.listdir(PLUGINS_PATH):
        if not os.path.isdir(plugin):
            continue
        skips.add(plugin)
        if os.path.exists(os.path.join(CUSTOM_PATH, plugin)):
            continue
        os.system(
            "ln -s %s %s"
            % (os.path.abspath(plugin), os.path.join(CUSTOM_PATH, plugin))
        )

    # 读取配置文件并解析
    f = codecs.open(PLUGINS_CONFIG_FILE, "r", "utf-8")
    content = f.read()
    f.close()
    data: dict = yaml.load(stream=content, Loader=yaml.FullLoader)
    plugins: list = []
    for i, name in enumerate(data["plugins"]):
        plugins.append((name, data["plugins"][name], i))

    plugins = sorted(plugins, key=lambda t: (t[1].get("order") or (9999), t[2]))
    for plugin in plugins:
        Plugin(plugin[0], plugin[1])
