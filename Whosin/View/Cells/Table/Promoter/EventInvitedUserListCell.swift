import UIKit

class EventInvitedUserListCell: UITableViewCell {

    @IBOutlet weak var _inviteGenderView: UIView!
    @IBOutlet weak var _eventRepeatView: UIView!
    @IBOutlet weak var _eventRepeatType: CustomLabel!
    @IBOutlet weak var _invitedGenderLabel: CustomLabel!
    @IBOutlet weak var _usersListView: UIView!
    @IBOutlet weak var _spotsView: UIView!
    @IBOutlet weak var _intrestedView: UIView!
    @IBOutlet weak var _inUserView: UIView!
    @IBOutlet weak var _circleView: UIView!
    @IBOutlet weak var _invitedView: UIView!
    @IBOutlet weak var _inviteCancelView: UIView!
    @IBOutlet weak var _plusOneView: UIView!
    @IBOutlet weak var _invitedUsersList: CustomUserListView!
    @IBOutlet weak var _intresetedUsersList: CustomUserListView!
    @IBOutlet weak var _circleInvitedList: CustomUserListView!
    @IBOutlet weak var _seatsUsersList: CustomUserListView!
    @IBOutlet weak var _inviteCancelUserList: CustomUserListView!
    @IBOutlet weak var _plusOneUserList: CustomUserListView!
    @IBOutlet weak var _dressCodeLbl: CustomLabel!
    @IBOutlet weak var _spotLbl: CustomLabel!
    @IBOutlet weak var _totalSpots: CustomLabel!
    private var event: PromoterEventsModel?
    
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


    public func setupData(_ model: PromoterEventsModel, isComplementary: Bool = false) {
        event = model
        if isComplementary {
            _invitedView.isHidden = true
            _circleView.isHidden = true
            _inUserView.isHidden = true
            _intrestedView.isHidden = true
            _usersListView.isHidden = true
            _inviteCancelView.isHidden = true
            _plusOneView.isHidden = true
            _spotsView.isHidden = true
            _totalSpots.isHidden = true
            _spotLbl.text = (model.maxInvitee - model.totalInMembers) < 1 ? "remaining_spot".localized() : LANGMANAGER.localizedString(forKey: "remaining_spot_count", arguments: ["value": "\(model.maxInvitee - model.totalInMembers)"])
            _inviteGenderView.isHidden = true
        } else {
            _usersListView.isHidden = false
            _invitedView.isHidden = model.invitedUsers.isEmpty
            _circleView.isHidden = model.invitedCircles.isEmpty
            _inUserView.isHidden = model.inMembers.isEmpty
            _intrestedView.isHidden = model.interestedMembers.isEmpty
            _inviteCancelView.isHidden = model.inviteCancelList.isEmpty
            _plusOneView.isHidden = model.plusOneMembers.isEmpty
            _totalSpots.text = LANGMANAGER.localizedString(forKey: "spots", arguments: ["value": "\(model.maxInvitee)"])
            _spotLbl.text = (model.maxInvitee - model.totalInMembers) < 1 ? "remaining_spot".localized() : LANGMANAGER.localizedString(forKey: "remaining_spot_count", arguments: ["value": "\(model.maxInvitee - model.totalInMembers)"])
            _inviteGenderView.isHidden = false
        }
        _invitedGenderLabel.text = model.invitedGender.capitalized
        if model.repeatEvent == "specific-date" {
            _eventRepeatType.text = model.repeatDate
        } else if model.repeatEvent == "none" {
            _eventRepeatView.isHidden = true
        } else {
            _eventRepeatType.text = model.repeatEvent 
            _eventRepeatView.isHidden = false
        }
        _dressCodeLbl.text = model.dressCode
        _invitedUsersList.setupData(model.invitedUsers.toArrayDetached(ofType: UserDetailModel.self), title: "users_invited".localized()  + "(\(model.invitedUsers.count))", isshowCount: true, titleFont: FontBrand.SFmediumFont(size: 14))
        _circleInvitedList.setupData(model.invitedCircles.toArrayDetached(ofType: UserDetailModel.self), title: "circles_invited", titleFont: FontBrand.SFmediumFont(size: 14))
        _seatsUsersList.setupData(model.inMembers.toArrayDetached(ofType: UserDetailModel.self), title: "\(model.maxInvitee) " + "seats".localized(), counts: (model.maxInvitee - model.totalInMembers) < 1 ? "remaining_spot".localized() : LANGMANAGER.localizedString(forKey: "remaining_spot_count", arguments: ["value": "\(model.maxInvitee - model.totalInMembers)"]), isshowCount: true, titleFont: FontBrand.SFmediumFont(size: 14))
        _intresetedUsersList.setupData(model.interestedMembers.toArrayDetached(ofType: UserDetailModel.self), title: "interested_users".localized(), titleFont: FontBrand.SFmediumFont(size: 14))
        _inviteCancelUserList.setupData(model.inviteCancelList.toArrayDetached(ofType: UserDetailModel.self), title: "cancelled_users".localized(), titleFont: FontBrand.SFmediumFont(size: 14))
        _plusOneUserList.setupData(model.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self), title: "plus_one_members", titleFont: FontBrand.SFmediumFont(size: 14))

    }
    
    func openInvitedBottomSheet(_ type: String) {
        let vc = INIT_CONTROLLER_XIB(SeeAllUsersBottomSheet.self)
        vc.event = event
        vc.isFromEvent = true
        vc.userType = type
        vc.openProfile = { id, isRingMember in
            if isRingMember {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = id
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = id
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        vc.openChat = { model in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = model
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: vc)

    }
    
    @IBAction func _handleSeeAllInUserEvent(_ sender: UIButton) {
//        guard event?.status != "in-progress", event?.status != "cancelled" && event?.status != "completed" else { return }
//        guard event?.status != "cancelled" && event?.status != "completed" else { return }
        openInvitedBottomSheet("in")
    }
    
    @IBAction func _handleSeeAllInvitedUsersEvent(_ sender: UIButton) {
//        guard event?.status != "in-progress", event?.status != "cancelled" && event?.status != "completed" else { return }
//        guard event?.status != "cancelled" && event?.status != "completed" else { return }
        openInvitedBottomSheet("invited")
    }
    
    @IBAction func _hanldeIntrestedUsersEvent(_ sender: UIButton) {
//        guard event?.status != "in-progress", event?.status != "cancelled" && event?.status != "completed" else { return }
//        guard event?.status != "cancelled" && event?.status != "completed" else { return }
        openInvitedBottomSheet("intreseted")
    }
    
    @IBAction func _handleCancelledUsersEvent(_ sender: UIButton) {
        openInvitedBottomSheet("cancelled")
    }
    
    @IBAction func _handlePlusOneUsersEvent(_ sender: UIButton) {
        openInvitedBottomSheet("plusOne")
    }
}
