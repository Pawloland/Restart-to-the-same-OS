# Restart to the same OS with Windows Boot Manager<br><sub><sub><sub> utilizing `bcdedit /bootcequence "{current}"`</sub></sub></sub>

This guide is for people with Windows multi boot, who want to be able to restart their computer from any place - be it Start Menu, Power Menu, Lock Screen, command prompt, etc - and make it always boot into the same Windows OS on which the restart was initiated. This is achieved by using the `Windows Boot Manager` and the `bcdedit /bootsequence "{current}"` command. It skips the OS selection screen. This solves the issue of having to seat in front of a computer, when clicking update&shutdown from the not-default OS. It will `install updates > restart > finish updating >  shutdown`, instead of how it was - `install updates > restart > boot to the default OS, so not the one that is being updated > wait on the login screen of the default OS`. 

## How to setup:
---
1. Restart Windows by using `Start Menu > Power > Restart`. 
2. Open `Task Scheduler`.
3. Create a new task.
4. In the `General` tab, give it a `Name` and set it to `Run whether user is logged on or not` and `Run with highest privileges`.
5. In the `Triggers` tab, create a new trigger and set it to begin the task `On an event`.
6. Change the `Settings` for the trigger from `Basic` to `Custom`.
7. Click on the `New Event Filter...` button.
8. In the `New Event Filter` window, select `XML` tab and check `Edit query manually`. If you are doing this the first time it will ask you if you are sure you want to do this. Click `Yes`.
9. Paste the following XML code into the text box:
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
10. Please note that the above XML code is valid only for english localization of Windows. If you are using a different localization, you will need to change the `restart` string to the appropriate string for your localization. You can find the appropriate string by opening the `Event Viewer > Windows Logs > System > Filter Current Log...` and filtering for the event ID `1074`. If you have events sorted by `Date and Time` the reboot event should be at the top. When you select a particular event, you will see the details in the `General` tab underneath event entries list. You should find an event that has entry which translates from your language to `Shutdown Type: restart` in english. If you find such an event, navigate to the `Details` tab which is right next to the `General` tab. The string you are looking for is the one in the `param5` field.
For example, if you are using a polish localization, you will need to change the `restart` string to `uruchomienie ponowne`.
11. Click `OK` to close the `New Event Filter` window.
12. Click `OK` to close the `New Trigger` window and make sure that the `Enabled` checkbox is checked.
13. Navigate to the `Actions` tab and click `New...`.
14. In the `New Action` window, select `Start a program` if not already selected.
15. ***In the `Program/script` field, enter `bcdedit`.***
16. ***In the `Add arguments (optional)` field, enter `/bootsequence "{current}"`.***
17. Click `OK` to close the `New Action` window.
18. Navigate to the `Conditions` tab and make every checkbox unchecked.
19. Navigate to the `Settings` tab and again make sure every checkbox is unchecked.
20. Click `OK` to close the `Create Task` window and save changes.
21. If prompted for credentials, enter your credentials for running this task and click `OK`.
22. You are done 🎉. You can now restart your from any place - be it Start Menu, Power Menu, Lock Screen, command prompt, etc. and it will always boot into the same Windows OS on which you initiated the restart.


## How to uninstall:
---
1. Simply delete the task you created from the `Task Scheduler`.


## FAQ:
---
1. **Why do I need to restart Windows at the beginning?**
    
    To make sure that the `Event Viewer` is able to log the event that tells about the restart. It's needed in the step 10 of the setup instructions, where we are filtering for the event that tells us what string to use in the XML code.
2. **It doesn't work with linux/grub/refind etc. What now?**
    
    These instructions are only applicable for boot entries that are booted using the only one Windows Boot Manager - so basically only Windows OSes. If you aren't using Windows Boot Manager, you have 2 options:
        
    - Set the `BOOTNEXT` EFI variable to the currently booted OS, which takes higher priority than the currently installed boot manager of your choice (but is very not pleasant to do from Windows without writing come c++/c# code). 
        
    - Use a special way of communicating with your boot manager of choice, like in this guide with the Windows one using `bcdedit`. 