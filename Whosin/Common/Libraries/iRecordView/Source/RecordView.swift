import UIKit

/**
 This Class design and implemented to Record Voice note view
 
 #Super Class
 UIView
 
 #Protocol
 CAAnimationDelegate
 */
public class RecordView: UIView, CAAnimationDelegate {

    /// True/False
    private var isSwiped = false
    /// Bucket image view
    private var bucketImageView: BucketImageView?
    /// Timer
    private var timer: Timer?
    /// Duration
    private var duration: CGFloat = 0
    /// Transform
    private var mTransform: CGAffineTransform?
    /// Audio player
    private var audioPlayer: AudioPlayer?
    /// Timer stack view
    private var timerStackView: UIStackView?
    /// Slide to cancel stack view
    private var slideToCancelStackVIew: UIStackView?
    /// Voice record action callbacks delegate
    public weak var delegate: RecordViewDelegate?
    /// Offset
    public var offset: CGFloat = 20
    /// Is sound enabled(true/false)
    public var isSoundEnabled = true
    /// Record button scale
    public var buttonTransformScale: CGFloat = 1.5
    /// Timer label font
    public var timerLabelFont: UIFont? {
        didSet {
            if let timerLabelFont = timerLabelFont {
                timerLabel.font = timerLabelFont
            }
        }
    }
    /// Slide label font
    public var slideLabelFont: UIFont? {
        didSet {
            if let slideLabelFont = slideLabelFont {
                slideLabel.font = slideLabelFont
            }
        }
    }

    /// Slide to cancel label font
    public var slideToCancelText: String? {
        didSet {
            slideLabel.text = slideToCancelText
        }
    }

    /// Slide to cancel label text color
    public var slideToCancelTextColor: UIColor? {
        didSet {
            slideLabel.textColor = slideToCancelTextColor
        }
    }

    /// Slide to cancel arrow image
    public var slideToCancelArrowImage: UIImage? {
        didSet {
            arrow.image = slideToCancelArrowImage
        }
    }

    /// Small mic image
    public var smallMicImage: UIImage? {
        didSet {
            guard let smallMicImage = smallMicImage else { return }
            bucketImageView?.smallMicImage = smallMicImage
        }
    }

    /// Duration label text color
    public var durationTimerColor: UIColor? {
        didSet {
            timerLabel.textColor = durationTimerColor
        }
    }

    /// Arrow image view
    private let arrow: UIImageView = {
        let arrowView = UIImageView()
        arrowView.image = UIImage.fromPod("slideToCancelArrow")
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.contentMode = .scaleAspectFit
        arrowView.tintColor = .black
        return arrowView
    }()

    /// Slide label
    private let slideLabel: UILabel = {
        let slide = UILabel()
        slide.text = "Slide To Cancel"
        slide.translatesAutoresizingMaskIntoConstraints = false
        slide.font = slide.font.withSize(12)
        return slide
    }()

    /// Timer label
    private var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Set up view
    private func setup() {
        let bucketImageView = BucketImageView(frame: frame)
        bucketImageView.animationDelegate = self
        bucketImageView.translatesAutoresizingMaskIntoConstraints = false
        bucketImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        bucketImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.bucketImageView = bucketImageView
        
        let timerStackView = UIStackView(arrangedSubviews: [bucketImageView, timerLabel])
        timerStackView.translatesAutoresizingMaskIntoConstraints = false
        timerStackView.isHidden = true
        timerStackView.spacing = 5
        self.timerStackView = timerStackView
        
        let slideToCancelStackVIew = UIStackView(arrangedSubviews: [arrow, slideLabel])
        slideToCancelStackVIew.translatesAutoresizingMaskIntoConstraints = false
        slideToCancelStackVIew.isHidden = true
        self.slideToCancelStackVIew = slideToCancelStackVIew
        addSubview(timerStackView)
        addSubview(slideToCancelStackVIew)

        arrow.widthAnchor.constraint(equalToConstant: 15).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 15).isActive = true

        slideToCancelStackVIew.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        slideToCancelStackVIew.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        timerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        timerStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        mTransform = CGAffineTransform(scaleX: buttonTransformScale, y: buttonTransformScale)

        audioPlayer = AudioPlayer()
    }
    
    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Touch down method
    /// - Parameter recordButton: Record button instance
    func onTouchDown(recordButton: RecordButton) {
        if isOnPhoneCall() {
            delegate?.onPhoneCall()
            return
        }
        onStart(recordButton: recordButton)
    }
    
    /// Touch up method
    /// - Parameter recordButton: Record button instance
    func onTouchUp(recordButton: RecordButton) {
        guard !isSwiped else {
            return
        }
        onFinish(recordButton: recordButton)
    }
    
    /// Touch cancelled method
    /// - Parameter recordButton: Record button instance
    func onTouchCancelled(recordButton: RecordButton) {
        onTouchCancel(recordButton: recordButton)
    }

    /// Returns an object initialized from data in the specified coder object.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Update duration method
    @objc private func updateDuration() {
        duration += 1
        timerLabel.text = duration.fromatSecondsFromTimer()
    }

    /// This will be called when user starts tapping the button
    /// - Parameter recordButton: Record button instance
    private func onStart(recordButton: RecordButton) {
        guard AudioRecorderManager.shared.checkAudioRecordPermission(showAlert: true) else { return }
        isSwiped = false
        self.prepareToStartRecording(recordButton: recordButton)
        if isSoundEnabled {
            audioPlayer?.playAudioFile(soundType: .start)
            audioPlayer?.didFinishPlaying = { [weak self] _ in
                self?.delegate?.onStart()
            }
        } else {
            delegate?.onStart()
        }
    }
    
    /// This will be called to prepare recording
    /// - Parameter recordButton: Record button instance
    private func prepareToStartRecording(recordButton: RecordButton) {
        slideLabel.startShimmering()
        delegate?.prepareToStartRecording()
        resetTimer()

        // start timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)

        // reset all views to default
        slideToCancelStackVIew?.transform = .identity
        recordButton.transform = .identity

        // animate button to scale up
        UIView.animate(withDuration: 0.2) {
            recordButton.transform = self.mTransform ?? .identity
        }

        slideToCancelStackVIew?.isHidden = false
        timerStackView?.isHidden = false
        timerLabel.isHidden = false
        bucketImageView?.isHidden = false
        bucketImageView?.resetAnimations()
        bucketImageView?.animateAlpha()
    }

    /// Animation record button
    /// - Parameter recordButton: Record button instance
    fileprivate func animateRecordButtonToIdentity(_ recordButton: RecordButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = .identity
        })
    }
    
    /// This will be called when user swipes to the left and cancel the record
    fileprivate func hideCancelStackViewAndTimeLabel() {
        slideLabel.stopShimmering()
        slideToCancelStackVIew?.isHidden = true
        timerLabel.isHidden = true
    }
    
    /// On swipe method
    /// - Parameter recordButton: Record button instance
    private func onSwipe(recordButton: RecordButton) {
        isSwiped = true
        audioPlayer?.didFinishPlaying = nil
        animateRecordButtonToIdentity(recordButton)
        hideCancelStackViewAndTimeLabel()
        if !isLessThanOneSecond() {
            bucketImageView?.animateBucketAndMic()
        } else {
            bucketImageView?.isHidden = true
            delegate?.onAnimationEnd()
        }
        resetTimer()
        delegate?.onCancel()
    }
    
    /// On touch cancel method
    /// - Parameter recordButton: Record button instance
    private func onTouchCancel(recordButton: RecordButton) {
        isSwiped = false
        audioPlayer?.didFinishPlaying = nil
        animateRecordButtonToIdentity(recordButton)
        hideCancelStackViewAndTimeLabel()
        bucketImageView?.isHidden = true
        delegate?.onAnimationEnd()
        resetTimer()
        delegate?.onCancel()
    }

    /// Reset timer
    private func resetTimer() {
        timer?.invalidate()
        timerLabel.text = "00:00"
        duration = 0
    }

    /// This will be called when user lift his finger
    /// - Parameter recordButton: Record button instance
    private func onFinish(recordButton: RecordButton) {
        isSwiped = false
        audioPlayer?.didFinishPlaying = nil
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            recordButton.transform = .identity
        })

        slideToCancelStackVIew?.isHidden = true
        timerStackView?.isHidden = true
        timerLabel.isHidden = true
        if isLessThanOneSecond() {
            if isSoundEnabled {
                audioPlayer?.playAudioFile(soundType: .error)
            }
        } else {
            if isSoundEnabled {
                audioPlayer?.playAudioFile(soundType: .end)
            }
        }

        delegate?.onFinished(duration: duration)
        resetTimer()

    }

    /// This will be called when user starts to move his finger
    /// - Parameters:
    ///   - recordButton: Record button instance
    ///   - sender: UIPanGestureRecognizer instance
    func touchMoved(recordButton: RecordButton, sender: UIPanGestureRecognizer) {
        guard !isSwiped else { return }
        guard let button = sender.view else { return }
        let translation = sender.translation(in: button)
        switch sender.state {
        case .changed:
            // prevent swiping the button outside the bounds
            if translation.x < 0 {
                // start move the views
                let transform = mTransform?.translatedBy(x: translation.x, y: 0) ?? .identity
                button.transform = transform
                slideToCancelStackVIew?.transform = transform.scaledBy(x: 0.5, y: 0.5)
                guard let frame1 = slideToCancelStackVIew?.frame, let frame2 = timerStackView?.frame else { return }
                if frame1.intersects(frame2.offsetBy(dx: offset, dy: 0)) {
                    onSwipe(recordButton: recordButton)
                }
            }
        default:
            break
        }
    }
}
/**
 Animation finished delegate extension
 */
extension RecordView: AnimationFinishedDelegate {
    /// Animation finished
    func animationFinished() {
        slideToCancelStackVIew?.isHidden = true
        timerStackView?.isHidden = false
        timerLabel.isHidden = true
        delegate?.onAnimationEnd()
    }
}

/**
 Record view extension
 */
private extension RecordView {
    /// Returns whether or not the user is on a phone call
    /// - Returns: True/False
     func isOnPhoneCall() -> Bool {
//        for call in CXCallObserver().calls {
//            if call.hasEnded == false {
//                return true
//            }
//        }
        return false
    }
}

/**
 Record view extension
 */
private extension RecordView {
    /// Audio less than one second
    /// - Returns: True/False
    func isLessThanOneSecond() -> Bool {
        return duration < 1
    }
}

/**
 UIView extension
 */
extension UIView {
    
    /// Start shimmering method
    func startShimmering() {
        //        let light = UIColor.init(white: 0, alpha: 0.1).cgColor
        let light = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        let dark = UIColor.black.cgColor

        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]
        gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3 * self.bounds.size.width, height: self.bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.4, 0.5, 0.6]
        self.layer.mask = gradient

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.8, 0.9, 1.0]
        animation.toValue = [0.0, 0.1, 0.2]
        animation.duration = 1.5
        animation.repeatCount = HUGE
        gradient.add(animation, forKey: "shimmer")
    }

    /// Stop shimmering method
    func stopShimmering() {
        self.layer.mask = nil
    }

}
