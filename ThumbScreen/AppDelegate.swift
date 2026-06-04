import AppKit
import ScreenCaptureKit

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var touchBarController: TouchBarController!
    private var screenCaptureManager: ScreenCaptureManager!
    private var settingsController: SettingsWindowController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()

        touchBarController = TouchBarController()
        touchBarController.setup()

        screenCaptureManager = ScreenCaptureManager { [weak self] image in
            self?.touchBarController.updateImage(image)
        }

        settingsController = SettingsWindowController()
        settingsController.onSettingsChanged = { [weak self] in
            self?.screenCaptureManager.applySettings()
        }

        requestCapturePermission()
    }

    // MARK: - Status item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "rectangle.on.rectangle",
            accessibilityDescription: "TouchBar Mirror"
        )

        let menu = NSMenu()

        menu.addItem(NSMenuItem(
            title: "Paramètres…",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))

        let permItem = NSMenuItem(
            title: "Autoriser la capture d'écran…",
            action: #selector(openScreenCapturePrefs),
            keyEquivalent: ""
        )
        permItem.tag = 100
        menu.addItem(permItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quitter",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
    }

    // MARK: - Permissions

    private func requestCapturePermission() {
        Task { @MainActor in
            do {
                try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                setPermissionItemVisible(false)
                screenCaptureManager.start()
            } catch {
                setPermissionItemVisible(true)
            }
        }
    }

    @MainActor
    private func setPermissionItemVisible(_ visible: Bool) {
        statusItem.menu?.item(withTag: 100)?.isHidden = !visible
    }

    // MARK: - Actions

    @objc private func openSettings() {
        settingsController.show()
    }

    @objc private func openScreenCapturePrefs() {
        NSWorkspace.shared.open(
            URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        screenCaptureManager.stop()
    }
}
