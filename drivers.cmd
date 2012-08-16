@echo off
setlocal
if /i '%1==' goto usage
if not exist %1 (
    echo Directory does not exist: %1
    exit /b 1
)
for /f "usebackq delims=" %%i in (`dir /s /b /a:d %1 ^| findstr /e \x86`) do dism /image:mount /add-driver:"%%i" /recurse
endlocal
goto :EOF

:usage
echo Usage: drivers source
echo.
echo Example: drivers c:\win7x86pe\pe
goto :EOF