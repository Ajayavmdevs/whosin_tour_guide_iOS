import UIKit

class UserTableCell: UITableViewCell {


    @IBOutlet weak var _leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var _tralingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _statusView: CustomStatusView!
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet weak var _selectedBtn: UIButton!
    @IBOutlet weak var _contactBtnView: ContactButtonView!
    
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
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
        
    // --------------------------------------
    // MARK: Data/Service
    // --------------------------------------


    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _updateOptions() {
        guard let userModel = _userModel else {return }
        guard let userDetail = APPSESSION.userDetail else { return }
        if userModel.id == userDetail.id {
            _contactBtnView.isHidden = true
        } else {
            _contactBtnView.isHidden = false
            _contactBtnView.setupData(model: userModel)
        }
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
        _selectedBtn.isHidden = true 
        _updateOptions()
    }
    
    func setupRings(_ userModel: UserDetailModel, isSelected: Bool) {
        _leadingConstraint.constant = 24
        _tralingConstraint.constant = 24
        self._userModel = userModel
        _titleLabel.text = userModel.fullName
        _subtitleLabel.text = kEmptyString
        _avatarImageView.loadWebImage(userModel.image, name: userModel.fullName)
        _statusView.isHidden = true
        _contactBtnView.isHidden = true
        _selectedBtn.isHidden = false
        _selectedBtn.isSelected = isSelected
    }
        
}
