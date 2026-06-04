# ThumbScreen

**Your entire Mac screen, live, squeezed into the Touch Bar.**

ThumbScreen is a tiny macOS menu bar app that mirrors your primary display in real-time directly in the MacBook Pro Touch Bar. It runs silently in the background and stays visible no matter which app is in front.

---

## Download

Head to the [**Releases page**](https://github.com/mamugg/ThumbScreen/releases/latest), grab `ThumbScreen-v1.0.zip`, unzip it, and drag **ThumbScreen.app** into your `/Applications` folder.

---

## First launch — important

Because ThumbScreen is not notarized by Apple, macOS will block it on the first open. **Do not double-click.** Instead:

1. **Right-click** `ThumbScreen.app` in Finder
2. Select **Open**
3. Click **Open** again in the security dialog

You only need to do this once. After that, the app opens normally.

Then, when prompted, grant **Screen Recording** permission:

**System Settings → Privacy & Security → Screen Recording → enable ThumbScreen**

If the permission prompt never appeared, click the menu bar icon and choose **Allow Screen Recording…**

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

---

## Build from source

```bash
git clone https://github.com/mamugg/ThumbScreen.git
cd ThumbScreen
open ThumbScreen.xcodeproj
```

1. In Xcode, go to **Signing & Capabilities** and select your Team (a free Apple ID works)
2. Hit **⌘R** to build and run

> The app must be code-signed for macOS to grant Screen Recording permission. A free Apple Developer account is enough — no paid membership required.

---

## Settings

Click the menu bar icon → **Settings…** (`⌘,`)

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

## License

MIT — do whatever you want with it.
