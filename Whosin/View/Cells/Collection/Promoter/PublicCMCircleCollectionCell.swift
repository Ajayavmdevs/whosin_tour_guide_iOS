import UIKit

class PublicCMCircleCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _nameLabel: CustomLabel!
    @IBOutlet private weak var _imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height : CGFloat { 60 }

    public func setup(_ model: UserDetailModel) {
        _nameLabel.text = model.title
        _imageView.loadWebImage(model.avatar, name: model.title)
    }
}
