import UIKit

/**
 CGFloat extension
 */
extension CGFloat {
    /// Format seconds into time
    /// - Returns: Formated minutes and seconds
    func fromatSecondsFromTimer() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

/**
 UIImage extension
 */
extension UIImage {
    
    /// Get image
    /// - Parameter name: Image name
    /// - Returns: UImage instance
    static func fromPod(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        return UIImage(named: name, in: nil, compatibleWith: traitCollection) ?? UIImage()
    }
}
