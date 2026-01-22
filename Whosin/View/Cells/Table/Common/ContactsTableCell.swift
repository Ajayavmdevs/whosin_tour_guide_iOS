import UIKit

class ContactsTableCell: UITableViewCell {
    
    @IBOutlet weak var _sapratorView: UIView!
    @IBOutlet private weak var _bgViewTariling: NSLayoutConstraint!
    @IBOutlet private weak var _bgViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet private weak var _contactbookName: UILabel!
    @IBOutlet private weak var _btnselect: UIButton!
    @IBOutlet private weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _statusView: CustomStatusView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
//    public var reloadCallback: ((_ id: String, _ status: String) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _avatarImageView.cancelImageFetch()
        _avatarImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    
    func setupData(_ model:UserDetailModel, isInvite: Bool = false, isSheet: Bool = false, isSelected: Bool = false) {
        _btnselect.isHidden = true
        _titleLabel.text = model.fullName
        _subtitleLabel.text = Utils.stringIsNullOrEmpty(model.phone) ? model.email : "\(model.countryCode) \(model.phone)"
        _avatarImageView.loadWebImage(model.image, name: model.firstName)
        _btnselect.setImage(isSelected ? UIImage(named: "icon_radio_selected") : UIImage(named: "icon_radio"), for: .normal)
        _btnselect.isHidden = !isInvite
        
        if isSheet {
            _btnselect.isHidden = false
            if isInvite {
                _btnselect.setImage(isSelected ? UIImage(named: "icon_radio_selected") : UIImage(named: "icon_radio"), for: .normal)
            } else {
                _btnselect.setImage(isSelected ? UIImage(named: "icon_selectedGreen") : UIImage(named: "icon_deselcetCode"), for: .normal)
            }
        }
    }
    
    func setupCircleData(_ model:UserDetailModel, isSelected: Bool = false) {
        _titleLabel.text = model.title
        _subtitleLabel.text = model.descriptions
        _avatarImageView.loadWebImage(model.avatar, name: model.title)
        _btnselect.isHidden = false
        _btnselect.setImage(isSelected ? UIImage(named: "icon_selectedGreen") : UIImage(named: "icon_deselcetCode"), for: .normal)
    }
    
    public func setPrifileConstraint(lastRow: Bool = false, firstRow: Bool = false) {
        self._bgViewTariling.constant = 10
        self._bgViewConstraint.constant = 10
        self._bgView.backgroundColor = ColorBrand.cardBgColor
        DispatchQueue.main.async {
            self._bgView.roundCorners(corners: (firstRow ? (lastRow ? [.allCorners] : [.topLeft, .topRight]) : (lastRow ? [.bottomRight, .bottomLeft] : [])), radius: (firstRow && lastRow ? 15 : 15))
        }
        _sapratorView.isHidden = lastRow
    }

    func _handleInviteEvent() {
        let items = [kInviteMessage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.setValue(kAppName, forKey: "subject")
        activityController.popoverPresentationController?.sourceView = self.parentViewController?.view
        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
        parentViewController?.present(activityController, animated: true, completion: nil)
    }
}



