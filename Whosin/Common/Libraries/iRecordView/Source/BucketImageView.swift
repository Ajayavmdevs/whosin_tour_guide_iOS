import UIKit

/// Animation finished output delegate
protocol AnimationFinishedDelegate: AnyObject {
    /// Animation finished
    func animationFinished()
}

/**
 This Class design and implemented to create View for delete Voice note Bucket
 
 #Super Class
 UIImageView
 
 #Protocol
 CAAnimationDelegate
 */
class BucketImageView: UIImageView, CAAnimationDelegate {

    /// Mic image view
    var smallMicImage: UIImage = UIImage() {
        didSet {
            micLayer.contents = smallMicImage.cgImage
        }
    }
    /// Bucket layer
    private var bucketLidLayer = CALayer()
    /// Body layer
    private var bucketBodyLayer = CALayer()
    /// Mic layer
    private var micLayer = CALayer()
    // this layer will contain bucketLidLayer + bucketBodyLayer
    /// Bucket container layer
    private var bucketContainerLayer = CALayer()
    /// Animation name
    private let animationNameKey = "animation_name"
    /// Mic up animation name
    private let micUpAnimationName = "mic_up_animation"
    /// Mic down animation name
    private let micDownAnimationName = "mic_down_animation"
    /// Bucket up animation name
    private let bucketUpAnimationName = "bucket_up_animation"
    /// Bucket drive down animation name
    private let bucketDownAnimationName = "bucket_drive_down_animation"
    /// Mic alpha animation name
    private let micAlphaAnimationName = "mic_alpha_animation"

    // the height of the Mic that should go up to
    /// Mic up animation height
    private let micUpAnimationHeight: CGFloat = 150
    /// Mic y offset
    private let micYOffsetFromBase = 7
    /// Mic mid y position
    private var micMidY: CGFloat?
    /// Mic y origin
    private var micOriginY: CGFloat?
    /// Bucket y origin
    private var bucketY: CGFloat?
    /// Animation callback delegate
    weak var animationDelegate: AnimationFinishedDelegate?

    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Animate small mic Infinite Alpha
    func animateAlpha() {
        micLayer.isHidden = false
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 0
        alphaAnimation.toValue = 1.0
        alphaAnimation.repeatCount = .infinity
        alphaAnimation.autoreverses = true
        alphaAnimation.duration = 0.8
        alphaAnimation.speed = 0.8
        micLayer.add(alphaAnimation, forKey: micAlphaAnimationName)
    }

    /// Set up view
    private func setup() {
        smallMicImage = UIImage.fromPod("mic_red")
        let bucketLidImage = UIImage.fromPod("bucket_lid")
        let bucketBodyImage = UIImage.fromPod("bucket_body")
        bucketLidLayer.anchorPoint = CGPoint(x: 0.15, y: 1.56)
        bucketBodyLayer.anchorPoint = CGPoint.zero
        bucketLidLayer.contents = bucketLidImage.cgImage
        bucketLidLayer.frame = CGRect(x: 0, y: 0, width: bucketLidImage.size.width, height: bucketLidImage.size.height)
        bucketBodyLayer.contents = bucketBodyImage.cgImage
        bucketBodyLayer.frame = CGRect(x: 0, y: bucketLidImage.size.height + 2, width: bucketBodyImage.size.width, height: bucketBodyImage.size.height)
        micLayer.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        micLayer.bounds = CGRect(x: 0, y: 0, width: 25, height: 25)
        micLayer.contents = smallMicImage.cgImage
        // align bucket below the mic to be invisible
        bucketContainerLayer.frame = micLayer.frame.offsetBy(dx: 5, dy: 200)
        bucketContainerLayer.addSublayer(bucketLidLayer)
        bucketContainerLayer.addSublayer(bucketBodyLayer)
        bucketContainerLayer.zPosition = 98
        micLayer.zPosition = 97
        layer.addSublayer(micLayer)
        layer.addSublayer(bucketContainerLayer)
    }

    /// Returns an object initialized from data in the specified coder object.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Start animation 'driveUp'
    func animateBucketAndMic() {
        micLayer.removeAnimation(forKey: micAlphaAnimationName)
        micDriveUpAnimation()
    }

    /// Reset animation
    func resetAnimations() {
        micLayer.removeAllAnimations()
        bucketContainerLayer.removeAllAnimations()
        bucketLidLayer.removeAllAnimations()
        bucketBodyLayer.removeAllAnimations()
        micLayer.isHidden = false
        bucketContainerLayer.isHidden = true
    }

    /// Open bucket (move bucket lid)
    private func openBucket() {
        let animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        let animation = CAKeyframeAnimation()
        animation.duration = 0.4
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.keyPath = "transform.rotation.z"
        animation.values = [degreesToRadians(degrees: 0), degreesToRadians(degrees: -60)]
        animation.timingFunctions = [animationTimingFunction, animationTimingFunction]
        bucketLidLayer.add(animation, forKey: "open")
    }

    /// Close bucket (move bucket lid)
    private func closeBucket() {
        let animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        let animation = CAKeyframeAnimation()
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.keyPath = "transform.rotation.z"
        animation.values = [degreesToRadians(degrees: -60), degreesToRadians(degrees: 0)]
        animation.timingFunctions = [animationTimingFunction, animationTimingFunction]
        animation.duration = 0.4
        bucketLidLayer.add(animation, forKey: "close")
    }

    /// Conver degrees to radians
    /// - Parameter degrees: Degrees
    /// - Returns: Radians
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }

    /// Lays out subviews.
    override func layoutSubviews() {
        super.layoutSubviews()

        if micMidY == nil {
            micMidY = micLayer.frame.midY
        }
        if micOriginY == nil {
            micOriginY = micLayer.frame.origin.y
        }
        if bucketY == nil {
            bucketY = bucketContainerLayer.frame.origin.y
        }
    }

    /// Mic drive up animation method
    private func micDriveUpAnimation() {
        let moveAnimation = CABasicAnimation(keyPath: "position.y")
        moveAnimation.fromValue = [micLayer.position.y]
        moveAnimation.toValue = [micLayer.frame.midY - micUpAnimationHeight]
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = CAMediaTimingFillMode.forwards
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)

        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform")
        rotateAnimation.values = [0.0, CFloat.pi, CGFloat.pi * 1.5, CGFloat.pi * 2.0]
        rotateAnimation.valueFunction = CAValueFunction(name: CAValueFunctionName.rotateZ)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotateAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]

        let animGroup = CAAnimationGroup()
        animGroup.delegate = self
        animGroup.setValue(micUpAnimationName, forKey: animationNameKey)
        animGroup.animations = [moveAnimation, rotateAnimation]
        animGroup.duration = 0.6
        animGroup.isRemovedOnCompletion = false
        animGroup.fillMode = CAMediaTimingFillMode.forwards
        micLayer.add(animGroup, forKey: micUpAnimationName)
    }

    /// Mic drive down animation
    private func micDriveDownAnimation() {
        let moveAnimation = CABasicAnimation(keyPath: "position.y")
        moveAnimation.delegate = self
        moveAnimation.setValue(micDownAnimationName, forKey: animationNameKey)
        moveAnimation.toValue = [micLayer.position.y]
        moveAnimation.duration = 0.6
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = CAMediaTimingFillMode.forwards
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        micLayer.add(moveAnimation, forKey: micDownAnimationName)
    }

    /// Bucket drive down animation
    private func bucketDriveDownAnimation() {
        let moveAnimation = CABasicAnimation(keyPath: "position.y")
        moveAnimation.delegate = self
        moveAnimation.setValue(bucketDownAnimationName, forKey: animationNameKey)
        moveAnimation.toValue = [(micMidY ?? 0) + 100]
        moveAnimation.duration = 0.6
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = CAMediaTimingFillMode.forwards
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        moveAnimation.beginTime = CACurrentMediaTime() + 0.4
        bucketContainerLayer.add(moveAnimation, forKey: bucketDownAnimationName)
    }

    /// Bucket drive up animation method
    private func bucketDriveUpAnimation() {
        let moveAnimation = CABasicAnimation(keyPath: "position.y")
        moveAnimation.delegate = self
        moveAnimation.setValue(bucketUpAnimationName, forKey: animationNameKey)
        moveAnimation.fromValue = [bucketContainerLayer.position.y]
        moveAnimation.toValue = [micMidY ?? 0]
        moveAnimation.duration = 0.6
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = CAMediaTimingFillMode.forwards
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        bucketContainerLayer.add(moveAnimation, forKey: bucketUpAnimationName)

    }
    
    /// Tells the delegate the animation has started.
    /// - Parameter anim: The CAAnimation object that has started.
    func animationDidStart(_ anim: CAAnimation) {
        if let animationName = anim.value(forKey: animationNameKey) as? String {
            if animationName == micDownAnimationName {
                bucketDriveUpAnimation()
            } else if animationName == bucketUpAnimationName {
                bucketContainerLayer.isHidden = false
                openBucket()
            }
        }
    }
    
    /// Tells the delegate the animation has ended.
    /// - Parameters:
    ///   - anim: The CAAnimation object that has ended.
    ///   - flag: A flag indicating whether the animation has completed by reaching the end of its duration.
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {
            return
        }
        if let animationName = anim.value(forKey: animationNameKey) as? String {
            if animationName == micUpAnimationName {
                micDriveDownAnimation()
            } else if animationName == micDownAnimationName {
                micLayer.isHidden = true
                closeBucket()
                self.bucketDriveDownAnimation()
            } else if animationName == bucketDownAnimationName {
                bucketContainerLayer.isHidden = true
                animationDelegate?.animationFinished()
            }
        }
    }
}
