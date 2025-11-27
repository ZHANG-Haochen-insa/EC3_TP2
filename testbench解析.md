# moore_q1_tb.vhd Testbench 详细解析

## 📋 文件概述

`moore_q1_tb.vhd` 是为第一部分数字密码锁（moore_q1）设计的完整测试平台（testbench）。它模拟了各种使用场景，自动验证密码锁的功能是否正确。

---

## 🏗️ 整体架构

### 实例化的组件

testbench中实例化了两个核心组件：

1. **UUT_MEM（Memory）** - 内存模块
   - 存储4位数字密码
   - 默认密码：0001, 0010, 0100, 1000

2. **UUT（Unit Under Test）** - 被测试的Moore状态机
   - 实现密码验证逻辑
   - 有9个状态的Moore机

两个模块通过信号连接，模拟真实硬件中的工作方式。

---

## 📊 信号声明详解

### 输入信号（Testbench产生）

```vhdl
signal clk             : STD_LOGIC := '0';           -- 时钟信号
signal reset           : STD_LOGIC := '0';           -- 复位信号
signal contenu_bouton  : STD_LOGIC_VECTOR (3 downto 0) := "0000";  -- 按钮输入
signal porte           : STD_LOGIC := '0';           -- 门的状态开关
```

- **clk**: 10ns周期的时钟，由CLK_PROCESS自动生成
- **reset**: 高电平复位，测试开始时先复位系统
- **contenu_bouton**: 4位向量，表示哪个按钮被按下
  - `"0000"` = 无按钮按下
  - `"0001"` = BTND（下按钮）
  - `"0010"` = BTNR（右按钮）
  - `"0100"` = BTNU（上按钮）
  - `"1000"` = BTNL（左按钮）
- **porte**: 模拟物理门的状态
  - `'0'` = 门关闭
  - `'1'` = 门打开

### 输出信号（UUT产生）

```vhdl
signal adresse_machine : STD_LOGIC_VECTOR (1 downto 0);  -- 当前读取的内存地址
signal ouverture_porte : STD_LOGIC;                      -- 门锁状态（LED）
signal contenu_mem     : STD_LOGIC_VECTOR (3 downto 0);  -- 从内存读取的数据
```

- **adresse_machine**: 指示当前验证第几位密码
  - `"00"` = 第1位密码
  - `"01"` = 第2位密码
  - `"10"` = 第3位密码
  - `"11"` = 第4位密码
- **ouverture_porte**: 门锁状态
  - `'0'` = 门锁关闭
  - `'1'` = 门锁打开（验证成功）
- **contenu_mem**: 从内存读取的期望密码值

### 常量定义

```vhdl
constant CLK_PERIOD : time := 10 ns;               -- 时钟周期
constant CODE_1 : STD_LOGIC_VECTOR := "0001";      -- 密码第1位（BTND）
constant CODE_2 : STD_LOGIC_VECTOR := "0010";      -- 密码第2位（BTNR）
constant CODE_3 : STD_LOGIC_VECTOR := "0100";      -- 密码第3位（BTNU）
constant CODE_4 : STD_LOGIC_VECTOR := "1000";      -- 密码第4位（BTNL）
```

---

## 🧪 测试场景详解

### Test 1: 复位验证 ✅

**目的**: 验证系统复位后的初始状态

**测试步骤**:
```vhdl
reset <= '1';              -- 激活复位
wait for CLK_PERIOD * 2;   -- 保持2个时钟周期
reset <= '0';              -- 释放复位
wait for CLK_PERIOD * 2;   -- 等待稳定
```

**验证点**:
- ✓ 门应该是关闭的（`ouverture_porte = '0'`）
- ✓ 地址应该在00（`adresse_machine = "00"`）

---

### Test 2: 正确密码输入 ✅

**目的**: 验证输入正确密码序列后门能正常打开

**测试步骤**:
```
1. 按下BTND（0001）→ 释放 → 等待
2. 按下BTNR（0010）→ 释放 → 等待
3. 按下BTNU（0100）→ 释放 → 等待
4. 按下BTNL（1000）→ 释放 → 等待
```

**每个按钮的操作**:
```vhdl
contenu_bouton <= CODE_1;    -- 按下按钮
wait for CLK_PERIOD * 3;     -- 保持3个时钟周期
contenu_bouton <= "0000";    -- 释放按钮
wait for CLK_PERIOD * 2;     -- 等待去抖动
```

**状态转换流程**:
```
ST_IDLE_1 → (按BTND,正确) → ST_WAIT_REL_1 → (释放) →
ST_IDLE_2 → (按BTNR,正确) → ST_WAIT_REL_2 → (释放) →
ST_IDLE_3 → (按BTNU,正确) → ST_WAIT_REL_3 → (释放) →
ST_IDLE_4 → (按BTNL,正确) → ST_SUCCESS
```

**验证点**:
- ✓ 门应该打开（`ouverture_porte = '1'`）

---

### Test 3: 门的开关操作 ✅

**目的**: 验证物理门开关后系统能正确返回初始状态

**测试步骤**:
```vhdl
porte <= '1';              -- 模拟门被推开
wait for CLK_PERIOD * 3;
porte <= '0';              -- 模拟门被关上
wait for CLK_PERIOD * 3;
```

**状态转换**:
```
ST_SUCCESS → (porte='0') → ST_IDLE_1
```

**验证点**:
- ✓ 门锁应该关闭（`ouverture_porte = '0'`）
- ✓ 地址返回到00（`adresse_machine = "00"`）
- ✓ 系统回到初始状态，可以重新输入密码

---

### Test 4: 错误密码输入 ❌

**目的**: 验证输入错误密码时门不会打开

**测试步骤**:
```
1. 按下BTND（0001）→ 正确 ✓
2. 按下BTNL（1000）→ 错误 ✗ （应该是BTNR/0010）
```

**状态转换**:
```
ST_IDLE_1 → (按BTND,正确) → ST_WAIT_REL_1 → (释放) →
ST_IDLE_2 → (按BTNL,错误) → ST_FAIL → (释放所有按钮) → ST_IDLE_1
```

**验证点**:
- ✓ 门保持关闭（`ouverture_porte = '0'`）
- ✓ 系统返回初始状态（`adresse_machine = "00"`）
- ✓ 可以重新尝试输入

---

### Test 5: 失败后重试 🔄

**目的**: 验证输入错误后可以重新输入正确密码

**测试步骤**:
```
在Test 4失败后，重新输入完整的正确密码序列：
BTND → BTNR → BTNU → BTNL
```

**验证点**:
- ✓ 门应该能正常打开（`ouverture_porte = '1'`）
- ✓ 证明错误不会永久锁定系统

---

### Test 6: 地址序列验证 🔍

**目的**: 验证内存地址在输入过程中正确递增

**测试步骤**:
```vhdl
初始: adresse_machine = "00"
按BTND后: adresse_machine = "00" (验证第1位)
按BTNR后: adresse_machine = "01" (验证第2位)
按BTNU后: adresse_machine = "10" (验证第3位)
按BTNL后: adresse_machine = "11" (验证第4位)
```

**验证点**:
- ✓ 地址按照 00 → 01 → 10 → 11 顺序变化
- ✓ 每个状态读取正确的内存位置

---

## ⏱️ 时序图示例

### 正确密码输入的时序

```
时钟:     __|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_

按钮:     0000__0001____0000__0010____0000__0100____0000__1000____0000

状态:     IDLE_1  WAIT_REL_1  IDLE_2  WAIT_REL_2  IDLE_3  WAIT_REL_3  IDLE_4  SUCCESS

地址:     00      00          01      01          10      10          11      11

门锁:     0       0           0       0           0       0           0       1
```

### 错误密码输入的时序

```
时钟:     __|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_

按钮:     0000__0001____0000__1000____0000

状态:     IDLE_1  WAIT_REL_1  IDLE_2  FAIL    IDLE_1

地址:     00      00          01      00      00

门锁:     0       0           0       0       0
```

---

## 🔧 使用方法

### 1. 使用GHDL仿真

```bash
# 编译所有文件（按依赖顺序）
ghdl -a memoire.vhd
ghdl -a moore_q1.vhd
ghdl -a moore_q1_tb.vhd

# 生成可执行文件
ghdl -e moore_q1_tb

# 运行仿真，生成波形文件
ghdl -r moore_q1_tb --wave=moore_q1_simulation.ghw

# 查看波形（使用GTKWave）
gtkwave moore_q1_simulation.ghw
```

### 2. 使用Vivado仿真

1. 在Vivado中创建项目
2. 添加源文件：
   - `memoire.vhd`
   - `moore_q1.vhd`
3. 添加仿真文件：
   - `moore_q1_tb.vhd`
4. 运行行为仿真（Behavioral Simulation）
5. 查看仿真波形和控制台输出

---

## 📈 仿真波形中应该观察的信号

### 建议添加到波形窗口的信号：

1. **时钟和复位**
   - `clk`
   - `reset`

2. **输入信号**
   - `contenu_bouton[3:0]` （以十六进制显示）
   - `porte`

3. **内部状态**（如果可见）
   - `UUT/state` （以枚举类型显示）
   - `UUT/next_state`
   - `UUT/bouton_presse`

4. **输出信号**
   - `adresse_machine[1:0]` （以十进制显示）
   - `ouverture_porte`
   - `contenu_mem[3:0]` （以十六进制显示）

---

## ✅ 预期输出（控制台）

如果所有测试通过，你应该在控制台看到：

```
===== DÉBUT DU TEST =====
Test 1: Vérification du reset
Test 2: Saisie du code correct
SUCCESS: La porte est ouverte après code correct
Test 3: Fermeture de la porte
SUCCESS: La machine retourne à l'état initial après fermeture
Test 4: Saisie d'un code incorrect
SUCCESS: La porte reste fermée après code incorrect
Test 5: Code correct après un échec
SUCCESS: La porte s'ouvre après un nouvel essai correct
Test 6: Vérification des adresses mémoire
SUCCESS: Les adresses mémoire changent correctement
===== TOUS LES TESTS SONT TERMINÉS =====
```

如果有错误，会看到类似：
```
ERREUR: La porte devrait être ouverte après code correct
Error: Assertion violation
```

---

## 🐛 调试技巧

### 如果测试失败：

1. **检查时序**
   - 确认按钮按下和释放的时间足够长
   - 检查时钟周期是否正确

2. **检查初始状态**
   - 确认复位后系统在ST_IDLE_1状态
   - 检查内存是否正确初始化

3. **检查状态转换**
   - 在波形中观察state信号
   - 确认每次输入后状态正确转换

4. **检查按钮去抖动**
   - 确保按钮释放后等待足够时间
   - 检查bouton_presse信号的变化

---

## 📝 扩展建议

如果想增强testbench，可以添加：

1. **边界条件测试**
   - 快速连续按钮（测试去抖动）
   - 同时按多个按钮
   - 在错误状态时继续按按钮

2. **随机测试**
   - 随机生成密码序列
   - 随机的正确/错误输入

3. **覆盖率测试**
   - 确保所有9个状态都被访问
   - 确保所有状态转换都被测试

4. **时序验证**
   - 检查建立时间和保持时间
   - 验证时钟频率的影响

---

## 💡 关键学习点

通过这个testbench，你应该理解：

1. ✅ **如何编写VHDL testbench**
   - 实例化待测模块
   - 生成时钟信号
   - 创建激励信号
   - 使用assert验证结果

2. ✅ **Moore状态机的工作原理**
   - 状态只依赖于输入
   - 输出只依赖于当前状态
   - 需要显式的"等待释放"状态

3. ✅ **按钮去抖动的重要性**
   - 为什么需要等待释放
   - 如何检测按钮按下和释放

4. ✅ **密码验证逻辑**
   - 顺序验证每一位
   - 错误处理和重试机制
   - 成功后的门控制

---

## 📚 参考资料

- VHDL testbench编写规范
- Moore状态机设计原则
- FPGA仿真最佳实践

祝仿真成功！🎉
