
import UIKit
import Lightbox

class PlusOneUserCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    private var _userModel: UserDetailModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 48 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        _avatarImageView.isUserInteractionEnabled = true
        _avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ userModel: UserDetailModel) {
        self._userModel = userModel
        _titleLabel.text = userModel.fullName
        _avatarImageView.loadWebImage(userModel.image, name: userModel.fullName)
    }
    
    @objc func profileImageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _avatarImageView.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended {
            images.append(LightboxImage(imageURL: URL(string: _userModel?.image ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        parentBaseController?.present(controller, animated: true, completion: nil)
    }


}
