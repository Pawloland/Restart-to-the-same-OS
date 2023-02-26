# Restart to the same OS with Windows Boot Manager<br><sub><sub><sub> utilizing `bcdedit /default "{current}"`</sub></sub></sub>

This guide is for people with Windows multi boot, who want to be able to restart their computer from any place - be it Start Menu, Power Menu, Lock Screen, command prompt, etc - and make it always boot into the same Windows OS on which the restart was initiated. This is achieved by using the ***WBM (Windows Boot Manager)*** and the `bcdedit /default "{current}"` command. Additionally, it doesn't skip the OS selection screen, so it can be easily overridden when a use wants to reboot to different OS. This solves the issue of having to seat in front of a computer, when clicking update&shutdown from the not-default OS. It will `install updates > restart > finish updating >  shutdown`, instead of how it was - `install updates > restart > boot to the default OS, so not the one that is being updated > wait on the login screen of the default OS`. 

## How to setup:
---
1. Download this repo.
2. Extract it somewhere on the filesystem.
3. Restart Windows by using `Start Menu > Power > Restart`. 
4. After restart run `install.bat` (note that the file extension must be `.bat`, not `.ps1`).
5. It will auto elevate if needed and ask for your password, to make the task `run with highest privileges`. (If you don't have a password, you may be unable to proceed, because AFAIK Windows doesn't allow to run tasks with highest privileges from an account without a password. In this case you need to set up not empty password for your account and then start over from step 1.)
6. You are done 🎉. You can now restart your computer from any place - be it Start Menu, Power Menu, Lock Screen, command prompt, etc. and it will always boot into the same Windows OS on which you initiated the restart - if you don't interrupt the reboot process, or to the OS of your choice - if you do.

## How to uninstall:
---
1. Just run `uninstall.bat`. It will auto elevate if needed.



## How it works:
---
1. OS boots.
2. If the file `engaged.txt` contains the string `true`, the script `revert_default_OS.bat` is executed on startup. The first thing it does is disengage the script on next startup by changing the contents of the `engaged.txt` to `false`.
3. Then the script reverts back to a default boot entry that is tracked in the `default_OS.txt`, but only if the contents of file `old_current_OS.txt` and output of command `bcdedit /enum /v | findstr /i "default"` have the same GUID. If they are different, the output of a command takes precedence, because there is possibility, that a user changed the default boot OS in the WBM OS selection screen.
4. A user does some work and potentially changes the default OS in `msconfig` or using `bcdedit`.
5. A user initiates a reboot.
6. The script `set_default_OS.bat` is run before a reboot. It saves the current default OS to the `default_OS.txt` and changes the default boot entry in WBM to `"{current}"`. The script also saves the `{current}` GUID to a file `old_current_OS.txt`. At the end it engages the script `revert_default_OS.bat` on next startup by changing the contents of the `engaged.txt` to `true`.
7. Go to step 1.

This way allows to reboot to the same OS and keeps the os selection override screen, (unlike the `bcdedit /bootsequence "{current}"` method).

<sub><sub>TODO: Idk, but maybe also make the OS selection screen be available for shorter time, so if a user wants to change the os and then reboots, he will stay in front of a computer and override the process in time, and if he wants to reboot the current system, it will happen quicker automatically.</sub></sub>

## FAQ:
---
1. **Why do I need to restart Windows at the beginning?**

    To make sure that the `Event Viewer` is able to log the event that tells about the restart. It's needed in the `install.ps1` script, where we are filtering for the event that tells us what string to use in the XML representation of task. The string is unfortunately specific to a language and is not able to be retrieved in english regardless of the language installed. The `install.ps1` script gets the latest 1074 event, that is the one that was caused by a user when he restarted a computer as in a step 1 of the `How to setup` section.

2. **It doesn't work with linux/grub/refind etc. What now?**
    
    These instructions are only applicable for boot entries that are booted using the only one WBM - so basically Windows OSes. If you aren't using WBM, you have 2 options:
        
    - Set the `BOOTNEXT` EFI variable to the currently booted OS, which takes higher priority than the currently installed boot manager of your choice (but is very not pleasant to do from Windows without writing come c++/c# code). 

    - Use a special way of communicating with your boot manager of choice, like in this guide with the Windows one using `bcdedit`. 


## Additional info:
---
1. All script files must be in the same directory, because they reference the same `.txt` files, which paths are relative to the location of those scripts. Also they can't be deleted or moved, because they are referenced in the `Task Scheduler` tasks. If they are, you will have to recreate the tasks accordingly.
2. All OS installs available in WBM must have those 2 tasks configured in the exact same way for it to work reliably.
3. After setting up those scripts on all OSes, changing the default boot entry in WBM while rebooting will be respected except for when you initiate a reboot from a not default OS (at the time of initiating reboot) and end up booting with default boot OS that you manually set in WBM to the OS that initiated the reboot. In this scenario, the OS that initiated the reboot will be set as default right before the restart. In WBM it will appear as the default. Lets say a user "tries to reselect it as a default" in the WBM (for the lack of better description of the operation - I hope it will be clear for anyone reading this). User then boots whatever OS that is available in WBM. On startup the `revert_default_OS.bat` is run. From here, it is impossible to determine, if the boot entry saved in the file `old_current_OS.txt` was reselected **to actually be the default OS** while user was in WBM. I don't know a way of registering changes made in WBM, which would be necessary to fix this edge case. Luckily it is very odd action to perform accidentally, so it should be non-issue in the day to day use. I document it just in case someone stumbles upon it unexpectedly in a future.
4. If you are booted to a not default OS and want to make the OS you are booted into the default one, please make it from inside of the OS you are booted into using `bcdedit` or `msconfig` (or some different way I don't know about). Don't perform a reboot with an intent to change it via WBM as it will be ignored. If you want to know why is that, see point 3 above. If you read it already - you have my respect for reading through the whole documentation from the top to bottom 🫡.