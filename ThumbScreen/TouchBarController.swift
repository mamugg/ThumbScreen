import AppKit

private let kStripID  = NSTouchBarItem.Identifier("com.mamuggeo.ThumbScreen.strip")
private let kMirrorID = NSTouchBarItem.Identifier("com.mamuggeo.ThumbScreen.mirror")

// Sous-classe pour imposer une taille fixe — le système Touch Bar lit intrinsicContentSize
// pour dimensionner le conteneur de l'item.
private final class MirrorImageView: NSImageView {
    override var intrinsicContentSize: NSSize { NSSize(width: 1085, height: 30) }
}

final class TouchBarController: NSObject, NSTouchBarDelegate {

    private var imageView: MirrorImageView!
    private var mirrorItem: NSCustomTouchBarItem!
    private var modalBar: NSTouchBar!

    func setup() {
        imageView = MirrorImageView(frame: NSRect(x: 0, y: 0, width: 1085, height: 30))
        imageView.imageScaling = .scaleAxesIndependently
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = NSColor.black.cgColor

        mirrorItem = NSCustomTouchBarItem(identifier: kMirrorID)
        mirrorItem.view = imageView

        // Item fantôme dans le Control Strip — sert d'ancrage à presentSystemModalTouchBar
        let stripItem = NSCustomTouchBarItem(identifier: kStripID)
        let phantom = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 30))
        phantom.wantsLayer = true
        phantom.layer?.backgroundColor = NSColor.clear.cgColor
        stripItem.view = phantom

        NSTouchBarItem.addSystemTrayItem(stripItem)
        DFRElementSetControlStripPresenceForIdentifier(kStripID.rawValue, true)

        // Pas de bouton de fermeture
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)

        // Touch Bar modale pleine largeur, persistante
        modalBar = NSTouchBar()
        modalBar.delegate = self
        modalBar.defaultItemIdentifiers = [kMirrorID]

        NSTouchBar.presentSystemModalTouchBar(modalBar, systemTrayItemIdentifier: kStripID)
    }

    // MARK: - NSTouchBarDelegate

    func touchBar(_ touchBar: NSTouchBar,
                  makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        guard identifier == kMirrorID else { return nil }
        return mirrorItem
    }

    // MARK: - Frame update

    func updateImage(_ image: CGImage) {
        // Déclare explicitement la taille logique (1085×30 pt) pour que NSImage
        // traite les 2170×60 px comme une image @2x → rendu pixel-perfect sur la Touch Bar.
        let nsImage = NSImage(cgImage: image, size: NSSize(width: 1085, height: 30))
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = nsImage
        }
    }
}
