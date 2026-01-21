# PowerRate

This project automatically changes your display refresh rate (highest or lowest) based on whether your PC is on AC power or battery.

## How to Install

1. Right-click on **AddTask.bat**.
2. Select **Run as administrator**.
3. The task is now added and will work automatically.

## How to Remove

1. Right-click on **RemoveTask.bat**.
2. Select **Run as administrator**.
3. The task will be removed.
4. To completely remove just delete the folder
That's it!

##To Compile Code use PyInstaller
pyinstaller --noconsole "Rate_switcher.py"