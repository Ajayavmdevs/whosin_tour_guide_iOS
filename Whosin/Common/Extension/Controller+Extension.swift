import Foundation
import UIKit
import PanModal
import FAPanels
import Toast_Swift
import ObjectMapper

extension CAGradientLayer {
    
    enum Point {
        case topRight, topLeft
        case bottomRight, bottomLeft
        case custion(point: CGPoint)
        
        var point: CGPoint {
            switch self {
            case .topRight: return CGPoint(x: 1, y: 0)
            case .topLeft: return CGPoint(x: 0, y: 0)
            case .bottomRight: return CGPoint(x: 1, y: 1)
            case .bottomLeft: return CGPoint(x: 0, y: 1)
            case .custion(let point): return point
            }
        }
    }
    
    convenience init(frame: CGRect, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        self.init()
        self.frame = frame
        self.colors = colors.map { $0.cgColor }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    convenience init(frame: CGRect, colors: [UIColor], startPoint: Point, endPoint: Point) {
        self.init(frame: frame, colors: colors, startPoint: startPoint.point, endPoint: endPoint.point)
    }
    
    func createGradientImage() -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
    
    func presentAsPanModal(controller: UIViewController) {
        if #available(iOS 26.0, *) {
            controller.modalPresentationStyle = .overFullScreen
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            controller.view.addGestureRecognizer(panGesture)
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.presentationController?.delegate = self
            if let presentedController = self.presentedViewController {
                presentedController.present(controller, animated: true, completion: nil)
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        } else if #available(iOS 17.0, *) {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = false
                sheet.preferredCornerRadius = 10
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            controller.modalPresentationStyle = .pageSheet
            controller.modalPresentationCapturesStatusBarAppearance = true
            if let presentedController = self.presentedViewController {
                presentedController.present(controller, animated: true, completion: nil)
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        } else {
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
//            controller.transitioningDelegate = PanModalPresentationDelegate.default
            
            if let presentedController = self.presentedViewController {
                presentedController.present(controller, animated: true, completion: nil)
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended, .cancelled:
            if translation.y > 100 { // threshold for dismiss
                view.window?.rootViewController?.dismiss(animated: true)
            } else {
                // Snap back
                UIView.animate(withDuration: 0.3) {
                    view.transform = .identity
                }
            }
        default:
            break
        }
    }

    
    func showToast(_ msg: String,_ position: ToastPosition = .bottom) {
        self.view.makeToast(msg, duration: 0.5, position: position)
    }
    
    func spinnerView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    func uniqueElementsFrom(array: [String]) -> [String] {
      var set = Set<String>()
      let result = array.filter {
        guard !set.contains($0) else {
          return false
        }
        
        set.insert($0)
        
        return true
      }
      return result
    }
    
    var isPresented: Bool {
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.last == self {
                return false
            } else {
                return true
            }
        } else if let tabBarController = self.tabBarController {
            return tabBarController.presentingViewController is UITabBarController
        } else {
            return presentingViewController != nil
        }
    }

    var isVCPresented: Bool {
        if let index = self.navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

extension String {
    
    func parseToInt() -> Int? {
        return Int(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
    
    func toInt() -> Int {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return .zero
        }
    }

    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
    
    func strikethrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    func roundedValue() -> Double? {
        if let doubleValue = Double(self) {
            return doubleValue.roundedValue()
        }
        return 0.0
    }
    
    func applyingDirhamFont(defaultFont: UIFont) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: self, attributes: [.font: defaultFont])

        if let dRange = self.range(of: "D") {
            let nsRange = NSRange(dRange, in: self)
            attributed.addAttribute(.font, value: FontBrand.dirhamText(size: defaultFont.pointSize), range: nsRange)
        }
        return attributed
    }
    
}

extension Int {
    func strikethrough() -> NSAttributedString {
        let stringValue = "\(self)"
        let attributeString = NSMutableAttributedString(string: stringValue)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
}

extension UICollectionView {
    
    func isCellFullyVisible(cell: VenueGalleryCollectionCell) -> Bool {
        let cellFrame = cell.frame
        let fullyVisibleFrame = bounds.inset(by: contentInset)
        return fullyVisibleFrame.contains(cellFrame)
    }
}

extension Double {
    func roundedValue() -> Double {
        let multiplied = self * 4
        let rounded: Double
        
        if multiplied.truncatingRemainder(dividingBy: 1) == 0.5 {
            rounded = multiplied.rounded(.up)
        } else {
            rounded = multiplied.rounded()
        }
        
        let finalValue = rounded / 4
        
        // Ensures the result has exactly 2 decimal places
        return Double(String(format: "%.2f", finalValue)) ?? finalValue
    }
    
    func formatted() -> Double {
        return Double(String(format: "%.2f", self)) ?? self
    }
    
    func formattedWithoutDecimal() -> Double {
        return Double(String(format: "%.0f", self)) ?? self
    }
    
    func hideFloatingValue() -> String {
        return String(Int(self))
    }
    
    func formattedDecimal() -> String {
        let string = String(format: "%.2f", self)
        if string.hasSuffix(".00") {
            return String(string.dropLast(3))
        } else if string.hasSuffix(".0") {
            return String(string.dropLast(1))
        } else {
            return string
        }
    }
}

extension UIViewController: @retroactive UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    }
}
