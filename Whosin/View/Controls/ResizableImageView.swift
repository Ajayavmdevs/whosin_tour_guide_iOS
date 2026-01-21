import Foundation
import UIKit

class ResizableImageView: UIImageView {

    private var _aspectRatioConstraint: NSLayoutConstraint?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override init(image: UIImage?) {
        super.init(image: image)
        _customize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _customize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _customize()
    }
    
    override var image: UIImage? {
        didSet {
            _updateAspectRatio()
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _customize() {
        contentMode = .scaleAspectFill
        _updateAspectRatio()
    }

    private func _updateAspectRatio() {
        _aspectRatioConstraint?.isActive = false
        guard let image = image else { return }
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        guard imageWidth > 0 else { return }
        let aspectRatio = imageHeight / imageWidth
        guard aspectRatio > 0 else { return }
        _aspectRatioConstraint = heightAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: aspectRatio
        )
        _aspectRatioConstraint?.isActive = true
    }
}
