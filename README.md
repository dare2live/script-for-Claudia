# 🎯 Claudia Manager for macOS

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-orange.svg)

一个功能强大的 macOS 脚本，用于管理 [Claudia](https://github.com/getAsterisk/claudia) 的完整生命周期 - 从安装到卸载的一站式解决方案。

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [系统要求](#-系统要求) • [使用指南](#-使用指南) • [故障排除](#-故障排除)

</div>

## 🌟 功能特性

### 核心功能
- 🆕 **一键安装** - 自动安装所有依赖并构建 Claudia
- 🔄 **智能更新** - 检查并更新到最新版本
- 🔧 **自动修复** - 诊断并修复常见问题
- 🗑️ **完全卸载** - 彻底清理所有组件和依赖
- 📊 **状态检查** - 实时查看系统和项目状态

### 高级特性
- 🥖 **Bun 修复工具** - 专门处理 Bun 安装问题
- 🌐 **中国镜像支持** - 自动配置国内加速源
- 🔍 **调试模式** - 详细的日志和错误追踪
- 🏗️ **架构自适应** - 支持 Apple Silicon 和 Intel
- 📝 **自动备份** - 修改配置前自动创建备份

## 📋 系统要求

- **操作系统**: macOS 10.15 (Catalina) 或更高版本
- **架构**: Apple Silicon (M1/M2/M3) 或 Intel
- **必需工具**:
  - Xcode Command Line Tools
  - [Claude Code CLI](https://claude.ai/code)
- **推荐工具**:
  - Homebrew（脚本可自动安装）

## 🚀 快速开始

### 1. 下载脚本

```bash
# 方式一：使用 curl
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/claudia-manager/main/claudia-manager.sh

# 方式二：使用 wget
wget https://raw.githubusercontent.com/YOUR_USERNAME/claudia-manager/main/claudia-manager.sh

# 方式三：直接克隆仓库
git clone https://github.com/YOUR_USERNAME/claudia-manager.git
cd claudia-manager
```

### 2. 添加执行权限

```bash
chmod +x claudia-manager.sh
```

### 3. 运行脚本

```bash
# 普通模式
./claudia-manager.sh

# 调试模式（显示详细信息）
./claudia-manager.sh --debug

# 使用中国镜像（推荐国内用户）
./claudia-manager.sh --mirror

# 查看帮助
./claudia-manager.sh --help
```

## 📖 使用指南

### 主菜单选项

运行脚本后，您将看到以下菜单：

```
🎯 Claudia 终极管理器 v2.0.0

📱 主菜单：

  1) 🆕 全新安装 Claudia
  2) 🔄 检查并更新 Claudia
  3) 🔧 修复现有安装
  4) 🧹 清理并重新安装
  5) 🗑️  完全卸载 Claudia

🛠️  工具选项：

  6) 🥖 修复/重装 Bun
  7) 📊 系统状态检查
  8) 🔍 调试模式
  9) 🌐 中国镜像模式

  0) ❌ 退出
```

### 功能详解

#### 1️⃣ 全新安装
完整的安装流程，包括：
- 检查系统兼容性
- 安装所有依赖（Rust、Bun、系统库）
- 克隆 Claudia 项目
- 构建应用程序
- 可选安装到 Applications 文件夹

#### 2️⃣ 检查更新
- 自动检查 GitHub 上的最新版本
- 显示更新日志
- 一键更新到最新版本

#### 3️⃣ 修复安装
智能诊断并修复：
- 环境变量问题
- 依赖缺失
- 构建错误
- 权限问题

#### 4️⃣ 清理重装
- 完全删除现有安装
- 清理所有缓存
- 执行全新安装

#### 5️⃣ 完全卸载
提供分级卸载选项：
- 基础卸载：仅删除 Claudia
- 完全卸载：包括 Rust、Bun 等开发工具
- 自动清理 shell 配置文件
- 保留备份文件

## 🛠️ 高级功能

### Bun 修复工具
专门解决 Bun 相关问题：
```bash
# 如果遇到 Bun 错误，选择选项 6
# 脚本会自动：
# - 清理损坏的 Bun 安装
# - 重新安装最新版本
# - 修复环境变量
# - 验证安装
```

### 中国镜像配置
自动配置以下镜像源：
- **Cargo**: rsproxy.cn
- **NPM**: npmmirror.com
- **Rustup**: rsproxy.cn

### 调试模式
提供详细的执行信息：
- 所有命令的输出
- 环境变量状态
- 错误堆栈追踪
- 完整的日志文件

## 🔧 故障排除

### 常见问题

<details>
<summary><b>错误：Bun 安装后仍然无法使用</b></summary>

```bash
# 解决方案 1：重新加载 shell 配置
source ~/.zshrc  # 或 ~/.bashrc

# 解决方案 2：使用修复功能
./claudia-manager.sh
# 选择选项 6 修复 Bun
```
</details>

<details>
<summary><b>错误：构建失败 - 找不到 tauri 命令</b></summary>

```bash
# 脚本会自动处理，但如果仍有问题：
cd claudia
bun add -D @tauri-apps/cli
bun tauri build
```
</details>

<details>
<summary><b>错误：网络连接问题（中国大陆）</b></summary>

```bash
# 使用镜像模式运行
./claudia-manager.sh --mirror

# 或在菜单中选择选项 9
```
</details>

### 日志文件

脚本会自动创建日志文件 `claudia-manager.log`，包含：
- 所有执行的命令
- 错误信息
- 系统状态
- 时间戳

查看日志：
```bash
cat claudia-manager.log
```

## 📊 兼容性

| macOS 版本 | 支持状态 | 备注 |
|-----------|---------|------|
| 15.0+ (Sequoia) | ✅ 完全支持 | 推荐 |
| 14.0 (Sonoma) | ✅ 完全支持 | |
| 13.0 (Ventura) | ✅ 完全支持 | |
| 12.0 (Monterey) | ⚠️ 部分支持 | 可能需要手动处理某些依赖 |
| 11.0 (Big Sur) | ⚠️ 部分支持 | 需要更新 Xcode |
| 10.15 (Catalina) | ❓ 未测试 | 理论上支持 |

## 🤝 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 开发建议

- 保持脚本的 POSIX 兼容性
- 添加充分的错误处理
- 更新相关文档
- 测试所有主要功能

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Claudia](https://github.com/getAsterisk/claudia) - 原项目
- [Tauri](https://tauri.app/) - 应用框架
- [Rust](https://www.rust-lang.org/) - 编程语言
- [Bun](https://bun.sh/) - JavaScript 运行时

## 📮 联系方式

- 提交 [Issue](https://github.com/YOUR_USERNAME/claudia-manager/issues) 报告问题
- 查看 [Discussions](https://github.com/YOUR_USERNAME/claudia-manager/discussions) 参与讨论

---

<div align="center">

**如果这个工具对您有帮助，请给个 ⭐ Star！**

Made with ❤️ for the macOS community

</div>
