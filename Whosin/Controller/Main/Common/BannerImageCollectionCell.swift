import UIKit
import CollectionViewPagingLayout

class BannerImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _imageView: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        291
    }

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ imagePath: String) {
        print("banner image url : \(imagePath)")
        _imageView.loadWebImage(imagePath)
    }

}

extension BannerImageCollectionCell:StackTransformView {
    var stackOptions: StackTransformViewOptions {
        StackTransformViewOptions(scaleFactor: 0.10, maxStackSize: 3, spacingFactor: 0.02, popAngle: 0, popOffsetRatio: .init(width: -1.3, height: 0.0),stackPosition: CGPoint(x: 1, y: 0))
    }
}


