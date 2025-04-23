Poniżej pełny, sprawdzony plik README.md, który możesz skopiować w całości — nie powinien już „rozjeżdżać się” na GitHubie. Zwróć uwagę na poprawne otwarcie i zamknięcie bloków kodu.

# OpenconnectGUI

![macOS](https://img.shields.io/badge/platform-macOS-blue)

**OpenconnectGUI** is a native macOS frontend for [openconnect](https://www.infradead.org/openconnect/), built in SwiftUI.  
It lets you manage multiple VPN profiles, securely store credentials in macOS Keychain, and connect via `sudo` using a simple GUI.

---

## ✨ Features

- Manage multiple VPN configurations  
- One-click connection using `sudo openconnect`  
- Support for `gp`, `anyconnect`, `pulse`, and other protocols  
- Store VPN and sudo credentials securely in macOS Keychain  
- Real-time logs and connection status indicator  
- Clean and modern SwiftUI interface for macOS  

---

## 📦 Installation

1. Download the latest `.app` from the [Releases](https://github.com/AshenMJ/OpenconnectGUI/releases)  
2. Move it to your `/Applications` folder  
3. If macOS blocks it:
   - Right-click the app → **Open** → Confirm  
   - Or remove quarantine attribute via Terminal:
     ```bash
     xattr -d com.apple.quarantine /Applications/OpenconnectGUI.app
     ```

---

## 🔧 Requirements

- macOS 12.0 or newer (tested on macOS Sequoia)  
- `openconnect` installed via [Homebrew](https://brew.sh/):
  ```bash
  brew install openconnect

🔒 Optional:
To allow openconnect to run without prompting for a sudo password, add this line to your sudoers file (sudo visudo):

your_username ALL=(ALL) NOPASSWD: /opt/homebrew/bin/openconnect



⸻

🔐 Security & Credentials
	•	VPN and sudo passwords can be saved in the macOS Keychain
	•	All data is stored locally and never transmitted
	•	The app does not collect telemetry or send data elsewhere

⸻

🧑‍💻 Development

Build from source:

git clone https://github.com/AshenMJ/OpenconnectGUI.git
cd OpenconnectGUI
open OpenconnectGUI.xcodeproj

Then in Xcode:
	•	Select the macOS target
	•	Run with Cmd + R

⚠️ Ensure App Sandbox is disabled to allow launching openconnect with sudo.

⸻

📃 License

This project is licensed under the MIT License. See LICENSE for details.

⸻

⚠️ Disclaimer

This project is not affiliated with the official OpenConnect project or Cisco.
Use at your own risk—make sure you comply with your organization’s VPN policies.
