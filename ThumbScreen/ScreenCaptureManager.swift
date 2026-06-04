import ScreenCaptureKit
import CoreMedia
import CoreVideo

final class ScreenCaptureManager: NSObject, SCStreamOutput, SCStreamDelegate {

    private let onFrame: (CGImage) -> Void
    private var stream: SCStream?

    init(onFrame: @escaping (CGImage) -> Void) {
        self.onFrame = onFrame
    }

    func start() {
        Task { await startCapture() }
    }

    func stop() {
        Task {
            try? await stream?.stopCapture()
            stream = nil
        }
    }

    // Applique les nouveaux réglages (FPS, curseur) sans redémarrer le stream.
    func applySettings() {
        guard let stream else { return }
        Task {
            try? await stream.updateConfiguration(buildConfig())
        }
    }

    // MARK: - Private

    private func startCapture() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(
                false, onScreenWindowsOnly: true
            )
            guard let display = content.displays.first else { return }

            let filter = SCContentFilter(display: display, excludingWindows: [])
            stream = SCStream(filter: filter, configuration: buildConfig(), delegate: self)
            try stream?.addStreamOutput(
                self, type: .screen, sampleHandlerQueue: .global(qos: .userInitiated)
            )
            try await stream?.startCapture()
        } catch {
            print("[ThumbScreen] SCStream start error: \(error)")
        }
    }

    private func buildConfig() -> SCStreamConfiguration {
        let fps = UserDefaults.standard.integer(forKey: "fps")

        let config = SCStreamConfiguration()
        config.width  = 2170   // résolution physique Touch Bar (@2x)
        config.height = 60
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.colorSpaceName = CGColorSpace.sRGB
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(fps > 0 ? fps : 10))
        config.queueDepth = 3
        config.showsCursor = UserDefaults.standard.bool(forKey: "showCursor")
        return config
    }

    // MARK: - SCStreamOutput

    func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard type == .screen,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width       = CVPixelBufferGetWidth(pixelBuffer)
        let height      = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        guard let baseAddr = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }

        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
                       | CGImageAlphaInfo.premultipliedFirst.rawValue
        guard let ctx = CGContext(
            data: baseAddr,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ), let cgImage = ctx.makeImage() else { return }

        onFrame(cgImage)
    }

    // MARK: - SCStreamDelegate

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("[ThumbScreen] SCStream stopped: \(error)")
    }
}
