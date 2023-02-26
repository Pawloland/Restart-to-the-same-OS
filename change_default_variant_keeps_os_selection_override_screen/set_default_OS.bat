@REM disables this weird Windows behavior of simulating typing out the whole script in command prompt and showing output in between the lines of the script's commands
@echo off
@REM enable unicode
chcp 65001 > NUL
echo [	%~n0%~x0	] [	%time%	] ================== > "%~dp0log.txt"
@REM save current default OS (the same as it appears in msconfig) to file, to make the startup task revert it back to the original default OS (we make something ala pseudo bcdedit /bootsequence)
for /f "tokens=2" %%i in ('bcdedit /enum /v ^| find /i "default"') do @echo %%i > "%~dp0default_OS.txt"

@REM save "{current}" GUID to file, to make the startup task able to compare it against the "{current}" GUID after the reboot is complete
for /f "tokens=2" %%i in ('bcdedit /enum "{current}" /v ^| find /i "identifier"') do @echo %%i > "%~dp0old_current_OS.txt"

@REM enable the revert process on next boot
echo true > "%~dp0engaged.txt"

@REM set default OS to the currently booted one
for /f "tokens=*" %%a in ('bcdedit /default "{current}" 2^>^&1') do echo [	%~n0%~x0	] [	%time%	] %%a >> "%~dp0log.txt" 2>&1
