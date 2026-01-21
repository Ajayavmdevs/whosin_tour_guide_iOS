import UIKit
import CollectionViewPagingLayout

class ShoutoutLargeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _containerView: UIView!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueNameLabel: UILabel!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _userNameLabel: UILabel!
    @IBOutlet weak var _distanceLabel: UILabel!
    @IBOutlet weak var _messageLabel: UILabel!
    @IBOutlet weak var _gradientButton: GradientView!
    @IBOutlet weak var _stackOneImage: UIImageView!
    @IBOutlet weak var _stackTwoImage: UIImageView!
    @IBOutlet weak var _stackThreeImage: UIImageView!
    @IBOutlet weak var _totalUserCountLabel: UILabel!
    @IBOutlet weak var _countContainer: GradientView!
    @IBOutlet weak var _userDetailStack: UIStackView!
    @IBOutlet weak var _venueDetailStack: UIStackView!
    
    private var _shoutOutModel: ShoutoutListModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        270
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._containerView.addGradientBorder(cornerRadius: 12, 4, false)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(letsTalkTapHandler(_:)))
        _gradientButton.addGestureRecognizer(tap)
        
        let tapVenue = UITapGestureRecognizer(target: self, action: #selector(openVenueDetail(_:)))
        _venueDetailStack.addGestureRecognizer(tapVenue)

        let tapUser = UITapGestureRecognizer(target: self, action: #selector(openUserDetail(_:)))
        _userDetailStack.addGestureRecognizer(tapUser)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: ShoutoutListModel?) {
        self._shoutOutModel = model
        
        _messageLabel.text = model?.title
        
        if let venue = model?.venue {
            _venueImage.loadWebImage(venue.cover, name: venue.name)
            _venueNameLabel.text = venue.name
        }
        
        if let user = model?.user {
            _userImage.loadWebImage(user.image, name: user.fullName)
            _userNameLabel.text = user.fullName
            _gradientButton.isHidden = user.id == APPSESSION.userDetail?.id
        }
        
        
        _stackOneImage.isHidden = true
        _stackTwoImage.isHidden = true
        _stackThreeImage.isHidden = true
        _totalUserCountLabel.isHidden = true
        _countContainer.isHidden = true
        
        if let withUsers = model?.withMe {
            if withUsers.count > 0 {
                _stackOneImage.isHidden = false
                _stackOneImage.loadWebImage(withUsers[0].image, name: withUsers[0].fullName)
            }
            if withUsers.count > 1 {
                _stackTwoImage.isHidden = false
                _stackTwoImage.loadWebImage(withUsers[1].image, name: withUsers[1].fullName)
            }
            if withUsers.count > 2 {
                _stackThreeImage.isHidden = false
                _stackThreeImage.loadWebImage(withUsers[2].image, name: withUsers[2].fullName)
            }
            if withUsers.count > 3 {
                _totalUserCountLabel.isHidden = false
                _countContainer.isHidden = false
                _totalUserCountLabel.text = "\(withUsers.count - 3)"
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func letsTalkTapHandler(_ g: UITapGestureRecognizer) -> Void {
        guard let user = _shoutOutModel?.user else {return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = user.image
        chatModel.title = user.fullName
        chatModel.chatType = "friend"
        chatModel.members.append(user.id)
        chatModel.members.append(userDetail.id)
        let chatIds = [user.id, userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.hidesBottomBarWhenPushed = true
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func openVenueDetail(_ g: UITapGestureRecognizer) -> Void {
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = _shoutOutModel?.venueId ?? kEmptyString
        vc.venueDetailModel = _shoutOutModel?.venue
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openUserDetail(_ g: UITapGestureRecognizer) -> Void {
        guard let user = _shoutOutModel?.user else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        if user.id != userDetail.id {
            if user.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = user.id
                vc.isFromPersonal = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else if user.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = user.id
                vc.isFromPersonal = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = user.id
                vc.modalPresentationStyle = .overFullScreen
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

extension ShoutoutLargeCollectionCell:StackTransformView {
    var stackOptions: StackTransformViewOptions {
        StackTransformViewOptions(scaleFactor: 0.10, maxStackSize: 3, spacingFactor: 0.02, popAngle: 0, popOffsetRatio: .init(width: -1.3, height: 0.0),stackPosition: CGPoint(x: 1, y: 0))
    }
}
