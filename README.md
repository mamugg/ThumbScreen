# ThumbScreen

**Your entire Mac screen, live, squeezed into the Touch Bar.**

ThumbScreen is a tiny macOS menu bar app that mirrors your primary display in real-time directly in the MacBook Pro Touch Bar. It runs silently in the background and stays visible no matter which app is in front.

---

## How it looks

```
┌──────────────────────────────────────────────────────────────────────┐
│  [your whole screen, live, at 10fps, in 30 pixels of height]        │
└──────────────────────────────────────────────────────────────────────┘
       ↑ Touch Bar (2170 × 60 px physical)
```

Yes, it's absurdly wide and comically short. That's the point.

---

## Features

- **Full-width mirror** — spans the entire Touch Bar, not just the Control Strip
- **Live capture** — uses ScreenCaptureKit for low-latency streaming
- **Persistent** — stays on the Touch Bar regardless of the active app (Control Strip injection via `DFRFoundation`)
- **Configurable** — FPS, cursor visibility, launch at login, all from a clean Settings window (`⌘,`)
- **Lightweight** — no window, no Dock icon, just a tiny menu bar icon

---

## Requirements

| | |
|---|---|
| **macOS** | 13 Ventura or later |
| **Hardware** | MacBook Pro with a physical Touch Bar (2016–2021) |
| **Permission** | Screen Recording (prompted on first launch) |
| **Xcode** | 15+ to build |

---

## Build & Run

```bash
git clone https://github.com/mamuggeo/ThumbScreen.git
cd ThumbScreen
open ThumbScreen.xcodeproj
```

1. In Xcode, go to **Signing & Capabilities** and select your Team (a free Apple ID works)
2. Hit **⌘R** to build and run

> The app must be code-signed for macOS to grant Screen Recording permission. A free Apple Developer account is enough — no paid membership required.

---

## First launch

On first run, macOS will prompt for **Screen Recording** access. Grant it in:

**System Settings → Privacy & Security → Screen Recording**

If the dialog never appeared, click the menu bar icon (look for `⧉`) and choose **"Autoriser la capture d'écran…"**.

---

## Settings

Click the menu bar icon → **Paramètres…** (`⌘,`)

| Setting | What it does |
|---|---|
| **Launch at login** | Registers the app as a login item via `SMAppService` |
| **Frames per second** | 5 / 10 / 15 / 20 fps — higher = smoother, more CPU |
| **Show cursor** | Include or hide the mouse cursor in the mirror |

---

## How it works

| Component | Tech |
|---|---|
| Screen capture | `ScreenCaptureKit` (`SCStream`) |
| Touch Bar injection | Private `DFRFoundation.framework` via `dlopen` + `dlsym` |
| Persistence | `NSTouchBar.presentSystemModalTouchBar(_:systemTrayItemIdentifier:)` |
| Capture resolution | 2170 × 60 px (Touch Bar physical @2x) — pixel-perfect rendering |
| Pixel pipeline | `CVPixelBuffer` → `CGContext` (direct, no `CIImage`, avoids color artifacts) |

---

## Limitations

- **Touch Bar only** — requires a Mac with a physical Touch Bar (MBP 2016–2021). Does nothing on other machines.
- **Private APIs** — uses `DFRFoundation`, an undocumented Apple framework. May break on future macOS releases.
- **Not App Store compatible** — sandbox disabled, private framework usage.
- **Aspect ratio** — the screen (~16:10) is squished into a ~36:1 strip. Things will look… flat.

---

## Why

Because why not. It's fun, it's weird, and it actually works.

---

## License

MIT — do whatever you want with it.
