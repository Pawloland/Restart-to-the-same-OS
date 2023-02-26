@REM disables this weird Windows behavior of simulating typing out the whole script in command prompt and showing output in between the lines of the script's commands
@echo off
@REM enable unicode
chcp 65001 > NUL

@REM check if we are running elevated
net session > NUL 2>&1
if %errorLevel% == 0 (
    @REM if we are, then we can start uninstalling
    echo [	%~n0%~x0	] [	%time%	] ------------------ 
    echo [	%~n0%~x0	] [	%time%	] Uninstalling...
    for /f "tokens=*" %%a in ('schtasks /delete /f /tn "Save this OS as default - set" 2^>^&1') do echo [	%~n0%~x0	] [	%time%	] %%a
    for /f "tokens=*" %%a in ('schtasks /delete /f /tn "Save this OS as default - revert" 2^>^&1') do echo [	%~n0%~x0	] [	%time%	] %%a
    echo [	%~n0%~x0	] [	%time%	] ------------------
    @REM check if this script wasn't started from another script
    if not "%1" == "delegated" (
        pause
    )
) else (
    @REM if we are not, then we need to reopen this script elevated (and it wasn't started from install.ps1)
    powershell "Start-Process '%~dp0%~n0%~x0' -Verb runAs"
    
)

