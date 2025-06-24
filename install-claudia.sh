#!/bin/bash

# Claudia 终极管理脚本 for macOS
# 包含：安装、更新、修复、卸载等完整功能

set -e  # 遇到错误就退出

# 版本信息
SCRIPT_VERSION="2.0.0"
SCRIPT_DATE="2025-06-23"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 全局变量
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$SCRIPT_DIR/claudia-manager.log"
DEBUG_MODE=false
ARCH=$(uname -m)
USE_MIRROR=false

# 初始化日志
init_log() {
    echo "=== Claudia Manager Log ===" > "$LOG_FILE"
    echo "Version: $SCRIPT_VERSION" >> "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "Architecture: $ARCH" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# 辅助函数
print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo "[HEADER] $1" >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    echo "[SUCCESS] $1" >> "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    echo "[WARNING] $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    echo "[ERROR] $1" >> "$LOG_FILE"
}

print_info() {
    echo -e "${MAGENTA}ℹ️  $1${NC}"
    echo "[INFO] $1" >> "$LOG_FILE"
}

debug_log() {
    if [ "$DEBUG_MODE" = true ]; then
        echo -e "${CYAN}[DEBUG] $1${NC}"
    fi
    echo "[DEBUG] $1" >> "$LOG_FILE"
}

confirm_action() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        echo -e "${YELLOW}$message (Y/n): ${NC}"
    else
        echo -e "${YELLOW}$message (y/N): ${NC}"
    fi
    
    read -r response
    
    if [[ "$default" == "y" ]]; then
        [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
    else
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 重新加载 shell 配置
reload_shell_config() {
    debug_log "Reloading shell configuration..."
    
    # 获取当前 shell
    local current_shell=$(basename "$SHELL")
    debug_log "Current shell: $current_shell"
    
    # 根据 shell 类型加载相应配置
    case "$current_shell" in
        bash)
            [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
            [ -f "$HOME/.bash_profile" ] && source "$HOME/.bash_profile"
            ;;
        zsh)
            [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
            [ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile"
            ;;
        *)
            debug_log "Unknown shell: $current_shell"
            ;;
    esac
    
    # 手动加载 Rust 和 Bun 环境
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
        debug_log "Loaded Rust environment"
    fi
    
    if [ -d "$HOME/.bun" ]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        debug_log "Loaded Bun environment"
    fi
}

# 检查网络连接
check_network() {
    print_info "检查网络连接..."
    if ping -c 1 github.com &> /dev/null; then
        print_success "网络连接正常"
        return 0
    else
        print_warning "无法连接到 GitHub"
        if ping -c 1 baidu.com &> /dev/null; then
            print_info "检测到可能在中国大陆，建议使用镜像源"
            USE_MIRROR=true
        fi
        return 1
    fi
}

# 配置镜像源
setup_mirrors() {
    if [ "$USE_MIRROR" = true ]; then
        print_info "配置中国镜像源..."
        
        # Cargo 镜像
        mkdir -p "$HOME/.cargo"
        cat > "$HOME/.cargo/config.toml" << EOF
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF
        print_success "Cargo 镜像配置完成"
        
        # NPM 镜像
        export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
        
        # Rustup 镜像
        export RUSTUP_DIST_SERVER=https://rsproxy.cn
        export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup
    fi
}

# 主菜单
show_main_menu() {
    clear
    print_header "🎯 Claudia 终极管理器 v$SCRIPT_VERSION"
    echo ""
    echo "📱 主菜单："
    echo ""
    echo "  1) 🆕 全新安装 Claudia"
    echo "  2) 🔄 检查并更新 Claudia"
    echo "  3) 🔧 修复现有安装"
    echo "  4) 🧹 清理并重新安装"
    echo "  5) 🗑️  完全卸载 Claudia"
    echo ""
    echo "🛠️  工具选项："
    echo ""
    echo "  6) 🥖 修复/重装 Bun"
    echo "  7) 📊 系统状态检查"
    echo "  8) 🔍 调试模式"
    echo "  9) 🌐 中国镜像模式"
    echo ""
    echo "  0) ❌ 退出"
    echo ""
    echo -n "请选择操作 (0-9): "
}

# 检查系统状态
check_system_status() {
    print_header "📊 系统状态检查"
    
    echo "🖥️  系统信息:"
    echo "   操作系统: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "   架构: $ARCH"
    echo "   Shell: $SHELL"
    echo ""
    
    echo "🛠️  开发工具:"
    # Xcode
    if command_exists xcode-select && xcode-select -p &> /dev/null; then
        print_success "Xcode Tools: $(xcode-select -p)"
    else
        print_error "Xcode Tools: 未安装"
    fi
    
    # Homebrew
    if command_exists brew; then
        print_success "Homebrew: $(brew --version | head -1)"
    else
        print_warning "Homebrew: 未安装"
    fi
    
    # Git
    if command_exists git; then
        print_success "Git: $(git --version)"
    else
        print_error "Git: 未安装"
    fi
    
    # Rust
    if command_exists rustc; then
        print_success "Rust: $(rustc --version)"
        if command_exists rustup; then
            echo "   Toolchains: $(rustup toolchain list | grep default | cut -d' ' -f1)"
        fi
    else
        print_error "Rust: 未安装"
    fi
    
    # Bun
    if command_exists bun; then
        print_success "Bun: $(bun --version)"
    else
        print_error "Bun: 未安装"
    fi
    
    # Node
    if command_exists node; then
        print_info "Node: $(node --version) (可选)"
    fi
    
    # Claude Code
    if command_exists claude; then
        print_success "Claude Code: $(claude --version 2>/dev/null || echo "已安装")"
    else
        print_error "Claude Code: 未安装"
    fi
    
    echo ""
    echo "📦 Claudia 项目:"
    if [ -d "claudia" ]; then
        cd claudia
        print_success "项目目录: $(pwd)"
        
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local current_branch=$(git branch --show-current 2>/dev/null || echo "未知")
            local current_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "未知")
            echo "   分支: $current_branch"
            echo "   提交: $current_commit"
        fi
        
        if [ -f "src-tauri/target/release/bundle/macos/Claudia.app/Contents/MacOS/Claudia" ]; then
            print_success "已构建应用: 存在"
        else
            print_warning "已构建应用: 不存在"
        fi
        
        if [ -d "/Applications/Claudia.app" ]; then
            print_success "已安装到 Applications: 是"
        else
            print_info "已安装到 Applications: 否"
        fi
        
        cd ..
    else
        print_warning "Claudia 项目目录不存在"
    fi
    
    echo ""
    echo "按回车键继续..."
    read -r
}

# 安装依赖工具
install_dependencies() {
    print_header "📦 安装系统依赖"
    
    # 检查 Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        print_error "需要先安装 Xcode Command Line Tools"
        xcode-select --install
        echo "请完成 Xcode Tools 安装后重新运行脚本"
        exit 1
    fi
    
    # 检查 Claude Code
    if ! command_exists claude; then
        print_error "未找到 Claude Code CLI"
        echo "请先从 https://claude.ai/code 安装 Claude Code"
        if ! confirm_action "是否已经安装 Claude Code？"; then
            exit 1
        fi
    fi
    
    # 安装 Homebrew（可选）
    if ! command_exists brew; then
        if confirm_action "是否安装 Homebrew？(推荐)" "y"; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # 添加到 PATH
            if [[ "$ARCH" == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
    fi
    
    # 使用 Homebrew 安装额外依赖
    if command_exists brew; then
        print_info "检查系统依赖..."
        
        # pkg-config
        if ! command_exists pkg-config; then
            brew install pkg-config
        fi
        
        # 其他可能需要的依赖
        local deps=("openssl" "libgit2")
        for dep in "${deps[@]}"; do
            if ! brew list "$dep" &>/dev/null; then
                print_info "安装 $dep..."
                brew install "$dep"
            fi
        done
    fi
}

# 安装 Rust
install_rust() {
    print_header "🦀 安装 Rust"
    
    if ! command_exists rustup; then
        print_info "安装 Rust..."
        if [ "$USE_MIRROR" = true ]; then
            export RUSTUP_DIST_SERVER=https://rsproxy.cn
            export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup
        fi
        
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env"
    fi
    
    # 确保有默认工具链
    if ! rustc --version &>/dev/null; then
        rustup default stable
    fi
    
    # 添加必要的 targets
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local targets=("aarch64-apple-darwin" "x86_64-apple-darwin")
        for target in "${targets[@]}"; do
            if ! rustup target list --installed | grep -q "$target"; then
                rustup target add "$target"
            fi
        done
    fi
    
    print_success "Rust 安装完成: $(rustc --version)"
}

# 修复 Bun
fix_bun() {
    print_header "🥖 修复 Bun"
    
    # 清理损坏的 Bun
    print_info "清理旧的 Bun 安装..."
    rm -rf "$HOME/.bun"
    rm -rf "$HOME/.cache/bun"
    rm -rf "$HOME/Library/Caches/bun"
    
    # 清理 shell 配置
    for file in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile; do
        if [ -f "$file" ]; then
            sed -i '' '/# Bun/d; /BUN_INSTALL/d; /\.bun\/bin/d' "$file" 2>/dev/null || true
        fi
    done
    
    # 重新安装
    print_info "重新安装 Bun..."
    if [ "$USE_MIRROR" = true ]; then
        curl -fsSL https://npmirror.com/mirrors/bun/install | bash
    else
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # 更新环境变量
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    # 更新 shell 配置
    local shell_config=""
    case "$(basename "$SHELL")" in
        bash) shell_config="$HOME/.bashrc" ;;
        zsh) shell_config="$HOME/.zshrc" ;;
        *) shell_config="$HOME/.profile" ;;
    esac
    
    if [ -n "$shell_config" ]; then
        echo "" >> "$shell_config"
        echo "# Bun" >> "$shell_config"
        echo 'export BUN_INSTALL="$HOME/.bun"' >> "$shell_config"
        echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$shell_config"
    fi
    
    # 验证安装
    if [ -f "$HOME/.bun/bin/bun" ] && "$HOME/.bun/bin/bun" --version &>/dev/null; then
        print_success "Bun 修复完成: $("$HOME/.bun/bin/bun" --version)"
    else
        print_error "Bun 修复失败"
        return 1
    fi
}

# 安装 Bun
install_bun() {
    print_header "🥖 安装 Bun"
    
    if ! command_exists bun; then
        fix_bun
    else
        print_success "Bun 已安装: $(bun --version)"
    fi
}

# 全新安装 Claudia
fresh_install() {
    print_header "🆕 全新安装 Claudia"
    
    # 检查系统
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "此脚本仅支持 macOS"
        exit 1
    fi
    
    # 检查网络
    check_network
    
    # 设置镜像
    setup_mirrors
    
    # 安装依赖
    install_dependencies
    
    # 重新加载环境
    reload_shell_config
    
    # 安装 Rust
    install_rust
    
    # 安装 Bun
    install_bun
    
    # 克隆项目
    if [ -d "claudia" ]; then
        print_warning "claudia 目录已存在"
        if confirm_action "是否删除并重新克隆？"; then
            rm -rf claudia
        else
            cd claudia
        fi
    fi
    
    if [ ! -d "claudia" ]; then
        print_info "克隆 Claudia 项目..."
        git clone https://github.com/getAsterisk/claudia.git
        cd claudia
    fi
    
    # 安装项目依赖
    print_info "安装项目依赖..."
    bun install
    
    # 检查 Tauri CLI
    if [ ! -f "node_modules/.bin/tauri" ]; then
        bun add -D @tauri-apps/cli
    fi
    
    # 构建应用
    build_claudia
    
    cd ..
}

# 构建 Claudia
build_claudia() {
    print_header "🔨 构建 Claudia"
    
    # 清理旧构建
    if [ -d "src-tauri/target" ] && confirm_action "是否清理旧的构建文件？" "y"; then
        rm -rf src-tauri/target
    fi
    
    print_info "开始构建（这可能需要几分钟）..."
    export RUST_BACKTRACE=1
    
    if bun run tauri build; then
        print_success "构建成功！"
        
        # 查找构建结果
        local app_path=$(find src-tauri/target/release/bundle/macos -name "*.app" -type d 2>/dev/null | head -1)
        local dmg_path=$(find src-tauri/target/release/bundle/dmg -name "*.dmg" -type f 2>/dev/null | head -1)
        
        if [ -n "$app_path" ]; then
            echo ""
            echo "📍 构建结果："
            echo "   App: $app_path"
            [ -n "$dmg_path" ] && echo "   DMG: $dmg_path"
            
            if confirm_action "是否立即启动 Claudia？" "y"; then
                open "$app_path"
            fi
            
            if confirm_action "是否安装到应用程序文件夹？" "y"; then
                cp -r "$app_path" /Applications/
                print_success "已安装到 /Applications"
            fi
        fi
    else
        print_error "构建失败"
        echo "请查看错误信息或尝试: bun run tauri dev"
        return 1
    fi
}

# 更新 Claudia
update_claudia() {
    print_header "🔄 更新 Claudia"
    
    if [ ! -d "claudia" ]; then
        print_error "找不到 claudia 目录"
        return 1
    fi
    
    cd claudia
    
    print_info "检查更新..."
    git fetch origin main
    
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)
    
    if [ "$local_commit" = "$remote_commit" ]; then
        print_success "已是最新版本！"
    else
        print_info "发现新版本"
        echo "当前: $(git rev-parse --short HEAD)"
        echo "最新: $(git rev-parse --short origin/main)"
        
        if confirm_action "是否更新？" "y"; then
            git pull origin main
            bun install
            build_claudia
        fi
    fi
    
    cd ..
}

# 完全卸载
complete_uninstall() {
    print_header "🗑️  完全卸载 Claudia"
    
    print_warning "将要删除以下内容："
    echo "• Claudia 项目目录"
    echo "• /Applications/Claudia.app"
    echo "• 构建缓存"
    echo ""
    
    if confirm_action "可选：是否同时卸载开发工具？"; then
        echo "  • Rust 工具链"
        echo "  • Bun 包管理器"
        echo "  • Homebrew 依赖"
    fi
    
    echo ""
    if ! confirm_action "确定要继续卸载吗？"; then
        return
    fi
    
    # 删除 Claudia
    print_info "删除 Claudia..."
    rm -rf claudia
    rm -rf /Applications/Claudia.app
    rm -rf "$HOME/.cache/tauri"
    rm -rf "$HOME/Library/Caches/com.claudia.app"
    
    # 可选：删除开发工具
    if confirm_action "是否卸载 Rust？"; then
        if command_exists rustup; then
            rustup self uninstall -y
        fi
        rm -rf "$HOME/.cargo"
        rm -rf "$HOME/.rustup"
        print_success "Rust 已卸载"
    fi
    
    if confirm_action "是否卸载 Bun？"; then
        rm -rf "$HOME/.bun"
        rm -rf "$HOME/.cache/bun"
        
        # 清理 shell 配置
        for file in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile; do
            if [ -f "$file" ]; then
                sed -i '' '/# Bun/d; /BUN_INSTALL/d; /\.bun\/bin/d' "$file" 2>/dev/null || true
            fi
        done
        print_success "Bun 已卸载"
    fi
    
    print_success "卸载完成！"
    print_warning "请重启终端以更新环境变量"
}

# 修复安装
repair_installation() {
    print_header "🔧 修复现有安装"
    
    # 重新加载环境
    reload_shell_config
    
    # 检查并修复工具
    if ! command_exists rustc; then
        install_rust
    fi
    
    if ! command_exists bun || ! bun --version &>/dev/null; then
        fix_bun
    fi
    
    # 修复项目
    if [ -d "claudia" ]; then
        cd claudia
        
        print_info "清理并重新安装依赖..."
        rm -rf node_modules bun.lockb package-lock.json yarn.lock
        bun install
        
        if [ ! -f "node_modules/.bin/tauri" ]; then
            bun add -D @tauri-apps/cli
        fi
        
        if confirm_action "是否重新构建？" "y"; then
            build_claudia
        fi
        
        cd ..
    else
        print_error "找不到 claudia 目录"
        if confirm_action "是否执行全新安装？" "y"; then
            fresh_install
        fi
    fi
}

# 主程序
main() {
    # 初始化
    init_log
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                DEBUG_MODE=true
                shift
                ;;
            --mirror)
                USE_MIRROR=true
                shift
                ;;
            --version)
                echo "Claudia Manager v$SCRIPT_VERSION"
                exit 0
                ;;
            --help)
                echo "Claudia 终极管理器 v$SCRIPT_VERSION"
                echo ""
                echo "用法: $0 [选项]"
                echo ""
                echo "选项:"
                echo "  --debug    启用调试模式"
                echo "  --mirror   使用中国镜像"
                echo "  --version  显示版本"
                echo "  --help     显示帮助"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # 主循环
    while true; do
        show_main_menu
        read -r choice
        
        case $choice in
            1)
                fresh_install
                ;;
            2)
                update_claudia
                ;;
            3)
                repair_installation
                ;;
            4)
                if [ -d "claudia" ]; then
                    rm -rf claudia
                fi
                fresh_install
                ;;
            5)
                complete_uninstall
                ;;
            6)
                fix_bun
                print_info "请运行 'source ~/.zshrc' 或重启终端"
                ;;
            7)
                check_system_status
                ;;
            8)
                DEBUG_MODE=true
                print_info "调试模式已开启"
                ;;
            9)
                USE_MIRROR=true
                setup_mirrors
                print_info "镜像模式已开启"
                ;;
            0)
                echo "👋 再见！"
                exit 0
                ;;
            *)
                print_error "无效选项"
                sleep 1
                ;;
        esac
        
        echo ""
        echo "按回车键返回主菜单..."
        read -r
    done
}

# 运行主程序
main "$@"
