import AppKit
import ServiceManagement

final class SettingsWindowController: NSObject {

    var onSettingsChanged: (() -> Void)?

    private var window: NSWindow?

    // MARK: - Public

    func show() {
        if let w = window, w.isVisible {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let w = buildWindow()
        window = w
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Window

    private func buildWindow() -> NSWindow {
        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 10),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        w.title = "Paramètres — TouchBar Mirror"
        w.contentView = buildContent()
        w.setContentSize(w.contentView!.fittingSize)
        w.center()
        w.isReleasedWhenClosed = false
        return w
    }

    // MARK: - Content

    private func buildContent() -> NSView {
        let root = NSStackView()
        root.orientation = .vertical
        root.alignment = .leading
        root.spacing = 0
        root.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        root.widthAnchor.constraint(equalToConstant: 340).isActive = true

        // --- Démarrage ---
        root.addArrangedSubview(sectionHeader("DÉMARRAGE"))
        root.setCustomSpacing(6, after: root.arrangedSubviews.last!)
        root.addArrangedSubview(row(
            "Lancer au démarrage",
            detail: "Lance l'app automatiquement à l'ouverture de session.",
            control: makeLaunchToggle()
        ))

        root.setCustomSpacing(16, after: root.arrangedSubviews.last!)

        // --- Capture ---
        root.addArrangedSubview(sectionHeader("CAPTURE"))
        root.setCustomSpacing(6, after: root.arrangedSubviews.last!)
        root.addArrangedSubview(row(
            "Images par seconde",
            detail: "Valeurs élevées = plus fluide, plus de CPU.",
            control: makeFPSPopup()
        ))
        root.setCustomSpacing(10, after: root.arrangedSubviews.last!)
        root.addArrangedSubview(row(
            "Afficher le curseur",
            detail: "Inclut la position du curseur dans le miroir.",
            control: makeCursorToggle()
        ))

        root.setCustomSpacing(20, after: root.arrangedSubviews.last!)

        // --- Séparateur ---
        let sep = NSBox(); sep.boxType = .separator
        root.addArrangedSubview(sep)
        root.setCustomSpacing(16, after: sep)

        // --- Quitter ---
        let quit = NSButton(
            title: "Quitter l'application",
            target: NSApp,
            action: #selector(NSApplication.terminate(_:))
        )
        quit.bezelStyle = .rounded
        root.addArrangedSubview(quit)

        return root
    }

    // MARK: - Rows

    private func sectionHeader(_ text: String) -> NSTextField {
        let f = NSTextField(labelWithString: text)
        f.font = .boldSystemFont(ofSize: 10)
        f.textColor = .secondaryLabelColor
        return f
    }

    private func row(_ title: String, detail: String, control: NSView) -> NSView {
        let titleField = NSTextField(labelWithString: title)
        titleField.font = .systemFont(ofSize: NSFont.systemFontSize)

        let detailField = NSTextField(labelWithString: detail)
        detailField.font = .systemFont(ofSize: 11)
        detailField.textColor = .secondaryLabelColor

        let labels = NSStackView(views: [titleField, detailField])
        labels.orientation = .vertical
        labels.alignment = .leading
        labels.spacing = 2
        labels.setContentHuggingPriority(.defaultLow, for: .horizontal)

        control.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        control.setContentCompressionResistancePriority(.required, for: .horizontal)

        let r = NSStackView(views: [labels, control])
        r.orientation = .horizontal
        r.distribution = .equalSpacing
        r.alignment = .centerY
        r.spacing = 12
        r.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return r
    }

    // MARK: - Controls

    private func makeLaunchToggle() -> NSSwitch {
        let s = NSSwitch()
        s.state = SMAppService.mainApp.status == .enabled ? .on : .off
        s.target = self; s.action = #selector(didToggleLaunch(_:))
        return s
    }

    private func makeFPSPopup() -> NSPopUpButton {
        let p = NSPopUpButton()
        p.addItems(withTitles: ["5 fps", "10 fps", "15 fps", "20 fps"])
        let stored = UserDefaults.standard.integer(forKey: "fps")
        p.selectItem(at: [5, 10, 15, 20].firstIndex(of: stored > 0 ? stored : 10) ?? 1)
        p.target = self; p.action = #selector(didChangeFPS(_:))
        return p
    }

    private func makeCursorToggle() -> NSSwitch {
        let s = NSSwitch()
        s.state = UserDefaults.standard.bool(forKey: "showCursor") ? .on : .off
        s.target = self; s.action = #selector(didToggleCursor(_:))
        return s
    }

    // MARK: - Actions

    @objc private func didToggleLaunch(_ sender: NSSwitch) {
        do {
            if sender.state == .on { try SMAppService.mainApp.register() }
            else                   { try SMAppService.mainApp.unregister() }
        } catch {
            print("[ThumbScreen] SMAppService: \(error)")
            sender.state = sender.state == .on ? .off : .on
        }
    }

    @objc private func didChangeFPS(_ sender: NSPopUpButton) {
        UserDefaults.standard.set([5, 10, 15, 20][sender.indexOfSelectedItem], forKey: "fps")
        onSettingsChanged?()
    }

    @objc private func didToggleCursor(_ sender: NSSwitch) {
        UserDefaults.standard.set(sender.state == .on, forKey: "showCursor")
        onSettingsChanged?()
    }
}
