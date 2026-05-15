#!/usr/bin/env zsh

# ============================================================
# 脚本名称: npm-install.sh
# 功能描述: 为 Linux 安装 npm
#   1. 优先检查 sudo 权限，有则用包管理器安装 nodejs+npm
#   2. 无 sudo 权限则通过 nvm 安装 node（自带 npm）
# ============================================================

set -e  # 遇到错误立即退出

# ---------- 颜色输出 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ---------- 检查命令是否存在 ----------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------- 检查 sudo 权限 ----------
check_sudo() {
    # 如果已经是 root，直接认为有权限
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi
    # 尝试用 sudo -n 非交互式验证，超时 5 秒
    if sudo -n true 2>/dev/null; then
        return 0
    else
        # 交互式询问用户密码
        if sudo -v 2>/dev/null; then
            return 0
        else
            return 1
        fi
    fi
}

# ---------- 检测包管理器 ----------
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists zypper; then
        echo "zypper"
    elif command_exists apk; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# ---------- 通过包管理器安装 ----------
install_via_package_manager() {
    local pm="$1"

    info "检测到 sudo 权限，使用包管理器安装..."
    info "包管理器类型: $pm"

    case "$pm" in
        apt)
            sudo apt-get update
            sudo apt-get install -y nodejs npm
            ;;
        dnf)
            sudo dnf install -y nodejs npm
            ;;
        yum)
            sudo yum install -y nodejs npm
            ;;
        pacman)
            sudo pacman -Syu --noconfirm nodejs npm
            ;;
        zypper)
            sudo zypper install -y nodejs npm
            ;;
        apk)
            sudo apk add --no-cache nodejs npm
            ;;
        *)
            error "不支持的包管理器，无法通过系统包管理安装。"
            ;;
    esac

    info "通过包管理器安装完成！"
}

# ---------- 通过 nvm 安装 ----------
install_via_nvm() {
    info "无 sudo 权限，将通过 nvm 安装 node 和 npm..."

    # 如果 nvm 已安装，直接使用；否则先安装 nvm
    if ! command_exists nvm; then
        # 检查是否已加载 nvm 脚本但未执行
        if [ -s "$HOME/.nvm/nvm.sh" ]; then
            source "$HOME/.nvm/nvm.sh"
        else
            info "正在安装 nvm..."
            # 获取最新版 nvm 的版本号并安装
            LATEST_NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
            if [ -z "$LATEST_NVM_VERSION" ]; then
                warn "获取 nvm 最新版本失败，使用后备版本 v0.40.1"
                LATEST_NVM_VERSION="v0.40.1"
            fi
            curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${LATEST_NVM_VERSION}/install.sh" | bash

            # 加载 nvm 到当前 shell
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

            info "nvm 安装完成"
        fi
    fi

    # 确认 nvm 命令可用
    if ! command_exists nvm; then
        error "nvm 安装后仍不可用，请手动执行: source ~/.zshrc"
    fi

    # 安装 Node.js LTS 版本（自带 npm）
    info "正在安装 Node.js LTS 版本..."
    nvm install --lts
    nvm use --lts

    info "通过 nvm 安装完成！"
    info "Node 版本: $(node --version)"
    info "npm 版本:  $(npm --version)"
}

# ---------- 主流程 ----------
main() {
    echo ""
    echo "============================================"
    echo "     Linux 环境 npm 安装脚本"
    echo "============================================"
    echo ""

    # 如果 npm 已安装，直接退出
    if command_exists npm; then
        info "npm 已安装，版本: $(npm --version)"
        exit 0
    fi

    # 如果有 sudo 权限，走包管理器
    if check_sudo; then
        local pm=$(detect_package_manager)
        if [ "$pm" = "unknown" ]; then
            warn "未找到支持的包管理器，降级为 nvm 安装..."
            install_via_nvm
        else
            install_via_package_manager "$pm"
        fi
    else
        warn "无 sudo 权限，使用 nvm 安装..."
        install_via_nvm
    fi

    # 最终验证
    echo ""
    if command_exists npm; then
        info "✅ npm 安装成功！版本: $(npm --version)"
    else
        error "安装失败，请检查错误信息。"
    fi
}

# 执行主函数
main