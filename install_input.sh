#!/bin/bash
# 安装拼音输入法（基于 fcitx），适用于 Kali Linux
# 注意：此脚本需要 sudo 权限

set -e

echo "=== 开始安装 ==="

# 更新软件包索引
echo "[1/4] 更新 apt 软件包列表..."
sudo apt-get update -y

# 安装 fcitx 核心及拼音模块
echo "[2/4] 安装 fcitx 与拼音输入法..."
sudo apt-get install -y fcitx-pinyin fcitx-config-gtk

# 配置环境变量
echo "[3/4] 配置环境变量（追加到 ~/.profile）..."
cat >> ~/.profile <<'EOF'

# --- fcitx configuration added by install_input.sh ---
export GTK_IM_MODULE=fcitx
export QT4_IM_MODULE=fcitx
export QT5_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# ----------------------------------------------------
EOF

# 启用 fcitx
echo "[4/4] 设置 fcitx 为默认输入法框架..."
if command -v fcitx &> /dev/null; then
    echo "fcitx 已安装。"
else
    echo "fcitx 未正确安装，请检查上面的错误信息。"
    exit 1
fi

echo "=== 安装完成 ==="
echo
echo "后续步骤："
echo "1. 请重新登录系统或重启，使环境变量生效。"
echo "2. 在图形界面中打开 \"fcitx 配置\"（可运行 fcitx-config-gtk），添加\"拼訑\"输入法，并调整顺序。"
echo "3. 以后可通过 Ctrl+Space 或任务栏图标切换输入法。"
echo
echo "注意：如需使用 QQ 官方的输入法客户端，需自行从腾讯官网下载linux版本并运行其安装包。"
