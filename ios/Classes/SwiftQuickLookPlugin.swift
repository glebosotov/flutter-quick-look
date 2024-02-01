import Flutter
import QuickLook
import UIKit

public class SwiftQuickLookPlugin: NSObject, FlutterPlugin, QLQuickLookApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger: FlutterBinaryMessenger = registrar.messenger()
        let api: QLQuickLookApi & NSObjectProtocol = SwiftQuickLookPlugin()
        SetUpQLQuickLookApi(messenger, api)
    }

    public func openURLUrl(
        _ url: String,
        completion: @escaping (NSNumber?, FlutterError?) -> Void
    ) {
        if let rootViewController = topViewController() {
            let quickLookVC = QuickLookViewController([url], 0, completion)
            rootViewController.present(quickLookVC, animated: true)
        } else {
            completion(false, nil)
        }
    }

    public func openURLsResourceURLs(
        _ resourceURLs: [String],
        initialIndex: Int,
        completion: @escaping (NSNumber?, FlutterError?) -> Void
    ) {
        if let rootViewController = topViewController() {
            let quickLookVC = QuickLookViewController(
                resourceURLs,
                initialIndex,
                completion
            )
            rootViewController.present(quickLookVC, animated: true)
        } else {
            completion(false, nil)
        }
    }

    private func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

class QuickLookViewController: UIViewController, QLPreviewControllerDataSource {
    var urlsOfResources: [String]
    var shownResource: Bool = false
    var initialIndex: Int
    var result: (NSNumber?, FlutterError?) -> Void

    init(
        _ resourceURLs: [String],
        _ initialIndex: Int,
        _ result: @escaping (NSNumber?, FlutterError?) -> Void
    ) {
        let urls = resourceURLs.map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
        urlsOfResources = urls.map { "file://\($0)" }
        self.result = result
        self.initialIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        if !shownResource {
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.currentPreviewItemIndex = initialIndex
            present(previewController, animated: true)
            shownResource = true
        } else {
            dismiss(animated: true, completion: { self.result(true, nil) })
        }
    }

    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return urlsOfResources.count
    }

    func previewController(
        _: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        let url = URL(string: urlsOfResources[index])!
        return url as QLPreviewItem
    }
}
