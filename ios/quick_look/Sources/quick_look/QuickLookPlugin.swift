import Flutter
import QuickLook
import UIKit

@MainActor
public class QuickLookPlugin: NSObject, FlutterPlugin, QuickLookApi {
    private weak var registrar: FlutterPluginRegistrar?
    private var activePreview: QuickLookPreviewController?

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    public nonisolated static func register(with registrar: FlutterPluginRegistrar) {
        // Flutter invokes registration and teardown on the platform (main) thread.
        MainActor.assumeIsolated {
            let instance = QuickLookPlugin(registrar: registrar)
            QuickLookApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
            registrar.publish(instance)
        }
    }

    func openURL(url: String, isDismissable: Bool) async throws -> Bool {
        try await openURLs(resourceURLs: [url], initialIndex: 0, isDismissable: isDismissable)
    }

    func openURLs(resourceURLs: [String], initialIndex: Int64, isDismissable: Bool) async throws -> Bool {
        guard activePreview == nil,
              !resourceURLs.isEmpty,
              initialIndex >= 0, initialIndex < resourceURLs.count else { return false }

        let urls = resourceURLs.compactMap(Self.previewURL)
        guard urls.count == resourceURLs.count,
              urls.allSatisfy({ QLPreviewController.canPreview($0 as NSURL) }),
              let presenter = presentingViewController() else { return false }

        return await withCheckedContinuation { continuation in
            let preview = QuickLookPreviewController(
                urls: urls,
                initialIndex: Int(initialIndex),
                isDismissable: isDismissable
            ) { [weak self] result in
                self?.activePreview = nil
                continuation.resume(returning: result)
            }
            activePreview = preview
            presenter.present(preview, animated: true)
            preview.presentationController?.delegate = preview
        }
    }

    func canOpenURL(url: String) async throws -> Bool {
        guard let fileURL = Self.previewURL(url) else { return false }
        return QLPreviewController.canPreview(fileURL as NSURL)
    }

    // Treat the argument as a path so spaces, Unicode, %, #, and ? stay literal.
    static func previewURL(_ path: String) -> URL? {
        guard path.hasPrefix("/"), !path.contains("\0") else { return nil }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory),
              !isDirectory.boolValue,
              FileManager.default.isReadableFile(atPath: path) else { return nil }
        return URL(fileURLWithPath: path)
    }

    private func presentingViewController() -> UIViewController? {
        // The registrar identifies this engine's scene, even with multiple windows.
        guard var controller = registrar?.viewController,
              let window = controller.viewIfLoaded?.window else { return nil }
        if let scene = window.windowScene, scene.activationState != .foregroundActive {
            return nil
        }
        while let presented = controller.presentedViewController {
            guard !controller.isBeingDismissed, !controller.isBeingPresented else { return nil }
            controller = presented
        }
        guard !controller.isBeingDismissed, !controller.isBeingPresented,
              controller.viewIfLoaded?.window != nil else { return nil }
        return controller
    }

    public nonisolated func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        MainActor.assumeIsolated {
            QuickLookApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
            let preview = activePreview
            preview?.finish(false)
            preview?.dismiss(animated: false)
            self.registrar = nil
        }
    }
}

final class QuickLookPreviewController: QLPreviewController,
    QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    private let urls: [URL]
    private var completion: ((Bool) -> Void)?

    init(urls: [URL], initialIndex: Int, isDismissable: Bool, completion: @escaping (Bool) -> Void) {
        self.urls = urls
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        dataSource = self
        delegate = self
        currentPreviewItemIndex = initialIndex
        isModalInPresentation = !isDismissable
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { urls.count }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        urls[index] as NSURL
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) { finish(true) }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) { finish(true) }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Also handle programmatic dismissal by the host. A share sheet or other
        // temporary covering controller must not complete the preview's future.
        if isBeingDismissed || presentingViewController == nil {
            finish(true)
        }
    }

    func finish(_ result: Bool) {
        let callback = completion
        completion = nil
        callback?(result)
    }
}
