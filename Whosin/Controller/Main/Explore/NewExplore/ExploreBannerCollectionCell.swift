import UIKit

class ExploreBannerCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _titleString: CustomLabel!
    @IBOutlet weak var _subTitleText: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        200
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

    public func setupData(_ imagePath: String,title: String, subtitle: String) {
        print("banner image url : \(imagePath)")
        _imageView.loadWebImage(imagePath)
        _titleString.text = title
        _subTitleText.text = subtitle
    }

}
