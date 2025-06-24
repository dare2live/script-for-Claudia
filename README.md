# script-for-Claudia
让claude code帮我写的安装claude code GUI程序Claudia的脚本，方便像我一样的小白也能体验带UI的claude code。
🚀 功能特点
📱 主要功能

全新安装 - 从零开始安装 Claudia
检查更新 - 检查并更新到最新版本
修复安装 - 修复损坏的安装
清理重装 - 删除旧版本并重新安装
完全卸载 - 彻底删除 Claudia 和所有依赖

🛠️ 工具功能

修复 Bun - 专门修复损坏的 Bun
系统检查 - 查看所有工具和依赖状态
调试模式 - 详细的调试信息
镜像模式 - 中国大陆用户专用

💡 智能特性

✅ 自动检测并修复环境变量
✅ 智能处理 Apple Silicon 和 Intel 架构
✅ 完整的日志记录
✅ 友好的交互界面
✅ 错误恢复机制

📦 使用方法
bash# 1. 保存脚本
# 将脚本保存为 claudia-manager.sh

# 2. 添加执行权限
chmod +x claudia-manager.sh

# 3. 运行脚本
./claudia-manager.sh

# 可选参数
./claudia-manager.sh --debug    # 调试模式
./claudia-manager.sh --mirror   # 使用中国镜像
./claudia-manager.sh --help     # 查看帮助
🎯 卸载功能详解
脚本的卸载功能会：

删除 Claudia 项目目录
删除 /Applications/Claudia.app
清理所有缓存
可选删除 Rust（会询问）
可选删除 Bun（会询问）
清理 shell 配置文件
保留备份（如果需要）

📝 特别说明

脚本会自动创建日志文件 claudia-manager.log
所有删除操作都会先询问确认
修改 shell 配置前会自动备份
Claude Code CLI 不会被删除（可能其他项目需要）

这个脚本应该能满足您的所有需求，从安装到卸载的完整生命周期管理！有任何问题随时告诉我。
