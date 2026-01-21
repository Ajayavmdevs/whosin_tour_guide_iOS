import Foundation
import UIKit

class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {

    private var _navigationController: UINavigationController

    init(controller: UINavigationController) {
        self._navigationController = controller
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return _navigationController.viewControllers.count > 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
