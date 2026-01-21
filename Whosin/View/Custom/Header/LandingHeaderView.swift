import UIKit

enum LandingViewType: Int {
    case register = 0
    case social = 1
    case login = 2
}

public protocol LandingHeaderViewDelegate: AnyObject {
    func profileUpload(_ image: UIImage)
}

class LandingHeaderView: UIView {
    
    @IBOutlet private weak var _profileImageView: UIImageView!
    @IBOutlet private weak var _avatarContainerView: UIView!
    @IBOutlet private weak var _welcomeContainerView: UIView!
    @IBOutlet private weak var _userContainerView: UIView!
    
    private var _viewType: LandingViewType = .register
    let _imagePicker = UIImagePickerController()
    var delegate: LandingHeaderViewDelegate?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    public class func initFromNib() -> LandingHeaderView {
        UINib(nibName: "LandingHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! LandingHeaderView
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleSigninEvent(_ sender: UIButton) {
        //IMPLEMENT LATTER
    }
    
    @IBAction private func _handleProfileUploadEvent(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            parentBaseController?.present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    var viewHeight: CGFloat {
        return 0
    }
    
    func setup(type: LandingViewType) {
        _avatarContainerView.isHidden = true
        _welcomeContainerView.isHidden = true
        _userContainerView.isHidden = true
        _viewType = type
        if _viewType == .register {
            _avatarContainerView.isHidden = false
        } else {
            _welcomeContainerView.isHidden = false
        }
    }
}

extension LandingHeaderView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._profileImageView.image = image
                self.delegate?.profileUpload(image)
            }
        }
    }
}
