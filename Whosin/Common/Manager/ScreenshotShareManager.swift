import UIKit

import UIKit

final class ScreenshotShareManager {

    static let shared = ScreenshotShareManager()

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

    @objc private func userDidTakeScreenshot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let screenshot = self.captureScreenshot(),
                  let topVC = UIApplication.topMostViewController() else { return }

            let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = topVC.view
            topVC.present(activityVC, animated: true)
        }
    }

    private func captureScreenshot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return nil }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { context in
            window.layer.render(in: context.cgContext)
        }
    }
}


extension UIApplication {
    static func topMostViewController(
        base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }

    var keyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: \.isKeyWindow) }
            .first
    }
}
