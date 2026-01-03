@echo off
chcp 65001 >nul
cls
title HTML圖片路徑更新工具
color 0A

echo.
echo ============================================
echo     智能點餐系統 - 圖片路徑更新
echo ============================================
echo.

REM 檢查檔案
if not exist "index.html" (
    echo [錯誤] 找不到 index.html
    pause
    exit /b 1
)

if not exist "image\" (
    echo [錯誤] 找不到 image 資料夾
    pause
    exit /b 1
)

echo [資訊] 正在備份原始檔案...
if exist "index.html.backup" del "index.html.backup"
copy "index.html" "index.html.backup" /Y >nul
echo [成功] 備份完成: index.html.backup
echo.

echo [資訊] 檢查圖片檔案...
set img_count=0
for %%i in (image\*.png) do (
    set /a img_count+=1
    echo   找到: %%~nxi
)

echo.
echo [資訊] 找到 %img_count% 張PNG圖片
echo [資訊] 開始更新HTML檔案...
echo.

REM 方法：直接處理檔案內容
setlocal enabledelayedexpansion
set line_num=0
set scene_count=0

REM 建立臨時檔案
(
for /f "delims=" %%a in (index.html) do (
    set /a line_num+=1
    set "current_line=%%a"
    
    REM 檢查是否包含 slide-image 和 background:
    echo !current_line! | find "slide-image" | find "background:" >nul
    if not errorlevel 1 (
        set /a scene_count+=1
        
        REM 圖片編號從0開始（0.png, 1.png, ..., 18.png）
        set /a img_num=scene_count-1
        
        REM 檢查圖片是否存在
        if exist "image\!img_num!.png" (
            set img_file=!img_num!.png
            echo [處理] 場景 !scene_count!: 使用圖片 !img_file!
            echo ^<div class="slide-image" style="background-image: url('image/!img_file!'); background-size: cover; background-position: center;"^>
        ) else (
            echo [警告] 場景 !scene_count!: 找不到 image/!img_num!.png
            echo !current_line!
        )
    ) else (
        echo !current_line!
    )
)
) > temp_new.html

REM 替換原始檔案
if exist "temp_new.html" (
    move /y temp_new.html index.html >nul
    echo.
    echo ============================================
    echo           更新完成！
    echo ============================================
    echo 處理場景數: !scene_count!
    echo 原始備份: index.html.backup
    echo 修改檔案: index.html
    echo ============================================
) else (
    echo [錯誤] 建立臨時檔案失敗
)

echo.
set /p open="是否要開啟HTML檔案預覽？(Y/N): "
if /i "!open!"=="Y" (
    start index.html
)

echo.
pause