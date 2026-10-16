# Mem Reduct 智能内存优化与全自动免管套件 (Auto Optimizer)

> **开箱即用 · 彻底告别鼠标转圈 · 5分钟极速自动轮询 · 75% 应急防御 · 开机最高管理员权限静默接管 (免 UAC 弹窗)**

---

## ⚡ 极简上手指南（3秒搞定，终身免管）

### 场景 A：下载便携包 / 换到新电脑（最推荐）
1. 点击直链下载预调优便携包 👉 [**MemReduct_AutoOptimizer_Portable.zip**](https://github.com/Kekeyo/memreduct-auto-optimizer/releases/latest/download/MemReduct_AutoOptimizer_Portable.zip)（或前往 [GitHub Releases](https://github.com/Kekeyo/memreduct-auto-optimizer/releases/tag/v3.5.2-optimized) 下载最新版）；
2. **直接双击运行其中的 `一键静默自启配置.bat`**：
   - 脚本会自动请求管理员权限；
   - 自动在 Windows 注册最高特权开机计划任务（彻底跳过 UAC 黄色弹窗）；
   - 自动启动程序并最小化常驻右下角托盘；
3. **搞定！** 从今往后无需任何手动干预，开机自动后台静默守护。

---

### 场景 B：已有 Mem Reduct，手动配置（图形界面 2 步）

#### 第一步：彻底消除转圈卡顿 (按 F2 调出设置)
1. 在软件窗口上按键盘 **`F2`** 键调出设置窗口（或点击 `File -> Settings...`）；
2. 切换到 **`Memory cleaning` (内存清理)** 页面：
   * ❌ **取消勾选** `Working set`（工作集，取消后前台软件不再掉帧）；
   * ❌ **取消勾选** `Modified page list`（已修改页面列表，官方打星号 `*` 的致卡项，取消后磁盘不再 100% 满载）；
   * ✅ **保留勾选** `Standby list`（待机列表，核心缓存释放项，瞬间秒清几十 GB）；
   * ✅ **保留勾选** `System working set`；
   * ✅ **勾选并设置** `Clean automatically every 5 minutes`（每 5 分钟定时自动清理）；
   * ✅ **勾选并设置** `Clean when usage exceeds 75%`（超过 75% 自动紧急防御）。

#### 第二步：打通无感开机管理员自启 (顶部 Settings 快捷菜单)
1. 在主界面顶部直接点击 **`Settings`** 快捷下拉菜单；
2. 确保勾选以下三项：
   * ✅ **`Load on system startup`**（开机自动启动）；
   * ✅ **`Skip "User Account Control" prompt warning`**（核心项！自动通过计划任务赋予最高权限，且**开机绝不弹 UAC 黄色弹窗**）；
   * ✅ **`Start minimized`**（启动后直接常驻右下角托盘，桌面不弹窗）；
3. 直接关闭主窗口即可。

---

## 🤖 给 AI 智能体的无脑配置指令 (For AI Agent Instruction)

> **智能体行动准则**：智能体应定位到程序的便携目录并直接修饰写入 `memreduct.ini`，避免进行无效的 UI 猜测。

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

### 掩码二进制解析 (`ReductMask2 = 234`)
掩码 `234`（十六进制 `0xEA`，二进制 `11101010`）是兼顾性能与稳定性的黄金组合：
* **Bit 0 (`0x01 = 1`) Working set**：**关闭 (0)** —— 严禁清前台活跃工作集，防止软件掉帧卡顿；
* **Bit 1 (`0x02 = 2`) System file cache**：**开启 (1)** —— 正常清理系统文件缓存；
* **Bit 2 (`0x04 = 4`) Modified page list**：**关闭 (0)** —— 严禁刷脏页，彻底消除磁盘 I/O 100% 导致的鼠标转圈卡死；
* **Bit 3 (`0x08 = 8`) Standby list**：**开启 (1)** —— 清理核心待机列表缓存；
* **Bit 5 (`0x20 = 32`) Standby list (without priority)**：**开启 (1)**；
* **Bit 6 (`0x40 = 64`) Registry cache**：**开启 (1)**；
* **Bit 7 (`0x80 = 128`) Combine memory lists**：**开启 (1)**；
* **数值计算**：$2 + 8 + 32 + 64 + 128 = 234$。

### 智能体自动化执行脚本 (PowerShell 一键落盘)
```powershell
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

## 🔍 为什么默认配置会卡顿转圈？（内核底层诊断）

在默认或未调优状态下，用户常遇到两大致命体验问题：

### 1. 内存越积越多，鼠标频繁“转圈卡死”
* **原因一：自动清理默认被禁闭**。Mem Reduct 内部默认隐藏了一个保护开关 `IsAllowStandbyListCleanup=false`。即便开启了自动清理，底层也会强制跳过对 Windows 待机缓存（Standby Cache）的释放，导致系统文件缓存持续暴涨，可用内存耗尽，系统陷入频繁页面置换与内存锁，鼠标转圈。
* **原因二：误开致卡清理项**。若清理掩码中勾选了 `Modified page list`（已修改页面列表），触发瞬间会导致大量系统脏页同步刷盘，硬盘 I/O 瞬间拉满 100%，引发前台界面冻结转圈 1~2 秒；若勾选了 `Working set`，会把前台活跃程序的数据倒腾至虚拟内存，引发掉帧。

### 2. 开机自启动无法获得管理员权限
* 释放 Windows 系统内核级的 Standby List 必须具有最高管理员特权（High Elevation）。
* 若直接在注册表设置自启，Windows 开机会因 UAC 限制**直接拦截自启**或跳出刺眼的黄色弹窗打扰。

---

## 📌 软件官方来源与开源声明 (Attribution)

* **软件名称**：Mem Reduct
* **官方开源主页**：[https://github.com/henrypp/memreduct](https://github.com/henrypp/memreduct)
* **官方发布主页**：[https://www.henrypp.org](https://www.henrypp.org)
* **原作者**：Henry++ ([@henrypp](https://github.com/henrypp))
* **开源协议**：GNU General Public License v3.0 (GPL-3.0)
* **核心定位**：基于 Windows 未公开 Native API (`NtSetSystemInformation`) 开发的轻量级物理内存与系统待机缓存管理工具。
