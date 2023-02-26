@REM disables this weird Windows behavior of simulating typing out the whole script in command prompt and showing output in between the lines of the script's commands
@echo off
@REM enable unicode
chcp 65001 > NUL

@REM check if we are running elevated
net session > NUL 2>&1
if %errorLevel% == 0 (
    @REM if we are, then we can start the powershell script in the same window
    powershell "Start-Process powershell -NoNewWindow -Wait -ArgumentList '-ExecutionPolicy Bypass -File %~dp0install.ps1'"
) else (
    @REM if we are not, then we need to start the powershell script in a new window
    powershell "Start-Process powershell -Verb runAs -ArgumentList '-ExecutionPolicy Bypass -File %~dp0install.ps1'"
)
