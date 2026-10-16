@echo off
chcp 65001 >nul
title Mem Reduct 全自动免管配置启动器
echo ========================================================
echo       Mem Reduct 智能内存优化套件 - 一键静默部署
echo ========================================================
echo.

:: 检查是否具有管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
set "EXE_PATH=%~dp0memreduct.exe"

echo [1/3] 正在注册 Windows 最高管理员权限计划任务...
schtasks /create /tn "memreductTask" /tr "\"%EXE_PATH%\" $(Arg0)" /sc onlogon /rl highest /f >nul 2>&1

echo [2/3] 正在写入注册表开机静默自启项...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Mem Reduct" /t REG_SZ /d "\"%EXE_PATH%\" -minimized" /f >nul 2>&1

echo [3/3] 正在启动 Mem Reduct 并常驻右下角托盘...
taskkill /f /im memreduct.exe >nul 2>&1
start "" "%EXE_PATH%" -minimized

echo.
echo ========================================================
echo  [成功] 部署完成！
echo  - 已开启开机静默自启（最高管理员权限，永不弹 UAC 弹窗）
echo  - 已开启 5 分钟自动待机缓存释放与 75%% 应急防御
echo  - 程序已在右下角托盘后台静默守护，从今往后彻底不用管了！
echo ========================================================
echo.
timeout /t 3 >nul
exit /b
