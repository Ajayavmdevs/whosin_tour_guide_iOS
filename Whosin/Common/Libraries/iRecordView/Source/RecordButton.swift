import UIKit

/**
 This Class design and implemented to Record Voice note with animation
 
 #Super Class
 UIButton
 
 #Protocol
 UIGestureRecognizerDelegate
 */
open class RecordButton: UIButton, UIGestureRecognizerDelegate {

    /// Record view
    public var recordView: RecordView?
    /// Transform
    private var mTransform: CGAffineTransform?
    /// Button center
    private var buttonCenter: CGPoint?
    /// Slider center
    private var slideCenter: CGPoint?
    /// Touch down and up gesture
    private var touchDownAndUpGesture: IGesutreRecognizer?
    /// Move gesture
    private var moveGesture: UIPanGestureRecognizer?

    /// Listen for record(true/false)
    public var listenForRecord: Bool? {
        didSet {
            guard let listenForRecord = listenForRecord else { return }
            touchDownAndUpGesture?.isEnabled = listenForRecord
            moveGesture?.isEnabled = listenForRecord
        }
    }
    
    /// Prevent color change (onClick) when adding the button using Storyboard
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                isHighlighted = false
            }
        }
    }

    /// Setup ui
    private func setup() {
        setTitle("", for: .normal)
        if image(for: .normal) == nil {
            let image = UIImage.fromPod("mic_blue").withRenderingMode(.alwaysTemplate)
            setImage(image, for: .normal)
            
            tintColor = .blue
        }
        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(touchMoved(_:)))
        moveGesture.delegate = self
        self.moveGesture = moveGesture
        let touchDownAndUpGesture = IGesutreRecognizer(target: self, action: #selector(handleUpAndDown(_:)))
        touchDownAndUpGesture.delegate = self
        self.touchDownAndUpGesture = touchDownAndUpGesture
        addGestureRecognizer(moveGesture)
        addGestureRecognizer(touchDownAndUpGesture)
        if mTransform == nil {
            mTransform = transform
        }
    }

    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Returns an object initialized from data in the specified coder object.
    /// - Parameter coder: An unarchiver object.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Touch down method
    @objc private func touchDown() {
        recordView?.onTouchDown(recordButton: self)
    }

    /// Touch down outside method
    @objc private func touchDownOutside() {
        recordView?.onTouchDown(recordButton: self)
    }

    /// Touch up method
    @objc private func touchUp() {
        recordView?.onTouchUp(recordButton: self)
    }

    /// Touch moved method
    /// - Parameter sender: An instance of a subclass of the abstract base class UIPanGestureRecognizer. This is the object sending the message to the delegate.
    @objc private func touchMoved(_ sender: UIPanGestureRecognizer) {
        recordView?.touchMoved(recordButton: self, sender: sender)
    }

    /// Handle up/down event on button
    /// - Parameter sender: An instance of a subclass of the abstract base class UIGestureRecognizer. This is the object sending the message to the delegate.
    @objc private func handleUpAndDown(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            recordView?.onTouchDown(recordButton: self)

        case .ended:
            recordView?.onTouchUp(recordButton: self)
            
        case .cancelled:
            recordView?.onTouchCancelled(recordButton: self)

        default:
            break
        }
    }
    
    /// Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
    /// - Parameters:
    ///   - gestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer. This is the object sending the message to the delegate.
    ///   - otherGestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer.
    /// - Returns: True to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously. The default implementation returns false—no two gestures can be recognized simultaneously.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == touchDownAndUpGesture && otherGestureRecognizer == moveGesture) || (gestureRecognizer == moveGesture && otherGestureRecognizer == touchDownAndUpGesture)
    }
}
/**
 Record button extension
 */
extension RecordButton {
   /// Layout subviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        superview?.bringSubviewToFront(self)
    }
}
