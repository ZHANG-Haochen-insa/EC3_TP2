# TP VHDL Digicode - 项目结构说明

## 📁 项目总览

本项目是一个数字密码锁（Digicode）的VHDL实现，分为两个问题，每个问题有独立的文件夹。

```
TP_E2/
├── Q1_Validation_Basique/      # 第一问：基础密码验证
├── Q2_Modification_Code/       # 第二问：增加密码修改功能
├── README_项目结构.md          # 本文件
├── 对话.md                      # 开发过程记录和问题解答
└── TP说明.md                    # 原始实验说明
```

---

## 📂 文件夹详细说明

### 🟢 Q1_Validation_Basique/ - 第一问

**功能**: 基础密码验证功能

**包含文件**:
```
Q1_Validation_Basique/
├── moore_q1.vhd              # Moore状态机（9个状态）
├── memoire.vhd               # 内存模块
├── division_horloge.vhd      # 时钟分频器
├── digicode_top_q1.vhd       # 顶层模块（Q1专用）
├── moore_q1_tb.vhd           # Testbench
├── testbench解析.md          # Testbench中文详解
├── README_Q1.md              # Q1使用说明
└── TP VHDL Digicode 2025.pdf # 实验指导书
```

**核心特点**:
- ✅ 9状态Moore机
- ✅ 密码验证功能
- ✅ 按钮去抖动
- ✅ LED指示当前地址
- ❌ 无密码修改功能

**适合**: 初学者，第一问要求

---

### 🔵 Q2_Modification_Code/ - 第二问

**功能**: 完整功能（验证 + 修改密码）

**包含文件**:
```
Q2_Modification_Code/
├── machine_moore.vhd         # 完整Moore状态机（20个状态）
├── memoire.vhd               # 内存模块（支持写入）
├── division_horloge.vhd      # 时钟分频器
├── digicode_top.vhd          # 顶层模块（完整版）
├── machine_etats_tb.vhd      # Testbench（测试修改功能）
├── README_Q2.md              # Q2使用说明
└── TP VHDL Digicode 2025.pdf # 实验指导书
```

**核心特点**:
- ✅ 20状态Moore机
- ✅ 密码验证功能
- ✅ 密码修改功能 ⭐新增
- ✅ 修改模式LED指示 ⭐新增
- ✅ 内存写入功能
- ✅ SW1开关控制修改模式

**适合**: 完成第一问后的进阶要求

---

## 🔄 两个问题的关系

```
Q1 (基础版)              Q2 (完整版)
    │                        │
    │                        │
moore_q1.vhd ────扩展───> machine_moore.vhd
(9个状态)                 (20个状态)
    │                        │
    ├─ 验证功能              ├─ 验证功能
    └─ 9个状态               ├─ 修改功能 ⭐
                             └─ 20个状态
```

**建议学习路径**:
1. 先完成Q1，理解基本的Moore状态机
2. 理解Q1的testbench和仿真
3. 在FPGA板上验证Q1
4. 再学习Q2，理解如何添加修改功能
5. 对比两个版本的差异

---

## 📊 功能对比表

| 功能项 | Q1 | Q2 |
|-------|----|----|
| **密码验证** | ✅ | ✅ |
| **错误处理** | ✅ | ✅ |
| **按钮去抖动** | ✅ | ✅ |
| **地址LED显示** | ✅ | ✅ |
| **门锁LED** | ✅ | ✅ |
| **密码修改** | ❌ | ✅ |
| **修改模式LED** | ❌ | ✅ |
| **SW1开关** | 不使用 | 修改模式 |
| **内存写入** | 不使用 | ✅ |
| **状态数量** | 9 | 20 |
| **代码复杂度** | 简单 | 复杂 |

---

## 🚀 快速开始

### 对于第一次使用者：

1. **阅读实验说明**
   ```bash
   查看 TP说明.md
   查看 对话.md（包含常见问题解答）
   ```

2. **从Q1开始**
   ```bash
   cd Q1_Validation_Basique/
   阅读 README_Q1.md
   ```

3. **运行仿真**
   ```bash
   # 使用GHDL
   ghdl -a memoire.vhd
   ghdl -a moore_q1.vhd
   ghdl -a moore_q1_tb.vhd
   ghdl -e moore_q1_tb
   ghdl -r moore_q1_tb --wave=sim.ghw
   gtkwave sim.ghw
   ```

4. **理解波形**
   ```bash
   阅读 testbench解析.md
   观察状态转换
   验证功能正确性
   ```

5. **综合到FPGA**
   - 在Vivado中打开Q1项目
   - 添加约束文件
   - 综合、实现、生成比特流
   - 烧录到板子

6. **进入Q2**
   ```bash
   cd ../Q2_Modification_Code/
   阅读 README_Q2.md
   重复以上步骤
   ```

---

## 📝 重要文档说明

### 根目录文档

1. **对话.md** ⭐重要
   - 包含所有开发过程的问题和解答
   - 详细的修改记录
   - 语法错误修复说明
   - Reset信号处理说明
   - Moore机设计要点

2. **TP说明.md**
   - 实验的中文说明
   - 任务要求概述

3. **README_项目结构.md** (本文件)
   - 项目整体结构说明
   - 快速导航指南

### Q1专属文档

1. **testbench解析.md**
   - 非常详细的testbench说明
   - 包含时序图
   - 调试技巧
   - 扩展建议

2. **README_Q1.md**
   - Q1的完整使用说明
   - 端口定义
   - 操作流程

### Q2专属文档

1. **README_Q2.md**
   - Q2的完整使用说明
   - 密码修改功能详解
   - 与Q1的对比

---

## 🔧 开发工具

### 推荐工具链

1. **仿真工具**
   - GHDL + GTKWave (免费，Linux/Windows)
   - Vivado Simulator (集成在Vivado中)
   - ModelSim (商业软件)

2. **综合工具**
   - Vivado Design Suite (Xilinx官方，免费版本可用)

3. **文本编辑器**
   - VS Code + VHDL插件
   - Sublime Text
   - Vim/Emacs

### 目标FPGA板

- Nexys A7 (推荐)
- 其他Xilinx 7系列FPGA板

---

## ⚠️ 常见问题

### Q: 我应该从哪个文件夹开始？
**A**: 从 `Q1_Validation_Basique/` 开始，先掌握基础功能。

### Q: Q1和Q2可以同时在Vivado中打开吗？
**A**: 建议分别创建两个Vivado项目，避免混淆。

### Q: Testbench怎么运行？
**A**: 查看各个文件夹中的README文件，有详细的GHDL命令。

### Q: Reset信号为什么不反转？
**A**: 已根据用户需求修改为直接使用，详见`对话.md`中的修改记录。

### Q: 我发现了bug怎么办？
**A**:
1. 先查看`对话.md`中的修改记录，看是否已经修复
2. 检查你使用的是哪个版本的文件
3. 查看对应文件夹的README进行调试

---

## 📚 学习路线图

```
第1周：理解Moore状态机概念
  ↓
第2周：完成Q1仿真和理解
  ↓
第3周：Q1板级验证
  ↓
第4周：学习Q2增加的功能
  ↓
第5周：Q2仿真测试
  ↓
第6周：Q2板级验证和完善
```

---

## 🎯 学习目标

完成本项目后，你将掌握：

1. ✅ Moore状态机的设计方法
2. ✅ VHDL的基本语法和结构
3. ✅ 多模块系统的设计和连接
4. ✅ Testbench的编写方法
5. ✅ 仿真和调试技巧
6. ✅ FPGA综合和实现流程
7. ✅ 内存读写操作
8. ✅ 按钮去抖动技术
9. ✅ 时钟分频技术
10. ✅ 实际硬件验证方法

---

## 📞 获取帮助

1. **查看文档**: 各个文件夹的README和解析文档
2. **查看历史**: `对话.md`包含所有问题和解答
3. **仿真调试**: 使用GTKWave查看波形
4. **对比代码**: 对比Q1和Q2的差异来理解功能增加

---

## ✅ 项目检查清单

### Q1完成标准
- [ ] 仿真测试6个场景全部通过
- [ ] 理解9个状态的转换逻辑
- [ ] 能在FPGA板上用按钮开门
- [ ] LED指示正确

### Q2完成标准
- [ ] 仿真测试7个场景全部通过
- [ ] 理解20个状态的转换逻辑
- [ ] 能在FPGA板上验证密码
- [ ] 能在FPGA板上修改密码
- [ ] LED3正确指示修改模式
- [ ] 新密码能正确保存和使用

---

## 📄 版本信息

- **创建日期**: 2025-11-27
- **版本**: v1.0
- **作者**: Claude Code
- **测试环境**: GHDL + GTKWave

---

## 🎉 祝学习愉快！

如有任何问题，请先查阅各个README文档和`对话.md`文件。

**记住**: 先完成Q1，再做Q2！循序渐进才能学得扎实。
