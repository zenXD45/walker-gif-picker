

# 🎥 Walky Gifs

A lightning-fast, native GIF picker and search tool built directly inside the **Walker Launcher** ecosystem using the **Elephant** backend.

**Perfect for Hyprland & Sway environments.** Instantly find GIFs, preview them live, and paste them perfectly into Element, Discord, or WhatsApp Web—*without saving files to your disk*, and *without crashing your clipboard history*.

<br>
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2da8fcac-1900-4b9f-b060-5f7fba6d9abe" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/7496550e-4b99-48cf-ac05-33c605f72b6b" />




</div>

## ✨ Features
- **Smooth GUI Rendering:** Smooth native preview pane right inside Walker launcher.
- **In-Memory Clipboard Fetching:** Fetches the GIF directly to your clipboard memory—does not litter your `Downloads/` directory!
- **Universal App Support:** Converts animated GIFs dynamically into static `image/png` payloads upon exit. This provides flawless, instantaneous image pasting into apps like **Element (Matrix)** or **WhatsApp Web** without causing clipboard manager crashes.
- **Powered by Klipy:** Native super-fast GIF API.

---

## 🛠️ Prerequisites
Ensure your environment has the following installed:

*   **[Walker](https://github.com/abenz1267/walker)**: The application launcher.
*   **[Elephant](https://github.com/abenz1267/elephant)**: The backend data provider for Walker.

*(Note: Additional dependencies like `wl-clipboard`, `jq`, `curl`, `python3`, `requests`, and `Pillow` are automatically handled by the `install.sh` script).*

---

## 🚀 Installation & Setup Step-by-Step

### 1. Run the Installer 💻
Clone this repository and run the automated installation script. It will automatically install packages (via `apt`, `pacman`, or `dnf`), safely move files to your configuration folders, and set correct permissions:

```bash
cd walker-gif-picker
./install.sh
```

### 2. Get Your API Key 🔑
This script relies on the [Klipy API](https://klipy.co) (or any similar GIF API you prefer to mod it for). 
1. Go to the [Klipy Developer Portal](https://developers.klipy.co/).
2. Sign up and generate a free API Key.
3. Open the installed search script located at (`~/.config/walker/scripts/gif_search.sh`) and replace the placeholder `YOUR_API_KEY_HERE` with your newly acquired key:
   ```bash
   API_KEY="YOUR_API_KEY_HERE"
   ```

### 3. Configure Walker ⚙️
Open your Walker configuration file (`~/.config/walker/config.toml`) and add the following block so Walker knows how to launch the Elephant menu.

```toml
[[providers.prefixes]]
prefix = "gif"
provider = "menus:gifs"
```

Also, verify that the `default` action trigger allows you to hit "Return" on a menu selection:
```toml
[providers.actions]
fallback = [
  { action = "menus:default", label = "run", default = true, bind = "Return", after = "Close" },
]
```

### 4. Apply Changes 🔄
Restart your Elephant provider and Walker daemon to pick up the new Lua menus and logic:

```bash
pkill elephant; sleep 1; elephant &
pkill walker; sleep 1; walker --gapplication-service &
```

---

## 🎮 How to Use

1. Launch Walker and type `gif ` followed by your search query (e.g. `gif cat`).
   *(Alternatively, bind a specific hotkey in your Hyprland config to launch directly into the GIF menu: `bind = SUPER, G, exec, walker -m menus:gifs`)*
2. Scroll through the options and check out the auto-cached live previews in the right pane.
3. Press **Enter**.
4. You will instantly get a notification saying "Image Copied!".
5. Go to Element, Discord, or WhatsApp Web and press `Ctrl+V` to paste the image directly!

---

## 🐛 Troubleshooting

*   **Elephant Crashes:** Ensure you are using the provided Python `gif-copy` script exactly as is. Attempting to use `wl-copy -t image/gif` instead of our `image/png` Pillow conversion **will crash** Elephant's built-in clipboard history provider due to a known bug in Elephant with `.gif` caching.
*   **Nothing Pastes:** Make sure Python's `Pillow` library is installed (`python3 -m pip install Pillow`).
*   **No Results in Walker:** Check your Klipy API Key validity in the shell script.
