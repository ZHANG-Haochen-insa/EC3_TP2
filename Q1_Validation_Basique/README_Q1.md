# Question 1 - Validation Basique du Code

## 📁 描述

本文件夹包含**第一问**所需的所有文件：实现基本的密码验证功能，无密码修改功能。

## 📋 文件列表

### 核心设计文件

1. **moore_q1.vhd** - 简化的Moore状态机（9个状态）
   - 功能：验证4位密码
   - 状态数：9个
   - 不包含密码修改功能

2. **memoire.vhd** - 内存模块
   - 存储4位密码
   - 默认密码：0001, 0010, 0100, 1000（BTND, BTNR, BTNU, BTNL）
   - 支持读写（Q1中只使用读功能）

3. **division_horloge.vhd** - 时钟分频器
   - 将100MHz系统时钟分频到约3Hz
   - 便于观察LED变化和按钮检测

4. **digicode_top_q1.vhd** - 顶层模块（专为Q1设计）
   - 连接所有子模块
   - 实例化moore_q1、memoire、division_horloge
   - 映射到FPGA引脚

### 仿真测试文件

5. **moore_q1_tb.vhd** - Testbench
   - 包含6个测试场景
   - 自动验证功能正确性

### 文档文件

6. **testbench解析.md** - Testbench详细解析
   - 中文说明
   - 包含时序图、使用方法、调试技巧

7. **README_Q1.md** - 本文件

## 🎯 功能说明

### 第一问要求实现：

✅ 4位密码顺序输入验证
✅ 正确后LED点亮（模拟开门）
✅ 错误后返回初始状态
✅ 按钮去抖动（等待释放）
✅ 门开关模拟（switch控制）

### 不包含的功能：

❌ 密码修改功能
❌ 修改模式LED指示

## 🔌 端口说明

### 输入端口

| 端口名称 | 类型 | 说明 |
|---------|------|------|
| CLK100MHZ | STD_LOGIC | 系统时钟（100MHz） |
| CPU_RESETN | STD_LOGIC | 复位按钮（高电平有效） |
| BTND | STD_LOGIC | 下按钮（密码位1：0001） |
| BTNR | STD_LOGIC | 右按钮（密码位2：0010） |
| BTNU | STD_LOGIC | 上按钮（密码位3：0100） |
| BTNL | STD_LOGIC | 左按钮（密码位4：1000） |
| SW0 | STD_LOGIC | 开关0（模拟门的物理状态） |

### 输出端口

| 端口名称 | 类型 | 说明 |
|---------|------|------|
| LED0 | STD_LOGIC | 地址位0（显示当前验证第几位） |
| LED1 | STD_LOGIC | 地址位1 |
| LED2 | STD_LOGIC | 门锁状态（1=开，0=关） |

## 🚀 使用方法

### 1. Vivado综合实现

```bash
# 在Vivado中创建项目
# 添加以下源文件（按顺序）：
1. memoire.vhd
2. division_horloge.vhd
3. moore_q1.vhd
4. digicode_top_q1.vhd  (设为Top Module)

# 添加约束文件（.xdc）
# 运行综合（Synthesis）
# 运行实现（Implementation）
# 生成比特流（Generate Bitstream）
# 烧录到FPGA板
```

### 2. GHDL仿真

```bash
# 编译所有文件
ghdl -a memoire.vhd
ghdl -a moore_q1.vhd
ghdl -a moore_q1_tb.vhd

# 生成可执行文件
ghdl -e moore_q1_tb

# 运行仿真
ghdl -r moore_q1_tb --wave=moore_q1_sim.ghw

# 查看波形
gtkwave moore_q1_sim.ghw
```

## 📊 Moore状态机（9个状态）

```
ST_IDLE_1      → 等待第1位密码输入
ST_WAIT_REL_1  → 等待第1个按钮释放
ST_IDLE_2      → 等待第2位密码输入
ST_WAIT_REL_2  → 等待第2个按钮释放
ST_IDLE_3      → 等待第3位密码输入
ST_WAIT_REL_3  → 等待第3个按钮释放
ST_IDLE_4      → 等待第4位密码输入
ST_SUCCESS     → 密码正确，门打开
ST_FAIL        → 密码错误
```

## 🧪 测试场景

### Test 1: 复位验证
- 验证系统复位后回到初始状态

### Test 2: 正确密码输入
- 输入：0001 → 0010 → 0100 → 1000
- 期望：门打开（LED2亮）

### Test 3: 门开关操作
- 关门后系统返回初始状态

### Test 4: 错误密码输入
- 输入错误序列
- 期望：门保持关闭，系统复位

### Test 5: 失败后重试
- 验证错误后可以重新输入

### Test 6: 地址序列验证
- 验证内存地址正确递增：00→01→10→11

## 💡 使用提示

1. **默认密码顺序**：BTND（下） → BTNR（右） → BTNU（上） → BTNL（左）

2. **观察LED**：
   - LED0和LED1显示当前验证第几位（00/01/10/11）
   - LED2显示门的状态

3. **操作流程**：
   ```
   1. 按下复位按钮（CPU_RESETN）
   2. 按顺序按下4个按钮（每次按下后要释放）
   3. 如果正确，LED2会点亮
   4. 将SW0开关拨到1（模拟推开门）
   5. 将SW0开关拨回0（模拟关门）
   6. 系统返回初始状态，可以重新输入
   ```

## ⚠️ 注意事项

1. **时钟分频**：如果LED闪烁太快或太慢，修改division_horloge.vhd中的分频比
2. **Reset极性**：当前代码使用高电平有效复位（无反转）
3. **按钮去抖动**：确保每次按钮按下后完全释放再按下一个

## 📖 相关文档

- `testbench解析.md` - Testbench详细中文说明
- `TP VHDL Digicode 2025.pdf` - 原始实验指导书

## 🔗 进阶

完成第一问后，请查看 `../Q2_Modification_Code/` 文件夹完成第二问（密码修改功能）。
