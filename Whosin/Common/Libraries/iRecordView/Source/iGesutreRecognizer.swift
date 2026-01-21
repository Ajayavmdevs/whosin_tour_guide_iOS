import UIKit
/**
 This class design and implemented to create custom class of `UIGestureRecognizer`
 
 #Super Class
 UIGestureRecognizer
 */
class IGesutreRecognizer: UIGestureRecognizer {

    /// Tells this object that one or more new touches occurred in a view or window.
    /// - Parameters:
    ///   - touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's isMultipleTouchEnabled property to true.
    ///   - event: The event to which the touches belong.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard state != .began else {
            return
        }
        state = .began
    }

    /// Tells the responder when one or more fingers are raised from a view or window.
    /// - Parameters:
    ///   - touches: A set of UITouch instances that represent the touches for the ending phase of the event represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's isMultipleTouchEnabled property to true.
    ///   - event:The event to which the touches belong.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }
    
    /// Tells the responder when a system event (such as a system alert) cancels a touch sequence.
    /// - Parameters:
    ///   - touches: A set of UITouch instances that represent the touches for the ending phase of the event represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's isMultipleTouchEnabled property to true.
    ///   - event: The event to which the touches belong.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}
