import UIKit
//import Parchment
import StripeCore

class EventInvitedUserTableCell: UITableViewCell {
    
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet weak var _inGuestView: UIView!
    @IBOutlet var _peopleImages: [UIImageView]!
    @IBOutlet weak var _invitedPeopleText: UILabel!
    @IBOutlet weak var _peopleNameText: UILabel!
    private var eventId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func configureImageViews(imageViews: [UIImageView], userImages: [UserDetailModel]) {
        let totalImageViews = imageViews.count
        for i in 0..<totalImageViews {
            if i < userImages.count {
                imageViews[i].isHidden = false
                imageViews[i].loadWebImage(userImages[i].image, name: userImages[i].firstName) {
                    do {
                        imageViews[i].borderColor = try imageViews[i].image?.averageColor() ?? ColorBrand.brandGray
                        imageViews[i].borderWidth = 1
                    } catch {}
                }
            } else {
                imageViews[i].isHidden = true
            }
        }
    }
    
    private func setupUi() {
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: EventModel, userModel: [UserDetailModel] = []) {
        eventId = model.id
        var invitedGuestsId: [String] = []
        model.invitedGuest.forEach { value in
            invitedGuestsId.append(value.userId)
        }
        if model.inGuest.isEmpty {
            _inGuestView.isHidden = true
        }
        if let user = Utils.getModelsFromIds(model: userModel, ids: invitedGuestsId) {
            configureImageViews(imageViews: _imageViews, userImages: user)
            _invitedPeopleText.text = LANGMANAGER.localizedString(forKey: "extra_guest_invite_count", arguments: ["value1": "\(model.invitedGuestCount)", "value2": " \(model.extraGuestCount)"])
        }
        // In Guest
        var inGuestId: [String] = []
        model.inGuest.forEach { value in
            inGuestId.append(value.userId)
        }
        if let inGuest = Utils.getModelsFromIds(model: userModel, ids: inGuestId) {
        _inGuestView.isHidden = inGuest.isEmpty
        configureImageViews(imageViews: _peopleImages, userImages: inGuest)
        
        var people: [String] = []
        inGuest.prefix(1).forEach { name in
            people.append(name.firstName)
        }
        let remainingCount = max(inGuest.count - 1, 0)
        if remainingCount > 0 {
            let remainingText = LANGMANAGER.localizedString(forKey: "people_are_in", arguments: ["value": "\(model.inGuestCount)"])
            people.append(remainingText)
        } else {
            let remainingText = ""
            people.append(remainingText)
        }
        _peopleNameText.text = people.joined(separator: " ")
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @IBAction private func _handleInvitedGuestListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
        presentedViewController.eventId = eventId
        presentedViewController.openChatCallBack = { chatModel in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = chatModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction private func _handleInGuestListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
        presentedViewController.eventId = eventId
        presentedViewController.inviteStatus = "in"
        presentedViewController.openChatCallBack = { chatModel in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = chatModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
}
