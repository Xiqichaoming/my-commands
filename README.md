# my-commands

这是一个用来整理和沉淀快捷常用功能实现的脚本仓库。仓库的根目录下存放了一系列特定的 Shell（主要为 zsh 或 bash）脚本，每一个脚本对应解决一个特定的痛点或功能需求。

## 使用方法

本仓库的脚本主要设计为即下即用。你可以使用 `ghcd` 等工具直接下载对应的脚本文件并执行。

例如，使用 `ghcd` 下载并执行某个脚本：

```bash
# 下载对应的脚本文件
ghcd <repository_url>/<script_name>.sh

# 赋予可执行权限并运行
chmod +x <script_name>.sh
./<script_name>.sh
```

## 脚本列表

* **`npm-install.sh`**: 为 Linux 环境一键安装 Node.js 和 npm 的配置脚本。优先尝试系统包管理器（需 sudo），若无权限则自动回退下载最新稳定版 `nvm` 进行用户级安装。

---

*随着更多便捷脚本的加入，此列表将持续更新。*
