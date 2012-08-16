@echo off
setlocal
set choice=packages
set image=install.wim
choice /c 12 /m "Press 1 for pe install or 2 for image install"
if %ERRORLEVEL%==1 (
    set choice=pe
    set image=winpe.wim
)
set save=commit
echo Currently set to %save% changes made to the image. Edit make.cmd to change this behavior.
choice /c yn /m Continue?
if %ERRORLEVEL%==2 exit /b 1
mount %image% && drivers %choice% && unmount /%save% && if %choice%==pe makeiso
endlocal