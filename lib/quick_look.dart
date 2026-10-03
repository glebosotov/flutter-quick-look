import 'package:quick_look/quick_look_messages.g.dart';

/// Previews local files using Apple's native Quick Look on iOS.
class QuickLook {
  static final QuickLookApi _api = QuickLookApi();

  /// Opens the file at the absolute local path [url].
  ///
  /// Pass a file path, not a `file://` or network URL. The file must remain
  /// readable until the preview closes; documents, cache and temporary files
  /// are all supported.
  ///
  /// Completes with `true` after dismissal, or `false` if the file cannot be
  /// previewed, a preview is already open, or no active presenter is available.
  /// [isDismissable] controls swipe dismissal; the Done button remains available.
  static Future<bool> openURL(String url, {bool isDismissable = true}) async {
    if (!_isFilePath(url)) return false;
    return _api.openURL(url, isDismissable: isDismissable);
  }

  /// Opens [resourceURLs] in a swipeable preview, starting at [initialIndex].
  ///
  /// Each entry must be an absolute local file path. An empty list, an invalid
  /// index, or any file that cannot be previewed returns `false`.
  /// Otherwise the result and dismissal behavior match [openURL].
  static Future<bool> openURLs({
    required List<String> resourceURLs,
    int initialIndex = 0,
    bool isDismissable = true,
  }) async {
    if (resourceURLs.isEmpty ||
        initialIndex < 0 ||
        initialIndex >= resourceURLs.length ||
        !resourceURLs.every(_isFilePath)) {
      return false;
    }
    return _api.openURLs(
      resourceURLs: List<String>.of(resourceURLs),
      initialIndex: initialIndex,
      isDismissable: isDismissable,
    );
  }

  /// Whether Quick Look can preview the readable file at local path [url].
  ///
  /// Supported types depend on the iOS version. This does not guarantee that
  /// every file's contents can be rendered successfully.
  static Future<bool> canOpenURL(String url) async {
    if (!_isFilePath(url)) return false;
    return _api.canOpenURL(url);
  }

  static bool _isFilePath(String path) =>
      path.startsWith('/') && !path.contains('\u0000');
}
