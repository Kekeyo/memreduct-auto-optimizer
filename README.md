# Mem Reduct 全自动防卡顿部署指南 (GitHub 开源与智能体就绪版)

> 本文档专为 **人类用户** 与 **AI 智能体 (Agent)** 共同设计：
> - **智能体**可直接读取并执行文中的自动化修改逻辑与配置注入；
> - **人类用户**可直接查看极简的“免管操作清单”；
> - 格式标准、开源隐私已脱敏，可直接作为仓库的 `README.md` 发布到 GitHub。

---

## 1. 软件来源与官方开源声明 (Attribution & Source)

* **软件名称**：Mem Reduct
* **官方开源主页**：[https://github.com/henrypp/memreduct](https://github.com/henrypp/memreduct)
* **官方发布主页**：[https://www.henrypp.org](https://www.henrypp.org)
* **原作者**：Henry++ ([@henrypp](https://github.com/henrypp))
* **开源协议**：GNU General Public License v3.0 (GPL-3.0)
* **核心定位**：基于 Windows 未公开 Native API (`NtSetSystemInformation`) 开发的轻量级物理内存与系统待机缓存管理工具。

---

## 2. 核心痛点诊断与底层机理 (Why Default Settings Fail)

在默认或未调优状态下，用户常遇到两大致命体验问题：

### ① 内存越积越多，鼠标频繁“转圈卡死”
* **原因一：自动清理默认被禁闭**。Mem Reduct 内部默认隐藏了一个保护开关 `IsAllowStandbyListCleanup=false`。即便开启了自动清理，底层也会强制跳过对 Windows 待机缓存（Standby Cache）的释放，导致系统文件缓存持续暴涨，可用内存耗尽，系统陷入频繁页面置换与内存锁，鼠标转圈。
* **原因二：误开致卡清理项**。若清理掩码中勾选了 `Modified page list`（已修改页面列表），触发瞬间会导致大量系统脏页同步刷盘，硬盘 I/O 瞬间拉满 100%，引发前台界面冻结转圈 1~2 秒；若勾选了 `Working set`，会把前台活跃程序的数据倒腾至虚拟内存，引发掉帧。

### ② 开机自启动无法获得管理员权限
* 释放 Windows 系统内核级的 Standby List 必须具有最高管理员特权（High Elevation）。
* 若直接在注册表设置自启，Windows 开机会因 UAC 限制**直接拦截自启**或跳出刺眼的黄色弹窗打扰。

---

## 3. 给智能体的配置注入指令 (For AI Agent Instruction)

> **智能体行动准则**：
> 当接收到配置 Mem Reduct 的任务时，智能体应定位到程序的便携目录并直接修饰写入 `memreduct.ini`，避免进行无效的 UI 猜测。

### 黄金配置模板 (`memreduct.ini`)
```ini
[memreduct]
; 基础与免打扰
IsShowReductConfirmation=false
IsShowWarningConfirmation=false
BalloonCleanResults=false

; 核心自动化与防卡频率
AutoreductEnable=true
AutoreductValue=75
AutoreductIntervalEnable=true
AutoreductIntervalValue=5

; 底层核心解锁与防卡掩码
IsAllowStandbyListCleanup=true
ReductMask2=234

; 托盘与界面状态
TrayShowBorder=false
TrayUseTransparency=false
TrayUseAntialiasing=true
SettingsLastPage=102
```

### 掩码二进制深度解析 (`ReductMask2 = 234`)
掩码 `234`（十六进制 `0xEA`，二进制 `11101010`）是对稳定性和性能最优的黄金组合：
* **Bit 0 (`0x01 = 1`) Working set**：**关闭 (0)** —— 严禁清理前台活跃工作集，防止软件掉帧卡顿；
* **Bit 1 (`0x02 = 2`) System file cache**：**开启 (1)** —— 正常清理系统文件缓存；
* **Bit 2 (`0x04 = 4`) Modified page list**：**关闭 (0)** —— 严禁刷脏页，彻底消除磁盘 I/O 100% 导致的鼠标转圈卡死；
* **Bit 3 (`0x08 = 8`) Standby list**：**开启 (1)** —— 清理核心待机列表缓存；
* **Bit 5 (`0x20 = 32`) Standby list (without priority)**：**开启 (1)**；
* **Bit 6 (`0x40 = 64`) Registry cache**：**开启 (1)**；
* **Bit 7 (`0x80 = 128`) Combine memory lists**：**开启 (1)**；
* **数值计算**：$2 + 8 + 32 + 64 + 128 = 234$。

### 智能体自动化执行脚本 (PowerShell 一键落盘)
```powershell
# 智能体可直接无脑执行此段脚本完成配置写入
$iniPath = ".\memreduct.ini"
$config = @"
[memreduct]
IsShowReductConfirmation=false
IsShowWarningConfirmation=false
BalloonCleanResults=false
AutoreductEnable=true
AutoreductValue=75
AutoreductIntervalEnable=true
AutoreductIntervalValue=5
IsAllowStandbyListCleanup=true
ReductMask2=234
TrayShowBorder=false
TrayUseTransparency=false
TrayUseAntialiasing=true
SettingsLastPage=102
"@
[System.IO.File]::WriteAllText($iniPath, $config, [System.Text.Encoding]::UTF8)
```

---

## 4. 给人类用户的极简操作指南 (User Action Checklist)

人类用户不需要理解深奥的 Native API，配置完成后，**只需检查以下两步即可终身免管**：

### 步骤一：打通无感开机自启动（仅需点击两次）
1. 启动 `memreduct.exe`；
2. 点击顶部菜单栏的 **`Settings`**；
3. 确保以下两项**均已勾选**：
   * ✅ **`Load on system startup`**（开机自启）
   * ✅ **`Skip "User Account Control" prompt warning`**（核心项！自动通过 Windows 任务计划程序赋予最高管理员权限，且**开机绝不弹 UAC 黄色窗口**）；
4. 勾选 **`Start minimized`**（启动后直接常驻右下角托盘，桌面不弹窗）。

### 步骤二：开启彻底免管
1. 直接点击右上角缩小/关闭按钮，让其退回右下角托盘；
2. **从此电脑每次开机：**
   * 每 **5 分钟** 自动静默打扫一次核心缓存；
   * 若遇突发软件导致内存冲破 **75%**，不等定时，瞬间秒清；
   * 清理过程 0.1 秒内无感完成，**鼠标永不转圈，屏幕永不弹窗**。

---

## 5. 开源脱敏与版权合规声明

* 本文档遵循开源合规规范，所有测试数据及路径均已执行脱敏处理；
* 本指南中涉及的底层分析基于原作者 Henry++ 的开源项目 `henrypp/memreduct` 进行工程调优，其最终版权归原作者所有。
