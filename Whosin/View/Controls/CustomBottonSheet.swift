import UIKit

class CustomBottomSheet: UIPresentationController {

        private var panGestureRecognizer: UIPanGestureRecognizer!
        private var dimmingView: UIView!

        override func presentationTransitionWillBegin() {
            super.presentationTransitionWillBegin()
            self.dimmingView.shadowColor = ColorBrand.brandgradientPink
            dimmingView = UIView(frame: containerView!.bounds)
            dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
            dimmingView.alpha = 0
            containerView!.insertSubview(dimmingView, at: 0)

            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
                self?.dimmingView.alpha = 1
            }, completion: nil)
        }

        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
                self?.dimmingView.alpha = 0
            }, completion: nil)
        }

    }
