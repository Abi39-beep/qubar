# qubar

🚀 Custom Quickshell Desktop Bar & Dashboard

A highly customized, modular, and dynamic Wayland desktop bar built entirely in Quickshell for Hyprland. It features floating pill-shaped designs, interactive popups, system tray controls, and a massive all-in-one Control Center / Dashboard with live theming capabilities.

## 📦 System Dependencies

To ensure every widget, slider, and bash command in this setup works correctly, you must have the following packages installed. (Package names are based on Arch Linux / AUR).

### 🛠️ Core Packages
| Dependency | Purpose |
| :--- | :--- |
| `quickshell-git` | The core rendering engine for the UI. |
| `hyprland` | The Wayland compositor (Workspaces widget depends on this). |
| `ttf-jetbrains-mono-nerd` | Essential for all the icons (Volume, WiFi, Battery, etc.) to render correctly. |

### 🔋 Hardware & System
| Dependency | Purpose |
| :--- | :--- |
| `upower` | Reads live battery percentage and charging status. |
| `power-profiles-daemon` | Required for the Battery popup to switch between Performance, Balanced, and Power Saver. |
| `brightnessctl` | Allows the Dashboard brightness slider and scroll wheel to control screen backlight. |
| `libsmbios` | *(Dell Laptops Only)* Provides `smbios-battery-ctl` to communicate directly with hidden BIOS settings for custom charge limits. |

### 📡 Connectivity (Network & Bluetooth)
| Dependency | Purpose |
| :--- | :--- |
| `networkmanager` | Required for `nmcli` to scan for WiFi, connect, and verify ethernet status. |
| `bluez` & `bluez-utils` | Required for `bluetoothctl` to scan, pair, connect, and toggle Bluetooth power. |

### 🎵 Media & Audio
| Dependency | Purpose |
| :--- | :--- |
| `pipewire` & `wireplumber` | Quickshell's native audio tracker requires Pipewire to track volume/mute status, and the `wpctl` command to change it. |
| `playerctl` | Required for the Dashboard to fetch media metadata (Title, Artist, Album Art) and control playback. |

### 📋 Clipboard & Notifications
| Dependency | Purpose |
| :--- | :--- |
| `wl-clipboard` | Provides `wl-copy` and `wl-paste` to copy text/images from the history. |
| `cliphist` | The backend database that stores clipboard history. |

### 🎨 Theming Engine
| Dependency | Purpose |
| :--- | :--- |
| `glib2` | Provides the `gsettings` command used to force GTK apps to live-reload their colors. |
| `adw-gtk3` | The base GTK theme required to maintain beautiful rounded corners and shadows when the script injects custom colors. |

---

## 🧩 Widget Breakdown & Features

1. **shell.qml (The Root)**
   * **Floating Design:** A top-anchored, horizontally centered bar with a width of 570px, floating 2px from the top edge with rounded 18px corners.
   * **Smart Layout:** Uses centered and nested rows to perfectly space the Clock, Workspaces, and Tray modules.

2. **DashboardWidget.qml (The Control Center)**
   * This is the heart of the setup. It contains:
   * **Power Menu:** 5-button power row (Lock, Sleep, Logout, Reboot, Power) with a 10-second confirmation overlay.
   * **Media Player:** Fetches active album art, applies a blurred MultiEffect mask to the background, and features live progress sliders and playback controls.
   * **Hardware Stats:** Live CPU and Memory tracking utilizing `top` and `free -m`.
   * **Sliders:** Volume and Brightness sliders that fully support mouse dragging and scroll-wheel inputs.
   * **Notifications Tab:** Replaces `dunst` or `mako`. Intercepts system notifications, shows them in a list, and allows dismissing/clearing. Includes a floating OSD for incoming alerts.
   * **Clipboard Tab:** Visualizes `cliphist` history. Click to copy, click the trash can to delete, or clear the entire history.
   * **External Templates Popup:** A dedicated popup that dynamically reads the active Quickshell `Colors.qml` and injects those exact hex codes into `gtk.css` and Zed Editor's `settings.json`, providing instant, universal system theming.

3. **Workspaces.qml**
   * **Hyprland Native:** Uses Quickshell's Hyprland service to natively track workspaces.
   * **Dynamic Pill Animation:** Unoccupied workspaces are small dots, occupied are circles, and the currently focused workspace smoothly animates into a 50px wide pill.

4. **WifiWidget.qml**
   * **Ethernet/WiFi Smart Icon:** Automatically detects if you are on a wired connection and prioritizes the Ethernet icon.
   * **Interactive Network List:** Click the widget to open a WiFi scanner. Click a network to expand a smooth, animated password input box. Sends direct `nmcli` connection commands.

5. **BluetoothWidget.qml**
   * **Live Scanning & Toggles:** Toggle Bluetooth power instantly. Features a physical scan button.
   * **Device Management:** Lists all saved devices, highlights connected devices in blue, and allows one-click connect/disconnect via `bluetoothctl`.

6. **Battery.qml**
   * **Power Profiles:** Clicking the widget reveals a menu to switch between CPU power profiles (performance, balanced, power-saver) to extend battery life on laptops.

7. **CalendarWindow.qml**
   * **Clean Overlay:** A simple grid-based date viewer that highlights the current day. Closes automatically when clicking away or pressing Escape.

---

## ⚠️ Important Setup Notes

**1. Disable other Notification Daemons:**  
Quickshell acts as its own Notification Server. If you have `dunst`, `mako`, or `swaync` running in your background, the Quickshell notification widget will not catch alerts. Disable them in your Hyprland config.

**2. Autostart Cliphist:**  
For the clipboard widget to function, `cliphist` must actively listen in the background. Ensure these lines are in your `hyprland.conf`:
```bash
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

3. Hyprland IPC:

Ensure your Hyprland configuration allows IPC so the Workspaces widget can read window data.

4. Dell Battery Limit Override (Hardware Specific):

If you are using a Dell laptop, the proprietary motherboard BIOS actively ignores standard Linux kernel charge limits. To allow the Quickshell battery slider to actually stop the laptop from charging and protect battery health, you must bypass the kernel and talk directly to the BIOS using Dell's SMBIOS tool.

    Step 1: Install the Dell SMBIOS utility

    Ensure libsmbios is installed on your system.

    Step 2: Enable Passwordless Sudo for the utility

    Every time you plug in the AC adapter, the Linux kernel resets battery file permissions. The QML slider bypasses this by executing the official Dell tool directly. You must grant your user permission to run this specific tool without a password prompt. Run these commands in your terminal (Be sure to replace abimanyu with your actual username if you ever change it on a fresh install):
    Bash

    # 1. Ensure the sudoers drop-in directory exists
    sudo mkdir -p /etc/sudoers.d

    # 2. Create the bypass rule file
    echo "abimanyu ALL=(ALL) NOPASSWD: /usr/bin/smbios-battery-ctl, /usr/sbin/smbios-battery-ctl" | sudo tee /etc/sudoers.d/battery-limit

    Step 3: How the UI controls it

    As long as steps 1 and 2 are completed, the Profilemenu.qml slider will automatically work. When you drag the slider, Quickshell silently runs sudo smbios-battery-ctl --set-custom-charge-interval={start} {stop} in the background. This forcefully switches the Dell motherboard into "Custom" mode and physically cuts off the wall power the exact second your battery hits the slider's limit.
