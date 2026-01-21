import UIKit
import PanModal
import FSCalendar
import SnapKit
import FloatRatingView
import LinearProgressBar



class ReviewDetailScreen: BaseViewController {
    
    @IBOutlet weak var _menuBtnView: UIView!
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet weak var _userRatting: FloatRatingView!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _date: UILabel!
    @IBOutlet weak var _userName: UILabel!
    @IBOutlet weak var _reviewText: UILabel!
    public var model: RatingModel?
    public var ticketModel: TicketReviewModel?
    public var userList: [UserModel] = []
    public var user: UserDetailModel?
    private var rattingId: String?
    private var isCurrentUser: Bool = false
    private var userId: String?
    
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _setupRattingView()
    }
    
    override func setupUi() {
        _mainContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Updater
    // --------------------------------------
    
    private func _setupRattingView() {
        if let model = model {
            _reviewText.text = model.review
            rattingId = model.ratingId
            _userRatting.rating = model.stars
            userId = model.userId
            isCurrentUser = APPSESSION.userDetail?.id == model.userId
            if let user = Utils.getUserFromId(userModels: userList, userId: model.userId) {
                _userImage.loadWebImage(user.image, name: user.firstName)
                _userName.text = "\(user.firstName) \(user.lastName)"
            } else {
                _userImage.loadWebImage(model.user?.image ?? kEmptyString, name: model.user?.firstName ?? kEmptyString)
                _userName.text = "\(model.user?.firstName ?? "") \(model.user?.lastName ?? "")"
            }
        } else if let ticketModel = ticketModel {
            isCurrentUser = APPSESSION.userDetail?.id == ticketModel.userId
            _userRatting.rating = Double(ticketModel.stars)
            rattingId = ticketModel._id
            userId = ticketModel.userId
            _reviewText.text = ticketModel.review
            if let user = Utils.getUserFromId(userModels: userList, userId: ticketModel.userId) {
                _userImage.loadWebImage(user.image, name: user.firstName)
                _userName.text = "\(user.firstName) \(user.lastName)"
            } else {
                _userImage.loadWebImage("", name: "Unknown User")
                _userName.text = "Unknown User"
            }
        }
    }
        
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    private func _deleteReview() {
        guard let id = rattingId else { return }
        WhosinServices.reviewReplyDelete(reviewId: id) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.showToast(message) }
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
    
    func showActionSheet(from viewController: UIViewController) {
        let actionSheet = UIAlertController(title: kAppName, message: "", preferredStyle: .actionSheet)

        let option1 = UIAlertAction(title: "delete".localized(), style: .default) { _ in
            self.confirmAlert(message: "delete_review_confirm".localized(), okHandler: { action in
                self._deleteReview()
            })
        }

        let cancel = UIAlertAction(title: "cancel".localized(), style: .cancel)

        actionSheet.addAction(option1)
        actionSheet.addAction(cancel)

        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        viewController.present(actionSheet, animated: true)
    }
    
    private func _optionsBottomSheet() {
        let controller = INIT_CONTROLLER_XIB(ReportOptionsSheet.self)
        controller.didUpdateCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case "report" :
                openReport(type)
            case "block":
                self.alert(title: kAppName, message: LANGMANAGER.localizedString(forKey: "block_user_alert", arguments: ["value": self.user?.fullName ?? ""])) {_ in
                    self._requestBlockUser(blockId: self.userId ?? "")
                } cancelHandler: { UIAlertAction in
                    self.dismiss(animated: true)
                }
            case "both":
                openReport(type)
            default :
                return
            }
        }
        self.presentAsPanModal(controller: controller)
    }
    
    private func openReport(_ type: String) {
        let vc = INIT_CONTROLLER_XIB(ReportBottomSheet.self)
        vc.type = type
        vc.didUpdateCallback = { [weak self] type, reason, msg in
            guard let self = self else { return }
            if type == "both" {
                _requestBlockUser(blockId: self.userId ?? "")
                _requestReportUser(userId: self.userId ?? "", reason: reason, msg: msg)
            } else {
                self._requestReportUser(userId: self.userId ?? "", reason: reason, msg: msg)
            }
        }
        self.presentAsPanModal(controller: vc)

    }
    
    private func _requestReportUser(userId: String, reason: String, msg: String) {
        self.showHUD()
        let params: [String: Any] = [
            "userId": userId,
            "message": msg,
            "reason": reason,
            "type": "review",
            "typeId": rattingId ?? ""
        ]
        WhosinServices.addReportUser(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            if !Preferences.blockedUsers.contains(userId) {
                Preferences.blockedUsers.append(userId)
            }
            self.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_reported".localized() + "\(self.user?.fullName ?? "")")
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
                NotificationCenter.default.post(name: .openReportSuccessCard, object: nil)
            }
        }
    }

    
    private func _requestBlockUser(blockId: String) {
        self.showHUD()
        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            self.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_blocked" + "\(self.user?.fullName ?? "")")
            if !Preferences.blockedUsers.contains(blockId) {
                Preferences.blockedUsers.append(blockId)
            }
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
            }
        }
    }


    
    @IBAction func _handleMenuBtnEvent(_ sender: UIButton) {
        if isCurrentUser {
            showActionSheet(from: self)
        } else {
            _optionsBottomSheet()
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
}

extension ReviewDetailScreen: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.4)
    }
    
    var isHapticFeedbackEnabled: Bool {
        return true
    }
    
    var allowsTapToDismiss: Bool {
        return true
    }
    
    var allowsDragToDismiss: Bool {
        return true
    }
    
    public var showDragIndicator: Bool {
        return false
    }
    
    func panModalWillDismiss() {
    }
    
}
