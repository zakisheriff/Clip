# <div align="center">Clip</div>

<div align="center">
<strong>100% Native macOS Clipboard Manager.</strong>
</div>

<br />

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.0+-F05138?style=for-the-badge&logo=swift&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-Tahoe-000000?style=for-the-badge&logo=apple&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-15+-1575F9?style=for-the-badge&logo=xcode&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

<br />
<br />

</div>

<br />

> **"The clipboard manager Apple forgot to ship."**
>
> Clip isn't just another utility; it's a native extension of your Mac.  
> Built with SwiftUI and AppKit, it respects every system behavior, animation, and guideline.

---

## 🌟 Vision

Clip's mission is to be:

- **Invisible yet omnipresent** — Launches silently, stays out of your way.
- **Indistinguishable from macOS** — Uses native materials, fonts, and interactions.
- **Lightweight & Efficient** — Zero polling loops, extremely low memory footprint.

---

## ✨ Features

- **Dual Mode Interface**  
  - **Menu Bar**: Quick access popover for transient interactions.
  - **Full Window**: Deep browsing, categorization, and management.

- **Smart Clipboard Engine**  
  - Monitors `NSPasteboard` changes efficiently.
  - Automatically identifies Text, Links, and Code snippets.
  - Ignores duplicates and trims history automatically.

- **Native Design**  
  - SF Pro typography.
  - Vibrancy and blur materials matching macOS.
  - Full Dark Mode support.

---

## 🎨 Design Philosophy

- **No Electron**  
  Built strictly with Swift. 10MB app size vs 200MB+.

- **No Custom UIs**  
  If a native control exists, we use it. This ensures future-proofing and accessibility.

- **Apple Silicon First**  
  Optimized for M-series chips for instant launch and zero lag.

---

## 📁 Project Structure

```
Clip/
├── App/                          # Application Lifecycle
│   ├── AppDelegate.swift         # NSStatusItem & Popover logic
│   └── ClipApp.swift             # Entry point
├── Model/                        # Core Data Structures
│   └── ClipboardItem.swift       # The atomic unit of history
├── Engine/                       # Business Logic
│   ├── ClipboardEngine.swift     # NSPasteboard monitoring
│   └── Persistence.swift         # UserDefaults storage
└── UI/                           # SwiftUI Views
    ├── MenuBar/                  # Transient Popover
    ├── Main/                     # Full Window Interface
    ├── Settings/                 # Preferences Panel
    └── Shared/                   # Reusable Components
```

---

## 🚀 Quick Start

### Prerequisites

- **macOS 13+** (Ventura or later)
- **Xcode 14+**

### 1. Clone the Repository

```bash
git clone https://github.com/zakisheriff/Clip.git
cd Clip
```

### 2. Build

1. Open `Clip.xcodeproj`.
2. Ensure the Scheme is set to **Clip**.
3. Press **Cmd + R**.

---

## 🔧 Tech Stack

- **Swift** — Core language.
- **SwiftUI** — 95% of the UI (NavigationSplitView, Lists).
- **AppKit** — For precise window management, NSStatusItem, and NSPopover.
- **Combine** — Reactive updates from the Clipboard Engine.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

MIT License — 100% Free and Open Source

---

<p align="center">
Made by <strong>Zaki Sheriff</strong>
</p>
