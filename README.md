# <div align="center">Clip</div>

<div align="center">
<strong>100% Native macOS Clipboard Manager</strong>
</div>

<br />

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.0+-F05138?style=for-the-badge&logo=swift&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-Tahoe-000000?style=for-the-badge&logo=apple&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-15+-1575F9?style=for-the-badge&logo=xcode&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

<br />

> **"The clipboard manager Apple forgot to ship."**
>
> Clip isn't just another utility; it's a native extension of your Mac.  
> Built with SwiftUI and AppKit, it respects every system behavior, animation, and guideline.

</div>

---

## 🌟 Vision

Clip's mission is to be:

- **Invisible yet omnipresent** — Launches silently, stays out of your way.
- **Indistinguishable from macOS** — Uses native materials, fonts, and interactions.
- **Lightweight & Efficient** — Zero polling loops, extremely low memory footprint.

---

## ✨ Features

### Smart Clipboard Engine
- **Intelligent Monitoring** — Efficiently tracks `NSPasteboard` without draining battery.
- **Smart Detection** — Automatically categorizes copied content:
  - **Links**: URLs are detected instantly.
  - **Code**: Snippets are identified and syntax-highlighted (in future updates).
  - **Text**: Standard text is preserved with formatting.
- **Privacy First** — All data is stored locally using sandboxed persistence.

### Dual Mode Interface

#### 1. Menu Bar Experience
- **Quick Access** — One click to see recent history.
- **Transient Popover** — Opens instantly, closes when you click away.
- **Keyboard Navigation** — Built for speed.

#### 2. Full Application Window
- **Deep Browsing** — Search, filter, and organize your entire history.
- **Categorization** — Filter by Text, Links, or Code.
- **Detail View** — Full-width preview for long content.

---

## 🎨 Apple-Inspired Design

- **SF Pro Typography**  
  Uses the system font stack for perfect legibility.

- **Vibrant Materials**  
  Uses `NSVisualEffectView` materials (popover, sidebar, behind-window) to match macOS aesthetics.

- **Adaptive Colors**  
  Looks perfect in both Light and Dark modes.

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
- **AppKit** — For precise window management, `NSStatusItem`, and `NSPopover`.
- **Combine** — Reactive updates from the Clipboard Engine.
- **NSDataDetector** — For robust content type analysis.

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
