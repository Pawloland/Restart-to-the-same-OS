# Restart to the same OS with Windows Boot Manager<br><sub><sub><sub> utilizing `bcdedit /default "{current}"`</sub></sub></sub>

This guide is for people with Windows multi boot, who want to be able to restart their computer from any place - be it Start Menu, Power Menu, Lock Screen, command prompt, etc - and make it always boot into the same Windows OS on which the restart was initiated. This is achieved by using the ***WBM (Windows Boot Manager)*** and the `bcdedit /default "{current}"` command. Additionally, it doesn't skip the OS selection screen, so it can be easily overridden when a use wants to reboot to different OS. This solves the issue of having to seat in front of a computer, when clicking update&shutdown from the not-default OS. It will `install updates > restart > finish updating >  shutdown`, instead of how it was - `install updates > restart > boot to the default OS, so not the one that is being updated > wait on the login screen of the default OS`. 

## How to setup:
---
1. Download this repo.
2. Extract it somewhere on the filesystem.
3. Restart Windows by using `Start Menu > Power > Restart`. 
4. Open `Task Scheduler`.
5. Create a new task.
6. In the `General` tab, give it a `Name` - ***Set default OS*** and set it to `Run whether user is logged on or not` and `Run with highest privileges`.
7. In the `Triggers` tab, create a new trigger and set it to begin the task `On an event`.
8. Change the `Settings` for the trigger from `Basic` to `Custom`.
9. Click on the `New Event Filter...` button.
10. In the `New Event Filter` window, select `XML` tab and check `Edit query manually`. If you are doing this the first time it will ask you if you are sure you want to do this. Click `Yes`.
11. Paste the following XML code into the text box:
```xml
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">
    *[System[Provider[@Name='User32'] and (EventID=1074)]]
   and 
     *[EventData[Data[@Name='param5'] and (Data='restart')]]
    </Select>
  </Query>
</QueryList>
```
12. Please note that the above XML code is valid only for english localization of Windows. If you are using a different localization, you will need to change the `restart` string to the appropriate string for your localization. You can find the appropriate string by opening the `Event Viewer > Windows Logs > System > Filter Current Log...` and filtering for the event ID `1074`. If you have events sorted by `Date and Time` the reboot event should be at the top. When you select a particular event, you will see the details in the `General` tab underneath event entries list. You should find an event that has entry which translates from your language to `Shutdown Type: restart` in english. If you find such an event, navigate to the `Details` tab which is right next to the `General` tab. The string you are looking for is the one in the `param5` field.
For example, if you are using a polish localization, you will need to change the `restart` string to `uruchomienie ponowne`.
13. Click `OK` to close the `New Event Filter` window.
14. Click `OK` to close the `New Trigger` window and make sure that the `Enabled` checkbox is checked.
15. Navigate to the `Actions` tab and click `New...`.
16. In the `New Action` window, select `Start a program` if not already selected.
17. ***In the `Program/script` field, enter a path to a file `set_default_OS.bat`.***
18. Click `OK` to close the `New Action` window.
19. Navigate to the `Conditions` tab and make every checkbox unchecked.
20. Navigate to the `Settings` tab and again make sure every checkbox is unchecked.
21. Click `OK` to close the `Create Task` window and save changes.
22. If prompted for credentials, enter your credentials for running this task and click `OK`.

23. Create a new task.
24. In the `General` tab, give it a `Name` - ***Set default OS revert*** and set it to `Run whether user is logged on or not` and `Run with highest privileges`.
25. In the `Triggers` tab, create a new trigger and set it to begin the task `At startup`.
26. Navigate to the `Actions` tab and click `New...`.
27. In the `New Action` window, select `Start a program` if not already selected.
28. ***In the `Program/script` field, enter a path to a file `revert_default_OS.bat`.***
29. Click `OK` to close the `New Action` window.
30. Navigate to the `Conditions` tab and make every checkbox unchecked.
31. Navigate to the `Settings` tab and again make sure every checkbox is unchecked.
32. Click `OK` to close the `Create Task` window and save changes.
33. If prompted for credentials, enter your credentials for running this task and click `OK`.
34. You are done 🎉. You can now restart your from any place - be it Start Menu, Power Menu, Lock Screen, command prompt, etc. and it will always boot into the same Windows OS on which you initiated the restart if you don't interrupt the reboot process, or to the OS of your choice if you do.

## How to uninstall:
---
1. Simply delete the tasks you created from the `Task Scheduler` and if you want, delete the downloaded repo folder.



## How it works:
---
1. OS boots.
2. If the file `engaged.txt` contains the string `true`, the script `revert_default_OS.bat` is executed on startup. The first thing it does is disengage the script on next startup by changing the contents of the `engaged.txt` to `false`.
3. Then the script reverts back to a default boot entry that is tracked in the `default_OS.txt`, but only if the contents of file `old_current_OS.txt` and output of command `bcdedit /enum /v | findstr /i "default"` have the same GUID. If they are different, the output of a command takes precedence, because there is possibility, that a user changed the default boot OS in the WBM (Windows Boot Manager) OS selection screen.
4. A user does some work and potentially changes the default OS in `msconfig` or using `bcdedit`.
5. A user initiates a reboot.
6. The script `set_default_OS.bat` is run before a reboot. It saves the current default OS to the `default_OS.txt` and changes the default boot entry in WBM to `"{current}"`. The script also saves the `{current}` GUID to a file `old_current_OS.txt`. At the end it engages the script `revert_default_OS.bat` on next startup by changing the contents of the `engaged.txt` to `true`.
7. Go to step 1.

This way allows to reboot to the same OS and keeps the os selection override screen, (unlike the `bcdedit /bootsequence "{current}"` method).

<sub><sub>TODO: Idk, but maybe also make the OS selection screen be available for shorter time, so if a user wants to change the os and then reboots, he will stay in front of a computer and override the process in time, and if he wants to reboot the current system, it will happen quicker automatically.</sub></sub>

## FAQ:
---
1. **Why do I need to restart Windows at the beginning?**

    To make sure that the `Event Viewer` is able to log the event that tells about the restart. It's needed in the step 12 of the setup instructions, where we are filtering for the event that tells us what string to use in the XML code.

2. **It doesn't work with linux/grub/refind etc. What now?**
    
    These instructions are only applicable for boot entries that are booted using the only one Windows Boot Manager - so basically only Windows OSes. If you aren't using Windows Boot Manager, you have 2 options:
        
    - Set the `BOOTNEXT` EFI variable to the currently booted OS, which takes higher priority than the currently installed boot manager of your choice (but is very not pleasant to do from Windows without writing come c++/c# code). 

    - Use a special way of communicating with your boot manager of choice, like in this guide with the Windows one using `bcdedit`. 


## Additional info:
---
1. Those `.bat` files must be in the same directory, because they reference the same `.txt` files, which paths are relative to the location of those `.bat` scripts. Also they can't be deleted or moved, because they are referenced in the `Task Scheduler` tasks. If they are, you will have to recreate the tasks accordingly.
2. All OS installs available in WBM must have those 2 tasks configured in the exact same way for it to work reliably.
3. After setting up those scripts on all OSes, changing the default boot entry in WBM while rebooting will be respected except for when you initiate a reboot from a not default OS (at the time of initiating reboot) and end up booting with default boot OS that you manually set in WBM to the OS that initiated the reboot. In this scenario, the OS that initiated the reboot will be set as default right before the restart. In WBM it will appear as the default. Lets say a user "tries to reselect it as a default" in the WBM (for the lack of better description of the operation - I hope it will be clear for anyone reading this). User then boots whatever OS that is available in WBM. On startup the `revert_default_OS.bat` is run. From here, it is impossible to determine, if the boot entry saved in the file `old_current_OS.txt` was reselected **to actually be the default OS** while user was in WBM. I don't know a way of registering changes made in WBM, which would be necessary to fix this edge case. Luckily it is very odd action to perform accidentally, so it should be non-issue in the day to day use. I document it just in case someone stumbles upon it unexpectedly in a future.
4. If you are booted to a not default OS and want to make the OS you are booted into the default one, please make it from inside of the OS you are booted into using `bcdedit` or `msconfig` (or some different way I don't know about). Don't perform a reboot with an intent to change it via WBM as it will be ignored. If you want to know why is that, see point 3 above. If you read it already - you have my respect for reading through the whole documentation from the top to bottom 🫡.