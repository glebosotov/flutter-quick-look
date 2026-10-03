import Flutter
import QuickLook
import UIKit
import XCTest
@testable import quick_look

@MainActor
final class QuickLookTests: XCTestCase {
    func testLiteralFilePathsAndInvalidFiles() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("Пример #100% ? document.pdf")
        try Data("example".utf8).write(to: file)
        let url = try XCTUnwrap(QuickLookPlugin.previewURL(file.path))
        XCTAssertEqual(url.path, file.path)
        XCTAssertTrue(url.isFileURL)
        for invalid in ["", "relative.pdf", file.absoluteString, directory.path, directory.appendingPathComponent("missing.pdf").path, file.path + "\0"] {
            XCTAssertNil(QuickLookPlugin.previewURL(invalid), invalid)
        }
    }

    func testPreviewOrderAndDismissalControl() {
        let urls = [URL(fileURLWithPath: "/tmp/first.pdf"), URL(fileURLWithPath: "/tmp/second.jpg")]
        let preview = QuickLookPreviewController(urls: urls, initialIndex: 1, isDismissable: false) { _ in }
        XCTAssertEqual(preview.numberOfPreviewItems(in: preview), 2)
        XCTAssertEqual(preview.previewController(preview, previewItemAt: 1).previewItemURL, urls[1])
        XCTAssertTrue(preview.isModalInPresentation)
    }

    func testDismissalCompletesExactlyOnce() {
        var results: [Bool] = []
        let preview = QuickLookPreviewController(urls: [], initialIndex: 0, isDismissable: true) { results.append($0) }
        XCTAssertFalse(preview.isModalInPresentation)
        preview.previewControllerDidDismiss(preview)
        preview.presentationControllerDidDismiss(UIPresentationController(presentedViewController: preview, presenting: nil))
        preview.finish(false)
        XCTAssertEqual(results, [true])
    }

    func testCancellationCompletesWithFalseOnlyOnce() {
        var results: [Bool] = []
        let preview = QuickLookPreviewController(urls: [], initialIndex: 0, isDismissable: true) { results.append($0) }
        preview.finish(false)
        preview.previewControllerDidDismiss(preview)
        XCTAssertEqual(results, [false])
    }

    func testNativeValidationAndHeadlessEngine() async throws {
        let engine = FlutterEngine(name: "quick-look-validation")
        let registrar = try XCTUnwrap(engine.registrar(forPlugin: "QuickLookTests"))
        let plugin = QuickLookPlugin(registrar: registrar)
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 100, height: 100))
        try renderer.pdfData { context in context.beginPage() }.write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }

        let supported = try await plugin.canOpenURL(url: file.path)
        XCTAssertTrue(supported)
        let missing = try await plugin.canOpenURL(url: file.path + ".missing")
        XCTAssertFalse(missing)
        let empty = try await plugin.openURLs(resourceURLs: [], initialIndex: 0, isDismissable: true)
        XCTAssertFalse(empty)
        for index: Int64 in [-1, 1, Int64.max] {
            let opened = try await plugin.openURLs(resourceURLs: [file.path], initialIndex: index, isDismissable: true)
            XCTAssertFalse(opened)
        }
        let headless = try await plugin.openURL(url: file.path, isDismissable: true)
        XCTAssertFalse(headless)
    }

    func testInitialIndexAndCoveringPreviewUntilProgrammaticDismissal() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first { $0.isKeyWindow }
        let window = UIWindow(windowScene: scene)
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            previousKeyWindow?.makeKeyAndVisible()
        }

        let file = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 100, height: 100))
        try renderer.pdfData { context in context.beginPage() }.write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }

        let secondFile = file.deletingLastPathComponent().appendingPathComponent("second-" + file.lastPathComponent)
        try FileManager.default.copyItem(at: file, to: secondFile)
        defer { try? FileManager.default.removeItem(at: secondFile) }

        var results: [Bool] = []
        let preview = QuickLookPreviewController(urls: [file, secondFile], initialIndex: 1, isDismissable: true) { results.append($0) }
        await withCheckedContinuation { continuation in
            host.present(preview, animated: false) { continuation.resume() }
        }
        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(preview.currentPreviewItemIndex, 1)

        let covering = UIViewController()
        covering.modalPresentationStyle = .fullScreen
        await withCheckedContinuation { continuation in
            preview.present(covering, animated: false) { continuation.resume() }
        }
        XCTAssertTrue(results.isEmpty, "Temporarily covering Quick Look must not complete the future.")
        await withCheckedContinuation { continuation in
            covering.dismiss(animated: false) { continuation.resume() }
        }
        await withCheckedContinuation { continuation in
            host.dismiss(animated: false) { continuation.resume() }
        }
        XCTAssertEqual(results, [true])
    }
}
