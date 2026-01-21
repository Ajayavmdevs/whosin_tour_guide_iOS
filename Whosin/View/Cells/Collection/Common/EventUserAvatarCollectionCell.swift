import UIKit

class EventUserAvatarCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _addImageView: UIImageView!

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        87
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
    
    func setupData() {
    }
}
