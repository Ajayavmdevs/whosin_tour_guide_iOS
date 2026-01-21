import Foundation
import UIKit

extension UITableViewCell {
    
    func disableSelectEffect() {
        let view = UIView()
        view.backgroundColor = .clear
        selectedBackgroundView = view
    }
}

extension UITableView {

    public var boundsWithoutInset: CGRect {
        var boundsWithoutInset = bounds
        boundsWithoutInset.origin.y += contentInset.top
        boundsWithoutInset.size.height -= contentInset.top + contentInset.bottom
        return boundsWithoutInset
    }

    public func isRowCompletelyVisible(at indexPath: IndexPath) -> Bool {
        let rect = rectForRow(at: indexPath)
        return boundsWithoutInset.contains(rect)
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.windows.first?.rootViewController?.topMostViewController()
    }
}
