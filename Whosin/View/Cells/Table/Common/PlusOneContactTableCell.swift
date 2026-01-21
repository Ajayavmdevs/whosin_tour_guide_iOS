import UIKit
import MessageUI

class PlusOneContactTableCell: UITableViewCell {
    
    @IBOutlet weak var _contactBtn: ContactButtonView!
    @IBOutlet weak var _btnStack: UIStackView!
    @IBOutlet weak var _notEligibleText: CustomLabel!
    @IBOutlet weak var _selectImage: UIImageView!
    @IBOutlet weak var _sapratorView: UIView!
    @IBOutlet private weak var _bgViewTariling: NSLayoutConstraint!
    @IBOutlet private weak var _bgViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet weak var _avatarImageView: UIImageView!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _subtitleLabel: UILabel!
    @IBOutlet weak var _inviteButton: UIButton!
    @IBOutlet weak var _plusOneStaus: CustomLabel!
    @IBOutlet weak var _menuButton: CustomButton!
    private var _inviteModel: UserDetailModel?
    private var shareMessage: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestInvite(_ id: String, name: String) {
        parentBaseController?.showHUD()
        WhosinServices.invitePlusOneMember(id: id) { [weak self] container, error in
            guard let self = self else { return }
            parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showSuccessMessage("invitation_sent".localized(), subtitle: LANGMANAGER.localizedString(forKey: "invitation_sent_subtitle", arguments: ["value": name]))
                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                self.parentViewController?.dismiss(animated: true)
            }
        }
    }
    
    private func shareDynamicLink() {
        guard let user = APPSESSION.userDetail else { return }
        var params: [String: Any] = [:]
        params["title"] = user.fullName
        params["description"] = user.bio
        params["image"] = user.image
        params["itemId"] = user.id
        params["itemType"] = "PlusOne"

        Utils.generateDynamicLinksForJoinPlusOne(params: params) { [weak self] message, error in
            guard let self = self else { return }
            guard let message = message else { return }
            if !Utils.stringIsNullOrEmpty(message) {
                guard let inviteModel = _inviteModel else { return }
                let matchingContacts = WHOSINCONTACT.inviteContactList.filter { contact in
                    return contact.phone == inviteModel.phone
                }
                let numbers = matchingContacts.map { $0.phone }
                if numbers.isEmpty { return }
                guard MFMessageComposeViewController.canSendText() else { return }
                let messageVC = MFMessageComposeViewController()
                messageVC.body = message
                messageVC.recipients = numbers
                messageVC.messageComposeDelegate = self
                parentViewController?.present(messageVC, animated: false, completion: nil)

            }
        }
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ model:UserDetailModel, isSelected: Bool = false, isInvite: Bool = false, isRingMember: Bool = false) {
        _avatarImageView.loadWebImage(model.image, name: model.firstName)
        _titleLabel.text = model.fullName
        _selectImage.image = UIImage(named: isSelected ? "icon_selectedGreen" : "icon_deselcetCode")
        _inviteButton.isHidden = !isInvite
        _selectImage.isHidden = isInvite
        _inviteModel = model
        if isInvite {
            _plusOneStaus.text = kEmptyString
            _menuButton.isHidden = true
            _contactBtn.isHidden = true
            _selectImage.isHidden = true
        } else if model.follow == "pending" || model.follow == "cancelled" || model.follow == "none" && !isRingMember {
            _plusOneStaus.text = kEmptyString
            _menuButton.isHidden = true
            _selectImage.isHidden = true
            _contactBtn.isHidden = false
            _contactBtn.isinvite = true
            _contactBtn.setupData(model: model.detached())
        } else {
            setPlusStatus(model.plusOneStatus, adminStatus: model.adminStatusOnPlusOne, model: model)
        }
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
    
    private func setPlusStatus(_ status: String, adminStatus: String, model: UserDetailModel) {
        _contactBtn.isHidden = true
        if status == "pending" {
            _plusOneStaus.text = "pending".localized()
            _plusOneStaus.textColor = ColorBrand.amberColor
            _selectImage.isHidden = true
            _menuButton.isHidden = false
        } else if status == "accepted" {
            _selectImage.isHidden = true
            if adminStatus == "pending" {
                _plusOneStaus.text = "waiting_for_admin_approval".localized()
                _plusOneStaus.textColor = ColorBrand.amberColor
                _menuButton.isHidden = true
            } else if adminStatus == "rejected" {
                _plusOneStaus.text = "rejected".localized()
                _plusOneStaus.textColor = .red
                _menuButton.isHidden = false
            } else {
                _plusOneStaus.text = kEmptyString//Utils.stringIsNullOrEmpty(model.phone) ? model.email : model.phone
//                _plusOneStaus.textColor = ColorBrand.white
                _menuButton.isHidden = true
                _selectImage.isHidden = false
            }
        } else if status == "rejected" {
            _plusOneStaus.text = "rejected".localized()
            _plusOneStaus.textColor = .red
            _selectImage.isHidden = true
            _menuButton.isHidden = false
        } else {
            _plusOneStaus.text = kEmptyString
            _selectImage.isHidden = false
            _menuButton.isHidden = true
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleMenuButtonEvent(_ sender: UIButton) {
        guard let user = _inviteModel else { return }
        let updateTime = Utils.stringToDate(user.plusOneRequestedAt, format: kStanderdDate) ?? Date()
        let differenceInSeconds = Date().timeIntervalSince(updateTime)
        if differenceInSeconds < 60 {
            parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
            return
        }
        self._requestInvite(user.id, name: user.fullName)
    }
    
    
    @IBAction func _handleInviteButton(_ sender: UIButton) {
        shareDynamicLink()
    }
}


extension PlusOneContactTableCell : MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            parentViewController?.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            parentViewController?.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            parentViewController?.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
}
