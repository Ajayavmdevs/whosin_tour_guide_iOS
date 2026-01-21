import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _closeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    class var height: CGFloat {
        230
    }
    
    public func setupData(_ imageName: String = "imge_defaultBanner", imageUrl:String = kEmptyString) {
        if imageUrl.isEmpty {
            _imageView.image = UIImage(named: imageName)
        } else {
            _imageView.loadWebImage(imageUrl)
        }
    }
}
