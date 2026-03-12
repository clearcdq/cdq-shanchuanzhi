#!/bin/bash
# baseline_check.sh - 系统安全基线核查脚本
# 功能：检查系统是否符合基本安全基线要求
# 作者：无敌山川志
# 日期：2026-03-10

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "====================================="
echo "   🔍 系统安全基线核查报告"
echo "   时间: $(date)"
echo "   用户: $(whoami)"
echo "====================================="

# 1. 系统基本信息检查
echo -e "\n${YELLOW}1. 系统基本信息${NC}"
echo "操作系统: $(lsb_release -d 2>/dev/null | cut -f2- -d':')"
echo "内核版本: $(uname -r)"
echo "主机名: $(hostname)"
echo " uptime: $(uptime -p)"

# 2. 用户账户安全检查
echo -e "\n${YELLOW}2. 用户账户安全${NC}"
echo "当前用户: $(whoami)"
echo "root账户状态: $(sudo passwd -S root 2>/dev/null | awk '{print $2}')"
echo "空密码账户数量: $(awk -F: '$2 == "" {print $1}' /etc/shadow | wc -l)"
echo "UID为0的非root账户: $(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/passwd | wc -l)"

# 3. 文件权限检查
echo -e "\n${YELLOW}3. 关键文件权限检查${NC}"
echo "/etc/passwd 权限: $(stat -c "%A" /etc/passwd)"
echo "/etc/shadow 权限: $(stat -c "%A" /etc/shadow)"
echo "/etc/gshadow 权限: $(stat -c "%A" /etc/gshadow)"
echo "/root 目录权限: $(stat -c "%A" /root)"

# 4. SSH 配置检查
echo -e "\n${YELLOW}4. SSH 安全配置${NC}"
if [ -f /etc/ssh/sshd_config ]; then
    echo "SSH允许root登录: $(grep -i "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | grep -v "^#")"
    echo "SSH使用协议: $(grep -i "^Protocol" /etc/ssh/sshd_config 2>/dev/null | grep -v "^#")"
    echo "SSH密码认证: $(grep -i "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | grep -v "^#")"
else
    echo "SSH配置文件未找到"
fi

# 5. 防火墙状态检查
echo -e "\n${YELLOW}5. 防火墙状态${NC}"
if command -v ufw >/dev/null 2>&1; then
    echo "UFW状态: $(ufw status | head -1)"
elif command -v iptables >/dev/null 2>&1; then
    echo "iptables规则数: $(iptables -L | wc -l)"
else
    echo "未检测到防火墙工具"
fi

# 6. 关键服务检查
echo -e "\n${YELLOW}6. 关键服务状态${NC}"
echo "SSH服务: $(systemctl is-active ssh 2>/dev/null || echo "unknown")"
echo "cron服务: $(systemctl is-active cron 2>/dev/null || echo "unknown")"
echo "rsyslog服务: $(systemctl is-active rsyslog 2>/dev/null || echo "unknown")"

# 7. 密码策略检查
echo -e "\n${YELLOW}7. 密码策略${NC}"
if [ -f /etc/login.defs ]; then
    echo "密码最小长度: $(grep -i "^PASS_MIN_LEN" /etc/login.defs 2>/dev/null | awk '{print $2}')"
    echo "密码过期天数: $(grep -i "^PASS_MAX_DAYS" /etc/login.defs 2>/dev/null | awk '{print $2}')"
else
    echo "login.defs未找到"
fi

# 8. 日志配置检查
echo -e "\n${YELLOW}8. 日志配置${NC}"
echo "syslog配置: $(ls -la /etc/rsyslog.d/ 2>/dev/null | wc -l) 个配置文件"
echo "日志轮转配置: $(ls -la /etc/logrotate.d/ 2>/dev/null | wc -l) 个配置文件"

# 9. 安全建议汇总
echo -e "\n${YELLOW}9. 安全建议汇总${NC}"
echo "✅ 建议1: 确保 /etc/shadow 权限为 600"
echo "✅ 建议2: 禁用root远程登录"
echo "✅ 建议3: 设置强密码策略"
echo "✅ 建议4: 定期更新系统补丁"
echo "✅ 建议5: 配置防火墙规则"

echo -e "\n${GREEN}基线核查完成！${NC}"
echo "如需详细报告，请运行: ./baseline_check.sh > baseline_report.txt"