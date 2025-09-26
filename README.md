# ⚡ PowerRate 🖥️

**PowerRate** is a Windows utility that automatically switches your display's refresh rate to either maximum or minimum, depending on your current power source (AC or Battery). This helps optimize battery life when unplugged and ensures smooth performance when plugged in.

---

## 🚀 How It Works

PowerRate operates in the background and leverages Windows' Task Scheduler to monitor system power events. When a change in the power source is detected (e.g., plugging in or unplugging the charger), PowerRate automatically adjusts your display's refresh rate accordingly:

- 🔌 **On AC Power:** Sets your display to the maximum refresh rate for the best experience.
- 🔋 **On Battery:** Switches to the minimum refresh rate to conserve battery.

---

## ✨ Features

- 🤖 **Automatic Switching:** No manual intervention needed after setup.
- 🔄 **Seamless Integration:** Uses Windows event triggers for instant response.
- 🛠️ **Easy Installation & Removal:** Simple batch scripts for setup and cleanup.
- 📦 **Standalone Executable:** No need to install Python or any dependencies.

---

## 🛠️ Installation

1. **Download and Extract:**  
   ⬇️ Download the PowerRate release and extract it to a convenient location.

2. **Install the Scheduled Task:**  
   ⚙️ Run `AddTask.bat` as **Administrator**.  
   This script will install a scheduled task that runs PowerRate's switcher automatically when a power source change is detected (`Kernel-Power` event).

3. **That's it!**  
   🎉 PowerRate will now automatically manage your refresh rate in the background.

> ⚠️ **Note:**  
> If you want to move the PowerRate files to another location, you’ll need to **first uninstall** (remove the scheduled task using `RemoveTask.bat`), **move the files**, and then **reinstall** by running `AddTask.bat` from the new location.

---

## ❌ Removal

1. 🗑️ Run `RemoveTask.bat` as **Administrator** to remove the scheduled task.
2. 🧹 Delete the PowerRate folder to fully remove the application.

---

## 🧑‍💻 Technical Details

- **Trigger:** The scheduled task listens for Windows `Kernel-Power` events.
- **Switcher:** The main logic is implemented in Python and bundled as a standalone executable using PyInstaller.  
  🐍 _No need to install Python or any libraries — everything is included!_

---

## 🖥️ Requirements

- 🪟 Windows 10/11
- 🔑 Administrative privileges for initial setup and removal

---

## 🕵️ Transparency

- 🚫 PowerRate does **not** contain any encrypted or obfuscated code.  
- 🔍 All operations are transparent, and the source code is available for your review.
- 🐍 If you wish, you can compile the Python source code yourself using PyInstaller to create the executable.
- 📖 The application is fully open regarding its functionality; you can see exactly how it works.

---

## 🛟 Troubleshooting

- 👮 Make sure to run batch scripts (`AddTask.bat`/`RemoveTask.bat`) as **Administrator**.
- 🖥️ If the refresh rate is not switching, confirm that your display supports multiple refresh rates and that you have the correct permissions.

---

## 📄 License

This project is open source and available under the MIT License.

---

**PowerRate** – Smart refresh rate switching for Windows! ⚡🖥️