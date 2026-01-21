import UIKit
/**
 Record view delegate protocol
 */
public protocol RecordViewDelegate: AnyObject {
    /// Start recording
    func onStart()
    /// Cancel recording
    func onCancel()
    /// Finished recording
    func onFinished(duration: CGFloat)
    /// User on phone call
    func onPhoneCall()
    /// Voice recording animation ended
    func onAnimationEnd()
    /// Prepare to start recording
    func prepareToStartRecording()
}

/**
 Record view delegate extension
 */
extension RecordViewDelegate {
    /// Voice Recording animation ended
    func onAnimationEnd() { }
}
