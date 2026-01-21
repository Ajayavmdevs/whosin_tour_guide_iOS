import UIKit
import Hero
import CollectionViewPagingLayout

class ShoutoutCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _userName: UILabel!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _messageLabel: UILabel!
    @IBOutlet weak var _venueName: UILabel!
    @IBOutlet weak var _userOneImae: UIImageView!
    @IBOutlet weak var _userTwoImage: UIImageView!
    @IBOutlet weak var _userThreeImage: UIImageView!
    @IBOutlet weak var _userCountView: GradientView!
    @IBOutlet weak var _userImageCount: UILabel!
    private var _venueDetailModel: VenueDetailModel?
    private var _userModel: UserDetailModel?
    private var _withMeUsers: [UserDetailModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        100
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._visualEffectView.roundCorners(corners: [.allCorners], radius: 10)
        }
    }
    
    override func select(_ sender: Any?) {
        
    }
     
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupShoutoutData(_ model: ShoutoutListModel?) {
        _userName.text = "\(model?.user?.firstName ?? kEmptyString) \(model?.user?.lastName ?? kEmptyString)"
        _userImage.loadWebImage(model?.user?.image ?? kEmptyString, name: model?.user?.firstName ?? kEmptyString)
        _userModel = model?.user
        _messageLabel.text = model?.title
        _venueName.text = model?.venue?.name
        _venueDetailModel = model?.venue

        guard let userModel = model?.withMe.toArrayDetached(ofType: UserDetailModel.self) else { return }
        _withMeUsers = userModel
        switch userModel.count {
        case 0:
            _userOneImae.isHidden = true
            _userTwoImage.isHidden = true
            _userThreeImage.isHidden = true
            _userCountView.isHidden = true
        case 1:
            _userOneImae.isHidden = false
            _userTwoImage.isHidden = true
            _userThreeImage.isHidden = true
            _userCountView.isHidden = true
            _userOneImae.loadWebImage(userModel[0].image, name: userModel[0].firstName)
        case 2:
            _userOneImae.isHidden = false
            _userTwoImage.isHidden = false
            _userThreeImage.isHidden = true
            _userCountView.isHidden = true
            _userOneImae.loadWebImage(userModel[0].image, name: userModel[0].firstName)
            _userTwoImage.loadWebImage(userModel[1].image, name: userModel[1].firstName)
        case 3:
            _userOneImae.isHidden = false
            _userTwoImage.isHidden = false
            _userThreeImage.isHidden = false
            _userCountView.isHidden = true
            _userOneImae.loadWebImage(userModel[0].image, name: userModel[0].firstName)
            _userTwoImage.loadWebImage(userModel[1].image, name: userModel[1].firstName)
            _userTwoImage.loadWebImage(userModel[2].image, name: userModel[2].firstName)
        case userModel.count:
            _userOneImae.isHidden = false
            _userTwoImage.isHidden = false
            _userThreeImage.isHidden = false
            _userCountView.isHidden = false
            _userOneImae.loadWebImage(userModel[0].image, name: userModel[0].firstName)
            _userTwoImage.loadWebImage(userModel[1].image, name: userModel[1].firstName)
            _userTwoImage.loadWebImage(userModel[2].image, name: userModel[2].firstName)
            _userImageCount.text = "+\(userModel.count - 3)"
        default:
            break
        }
    }

    @IBAction func _handleUserProfileEvent(_ sender: UIButton) {
        guard let userDetail = APPSESSION.userDetail, let object = _userModel, object.id != userDetail.id else { return }
        if object.isPromoter, userDetail.isRingMember {
            let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
            vc.promoterId = object.id
            vc.isFromPersonal = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else if object.isRingMember, userDetail.isPromoter {
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = object.id
            vc.isFromPersonal = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
            vc.contactId = _userModel?.id ?? kEmptyString
            vc.modalPresentationStyle = .overFullScreen
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func _handleWithMeBottomSheet(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(ShoutoutListBottomSheet.self)
        vc.userModel = _withMeUsers
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @IBAction private func _handleVenueClickEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let venueDetail = _venueDetailModel else {
            return
        }
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = venueDetail.id
        vc.venueDetailModel = venueDetail
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ShoutoutCollectionCell:StackTransformView {
    var stackOptions: StackTransformViewOptions {
        
        StackTransformViewOptions(scaleFactor: 0.10, maxStackSize: 3, spacingFactor: 0.02, alphaFactor: 0.5, popAngle: 0, popOffsetRatio: .init(width: -1.3, height: 0.0),stackPosition: CGPoint(x: 1, y: 0))
    }
    
}
