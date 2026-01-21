import UIKit

class ExploreCategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _nameLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        160
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setupData(_ model: CategoryDetailModel, isSqure: Bool = true) {
        _avatarImageView.cornerRadius = isSqure ? 10 : _avatarImageView.frame.height / 2
        _avatarImageView.loadWebImage(model.image)
        _nameLabel.text = model.title
    }

}
