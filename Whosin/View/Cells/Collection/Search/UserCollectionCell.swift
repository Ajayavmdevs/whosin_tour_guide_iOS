import UIKit

class UserCollectionCell: UICollectionViewCell {


    @IBOutlet weak var _selectedBtn: UIButton!
    @IBOutlet weak var _customBtnView: ContactButtonView!
    @IBOutlet private weak var _statusView: CustomStatusView!
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    private var _userModel: UserDetailModel?


    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 64 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ userModel: UserDetailModel) {
        self._userModel = userModel
        _titleLabel.text = userModel.fullName
        _subtitleLabel.text = kEmptyString
        _avatarImageView.loadWebImage(userModel.image, name: userModel.fullName)
        _statusView.isHidden = true
        _customBtnView.setupData(model: userModel)
        _selectedBtn.isHidden = true
    }
    
    func setupRings(_ userModel: UserDetailModel, isSelected: Bool) {
        self._userModel = userModel
        _titleLabel.text = userModel.fullName
        _subtitleLabel.text = kEmptyString
        _avatarImageView.loadWebImage(userModel.image, name: userModel.fullName)
        _statusView.isHidden = true
        _customBtnView.isHidden = true
        _selectedBtn.isSelected = isSelected
    }
        
}
