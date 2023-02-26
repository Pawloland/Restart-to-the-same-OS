@REM disables this weird Windows behavior of simulating typing out the whole script in command prompt and showing output in between the lines of the script's commands
@echo off 
@REM makes variables inside if that have "!" before and after the name to be expanded at the time of the execution, not when the script is parsed
@REM https://stackoverflow.com/questions/6679907/how-do-setlocal-and-enabledelayedexpansion-work
SETLOCAL EnableDelayedExpansion
@REM enable unicode
chcp 65001 > NUL

@REM check if the script was engaged
echo [	%~n0%~x0	] [	%time%	] revert_init >> "%~dp0log.txt"
echo [	%~n0%~x0	] [	%time%	] "~dp0 - %~dp0" >> "%~dp0log.txt"
set /p engaged=<"%~dp0engaged.txt"
echo [	%~n0%~x0	] [	%time%	] engaged - %engaged% >> "%~dp0log.txt"
@REM echo "engaged - %engaged%"
if %engaged%==true (
   @REM disengage the script
   echo false > "%~dp0engaged.txt" 
   echo [	%~n0%~x0	] [	%time%	] set false to engaged >> "%~dp0log.txt"

   @REM read the old "{current}" GUID from the file
   set /p old_current_OS_from_file=<"%~dp0old_current_OS.txt" >> "%~dp0log.txt" 2>&1
   @REM echo "old_current_OS_from_file - %old_current_OS_from_file%"
   echo [	%~n0%~x0	] [	%time%	] "old_current_OS_from_file - !old_current_OS_from_file!" >> "%~dp0log.txt"

   @REM read the default OS from bcdedit (can be changed in Windows Boot Manager os selection screen or in msconfig when booted)
   for /f "tokens=2" %%i in ('bcdedit /enum /v ^| find /i "default"') do set default_OS_from_bcdedit=%%i >> "%~dp0log.txt" 2>&1
   @REM echo "default_OS_from_bcdedit - %default_OS_from_bcdedit%"
   echo [	%~n0%~x0	] [	%time%	] "default_OS_from_bcdedit - !default_OS_from_bcdedit!" >> "%~dp0log.txt" 

   @REM read the default OS from the file
   set /p default_OS_from_file=<"%~dp0default_OS.txt" >> "%~dp0log.txt" 2>&1
   @REM echo "default_OS_from_file - %default_OS_from_file%"
   echo [	%~n0%~x0	] [	%time%	] "default_OS_from_file - !default_OS_from_file!">> "%~dp0log.txt"

   if !old_current_OS_from_file!==!default_OS_from_bcdedit! (
      echo [	%~n0%~x0	] [	%time%	] "old_current_OS_from_file==default_OS_from_bcdedit - true">> "%~dp0log.txt"

      @REM revert default OS to the one saved in the file and redirect the output to log formatted file nicely
      for /f "tokens=*" %%a in ('bcdedit /default !default_OS_from_file! 2^>^&1') do echo [	%~n0%~x0	] [	%time%	] %%a >> "%~dp0log.txt" 2>&1
      @REM echo "old_current_OS_from_file==default_OS_from_bcdedit - true"

   ) 
   @REM ) else (
   @REM    @REM the default OS was changed in Windows Boot Manager os selection screen so keep as is
   @REM    @REM do nothing
   @REM    echo "old_current_OS_from_file==default_OS_from_bcdedit - false"
   @REM )
   
)
echo [	%~n0%~x0	] [	%time%	] ================== >> "%~dp0log.txt"