import UIKit


class ContactBaseVC: NavigationBarViewController {
    
    var containerScrollView: UIScrollView?
    var customTableView: CustomTableView? { return nil }
    var childScrollingDownDueToParent = false
    
    override var navigationController: UINavigationController? {
        parent?.navigationController
    }
    
    func didScroll(scrollView: UIScrollView) {
        guard let parentScrollView = containerScrollView, let childScrollView = customTableView else { return }

        let goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        let parentViewMaxContentYOffset = parentScrollView.contentSize.height - parentScrollView.frame.height + 70
        
        if goingUp {
            if scrollView == childScrollView {
                if parentScrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    parentScrollView.contentOffset.y = max(min(parentScrollView.contentOffset.y + childScrollView.contentOffset.y, parentViewMaxContentYOffset), 0)
                    childScrollView.contentOffset.y = 0
                }
            }
        } else {
            if scrollView == childScrollView {
                if childScrollView.contentOffset.y < 0 && parentScrollView.contentOffset.y > 0 {
                    let tmpValue = max(parentScrollView.contentOffset.y - abs(childScrollView.contentOffset.y), 0)
                    parentScrollView.contentOffset.y = tmpValue
                }
            }
            
            if scrollView == parentScrollView {
                if childScrollView.contentOffset.y > 0 && parentScrollView.contentOffset.y < parentViewMaxContentYOffset {
                    childScrollingDownDueToParent = true
                    childScrollView.contentOffset.y = max(childScrollView.contentOffset.y - (parentViewMaxContentYOffset - parentScrollView.contentOffset.y), 0)
                    parentScrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}
