import UIKit
import CollectionViewPagingLayout

class ShoutoutEventCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet private weak var _orgLogoImageView: UIImageView!
    @IBOutlet private weak var _orgNameLabel: UILabel!
    @IBOutlet private weak var _distanceLabel: UILabel!
    @IBOutlet private weak var _eventCoverImage: UIImageView!
    @IBOutlet private weak var _eventTitelLabel: UILabel!
    @IBOutlet private weak var _eventDescLabel: UILabel!
    @IBOutlet private weak var _orgDataStack: UIStackView!
    @IBOutlet private weak var _userStackView: UIStackView!
    @IBOutlet private weak var _stackOneImage: UIImageView!
    @IBOutlet private weak var _stackTwoImage: UIImageView!
    @IBOutlet private weak var _stackThreeImage: UIImageView!
    @IBOutlet private weak var _totalUserCountLabel: UILabel!
    @IBOutlet private weak var _countContainer: GradientView!
    
    private var _eventModel: EventModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        270
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._mainContainerView.addGradientBorder(cornerRadius: 12, 4, false)
            self._orgLogoImageView.cornerRadius = self._orgLogoImageView.frame.height / 2
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openEvnetGuestList(_:)))
        _userStackView.addGestureRecognizer(tap)
        
        let orgTap = UITapGestureRecognizer(target: self, action: #selector(openEventOrganizer(_:)))
        _orgDataStack.addGestureRecognizer(orgTap)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: EventModel?, userModel: [UserDetailModel] = []) {
        self._eventModel = model
        
        _orgNameLabel.text = model?.orgData?.name
        _orgLogoImageView.loadWebImage(model?.orgData?.logo ?? kEmptyString, name: model?.orgData?.name ?? kEmptyString)
        
        _eventCoverImage.loadWebImage(model?.image ?? kEmptyString)
        _eventTitelLabel.text = model?.title
        _eventDescLabel.text = model?.descriptions
        _distanceLabel.text = String(format: "%.1f",model?.venueDetail?.distance ?? 0.0) + " km"
    
        let userRepo = UserRepository()
        
        _stackOneImage.isHidden = true
        _stackTwoImage.isHidden = true
        _stackThreeImage.isHidden = true
        _totalUserCountLabel.isHidden = true
        _countContainer.isHidden = true
        
        guard let model = model else { return }
        let users = model.invitedGuest
        if users.count > 0 {
            _stackOneImage.isHidden = false
            if let user = userRepo.getUserById(userId: users[0].userId) {
                _stackOneImage.loadWebImage(user.image, name: user.fullName)
            }
        }
        if users.count > 1 {
            _stackTwoImage.isHidden = false
            if let user = userRepo.getUserById(userId: users[1].userId) {
                _stackTwoImage.loadWebImage(user.image, name: user.fullName)
                
            }
        }
        if users.count > 2 {
            _stackThreeImage.isHidden = false
            if let user = userRepo.getUserById(userId: users[2].userId) {
                _stackThreeImage.loadWebImage(user.image, name: user.fullName)
            }
        }
        if model.inGuestCount > 3 {
            _totalUserCountLabel.isHidden = false
            _countContainer.isHidden = false
            _totalUserCountLabel.text = "\(model.inGuestCount)"
        }
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleSeeMoreEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
        vc.event = _eventModel
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openEvnetGuestList(_ g: UITapGestureRecognizer) -> Void {
        let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
        presentedViewController.eventId = _eventModel?.id ?? kEmptyString
        presentedViewController.userOpenCallBack = { userId in
            let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
            vc.contactId = userId
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        presentedViewController.openChatCallBack = { chatModel in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = chatModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @objc func openEventOrganizer(_ g: UITapGestureRecognizer) -> Void {
        let vc = INIT_CONTROLLER_XIB(EventOrganisierVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.orgId = _eventModel?.orgData?.id ?? kEmptyString
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}

extension ShoutoutEventCollectionCell:StackTransformView {
    var stackOptions: StackTransformViewOptions {
        StackTransformViewOptions(scaleFactor: 0.10, maxStackSize: 3, spacingFactor: 0.02, popAngle: 0, popOffsetRatio: .init(width: -1.3, height: 0.0),stackPosition: CGPoint(x: 1, y: 0))
    }
}
