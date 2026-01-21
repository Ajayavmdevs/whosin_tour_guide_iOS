import UIKit
import FloatRatingView
import StripeCore

class RatingViewCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _menuBtnView: UIView!
    @IBOutlet private weak var _editOptions: UIStackView!
    @IBOutlet private weak var _replyBtnView: UIView!
    @IBOutlet weak var _deleteReviewView: UIView!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _ratingView: FloatRatingView!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _reviewLabel: UILabel!
    @IBOutlet private weak var _replyView: UIView!
    @IBOutlet private weak var _replyImage: UIImageView!
    @IBOutlet private weak var _replyBusnessName: UILabel!
    @IBOutlet private weak var _replyTextLabel: UILabel!
    private var ratingModel: RatingModel?
    public var user: UserDetailModel?
    private var isCurrentUser: Bool = false
    private var rattingId: String?
    private var userId: String?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { 170 }
    
    class func height(text: String) -> CGFloat {
        let width = kScreenWidth - (kCollectionDefaultMargin * 4)
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontBrand.SFregularFont(size: 14),
            .paragraphStyle: paragraphStyle
        ]
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return ceil(boundingBox.height) + 68
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setUpdata(isShowText: Bool = false, model: RatingModel, bussnessImg: String?, bussnessName: String?) {
        isCurrentUser = model.userId == APPSESSION.userDetail?.id
        rattingId = model.ratingId
        userId = model.userId
        _deleteReviewView.isHidden = true
        _userImage.loadWebImage(model.user?.image ?? kEmptyString, name: model.user?.firstName ?? kEmptyString)
        _nameLabel.text = "\(model.user?.firstName ?? "") \(model.user?.lastName ?? "")"
        _reviewLabel.text = model.review
        _ratingView.rating = model.stars
        _dateLabel.text = Utils.dateToStringWithTimezone(model.createdAt, format: kFormatDateReview)
        if model.reply == nil {
            if isShowText {
                _reviewLabel.numberOfLines = 0
            } else {
                _reviewLabel.numberOfLines = 8
            }
            _replyView.isHidden = true
        } else {
            _replyView.isHidden = false
            _reviewLabel.numberOfLines = 3
            _replyBusnessName.text = bussnessName
            _replyImage.loadWebImage(bussnessImg ?? "")
            _replyTextLabel.text = model.reply?.reply
        }
    }
    
    func setupRatingData(_ data: RatingModel, userModel: [UserModel] = [], isFromYach: Bool = false, isFromTicket: Bool = false) {
        isCurrentUser = data.userId == APPSESSION.userDetail?.id
        rattingId = data.ratingId
        userId = data.userId
        _deleteReviewView.isHidden = true//isFromTicket ? !(data.userId == APPSESSION.userDetail?.id) : true
        _ratingView.tintColor = isFromYach ? ColorBrand.brandDarkSky : ColorBrand.brandPink
        ratingModel = data
        _reviewLabel.text = data.review
        _ratingView.rating = data.stars
        _reviewLabel.numberOfLines = 0
        _replyView.isHidden = true
        _dateLabel.text = Utils.dateToStringWithTimezone(data.createdAt, format: kFormatDateReview)
        if let user = Utils.getUserFromId(userModels: userModel, userId: data.userId) {
            _userImage.loadWebImage(user.image, name: user.firstName)
            _nameLabel.text = "\(user.firstName) \(user.lastName)"
        } 
        else if (data.userId == APPSESSION.userDetail?.id) {
            _userImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? "User")
            _nameLabel.text = APPSESSION.userDetail?.fullName ?? "User"
        }
        else {
            _userImage.loadWebImage("", name: "Unknown")
            _nameLabel.text = "Unknown"
        }
    }
    
    func setupRatingProfileData(_ data: RatingModel, userModel: [UserModel] = [], isFromYach: Bool = false, isPublic: Bool = false) {
        _deleteReviewView.isHidden = true
        rattingId = data.ratingId
        userId = data.userId
        _menuBtnView.isHidden = data.userId == APPSESSION.userDetail?.id
        _ratingView.tintColor = ColorBrand.brandPink
        ratingModel = data
        _replyImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _reviewLabel.text = data.review
        _ratingView.rating = data.stars
        _reviewLabel.numberOfLines = 0
        _dateLabel.text = Utils.dateToStringWithTimezone(data.createdAt, format: kFormatDateReview)
        if let user = Utils.getUserFromId(userModels: userModel, userId: data.userId) {
            _userImage.loadWebImage(user.image, name: user.firstName)
            _nameLabel.text = "\(user.firstName) \(user.lastName)"
        } 
        else if (data.userId == APPSESSION.userDetail?.id) {
            _userImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? "User")
            _nameLabel.text = APPSESSION.userDetail?.fullName ?? "User"
        }
        else {
            _userImage.loadWebImage("", name: "Unknown User")
            _nameLabel.text = "Unknown user"
        }
        _replyBtnView.isHidden = isPublic ? true : !Utils.stringIsNullOrEmpty(data.replyString)
        _replyView.isHidden = isPublic ? Utils.stringIsNullOrEmpty(data.replyString) : false
        _replyTextLabel.isHidden = Utils.stringIsNullOrEmpty(data.replyString)
        _replyBusnessName.text = kEmptyString
        _editOptions.isHidden = true
        if !Utils.stringIsNullOrEmpty(data.replyString), isPublic {
            if let user = user {
                _replyImage.loadWebImage(user.image, name: user.fullName)
            } else { _replyImage.loadWebImage("", name: user?.fullName ?? kEmptyString) }
            _replyBusnessName.text = "reply".localized()
            _replyTextLabel.text = data.replyString
        } else if !isPublic, !Utils.stringIsNullOrEmpty(data.replyString) {
            _editOptions.isHidden = Utils.stringIsNullOrEmpty(data.replyString)
            _replyImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
            _replyTextLabel.text = data.replyString
            _replyBusnessName.text = "reply".localized()
        }
    }
    
    func setupCustomTicketReview(_ data: TicketReviewModel, userModel: [UserModel] = [], isCurrentUserReview: Bool = false) {
        isCurrentUser = data.userId == APPSESSION.userDetail?.id
        rattingId = data._id
        userId = data.userId
        _deleteReviewView.isHidden = true//!isCurrentUserReview
        _ratingView.tintColor = ColorBrand.brandPink
        _reviewLabel.text = data.review
        _ratingView.rating = Double(data.stars)
        _reviewLabel.numberOfLines = 0
        _replyView.isHidden = true
        _dateLabel.text = Utils.dateToStringWithTimezone(data.createdAt, format: kFormatDateReview)
        if let user = Utils.getUserFromId(userModels: userModel, userId: data.userId) {
            _userImage.loadWebImage(user.image, name: user.firstName)
            _nameLabel.text = "\(user.firstName) \(user.lastName)"
        } else {
            _userImage.loadWebImage("", name: "Unknown User")
            _nameLabel.text = "Unknown User"
        }
    }
    
    func openAlert(_ text: String = kEmptyString) {
        let alertController = UIAlertController(title: "write_a_reply".localized(), message: nil, preferredStyle: .alert)

        let textViewContainer = UIView()
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        let textView = UITextView()
        textView.text = text
        textView.font = FontBrand.SFregularFont(size: 14)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5.0

        textViewContainer.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),
            textView.heightAnchor.constraint(equalToConstant: 60)
        ])

        alertController.view.addSubview(textViewContainer)
        
        NSLayoutConstraint.activate([
            textViewContainer.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            textViewContainer.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 10),
            textViewContainer.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -10),
            textViewContainer.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -50),
            textViewContainer.heightAnchor.constraint(equalToConstant: 60)
        ])

        let submitAction = UIAlertAction(title: "submit".localized(), style: .default) { _ in
            let userInput = textView.text
            if Utils.stringIsNullOrEmpty(userInput) {
                self.parentBaseController?.alert(message: "enter_your_text".localized())
                return
            }
            if text.isEmpty {
                self._writeReplay(userInput ?? kEmptyString)
            } else {
                self._writeReplay(userInput ?? kEmptyString)
            }
        }
        
        alertController.addAction(submitAction)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertController.view.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }

    
    private func _writeReplay(_ text: String) {
        guard let id = rattingId else { return }
        WhosinServices.ratingReply(reviewId: id, reply: text) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.parentViewController?.showToast(message) }
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)            
        }
    }
    
    private func _deleteReplay() {
        guard let id = rattingId else { return }
        WhosinServices.ratingReviewReplyDelete(reviewId: id) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.parentViewController?.showToast(message) }
            self._replyTextLabel.text = kEmptyString
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
    
    private func _deleteReview() {
        guard let id = rattingId else { return }
        WhosinServices.reviewReplyDelete(reviewId: id) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message { self.parentViewController?.showToast(message) }
            NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
        }
    }
    
    private func _requestReportUser(userId: String, reason: String, msg: String) {
        self.parentBaseController?.showHUD()
        let params: [String: Any] = [
            "userId": userId,
            "message": msg,
            "reason": reason,
            "type": "review",
            "typeId": rattingId ?? ""
        ]
        WhosinServices.addReportUser(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            if !Preferences.blockedUsers.contains(userId) {
                Preferences.blockedUsers.append(userId)
            }
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_reported".localized() +  "\(self.user?.fullName ?? "")")
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
                NotificationCenter.default.post(name: .openReportSuccessCard, object: nil)
            }
        }
    }
    
    private func _requestBlockUser(blockId: String) {
        self.parentBaseController?.showHUD()
        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_blocked".localized() + "\(self.user?.fullName ?? "")")
            if !Preferences.blockedUsers.contains(blockId) {
                Preferences.blockedUsers.append(blockId)
            } 
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
            }
        }
    }
    
    @IBAction func _handleDeleteEvent(_ sender: UIButton) {
        self.parentBaseController?.confirmAlert(message: "delete_reply_alert".localized(), okHandler: { action in
            self._deleteReplay()
        })
    }
    
    @IBAction private func _handleReportEvent(_ sender: UIButton) {
        if isCurrentUser, let vc = parentBaseController {
            showActionSheet(from: vc)
        } else {
            _optionsBottomSheet()
        }
    }
    
    func showActionSheet(from viewController: UIViewController) {
        let actionSheet = UIAlertController(title: kAppName, message: "", preferredStyle: .actionSheet)

        let option1 = UIAlertAction(title: "delete".localized(), style: .default) { _ in
            self.parentBaseController?.confirmAlert(message: "delete_review_confirm".localized(), okHandler: { action in
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
                self.parentBaseController?.alert(title: kAppName, message: LANGMANAGER.localizedString(forKey: "block_user_alert", arguments: ["value": self.user?.fullName ?? ""]), okActionTitle: "yes".localized()) { UIAlertAction in
                    self._requestBlockUser(blockId: self.userId ?? "")
                } cancelHandler: { UIAlertAction in
                    self.parentBaseController?.dismiss(animated: true)
                }
            case "both":
                openReport(type)
            default :
                return
            }
        }
        self.parentBaseController?.presentAsPanModal(controller: controller)
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
        self.parentBaseController?.presentAsPanModal(controller: vc)

    }
    
    @IBAction private func _handleReplayBtnEvent(_ sender: CustomButton) {
        openAlert(Utils.stringIsNullOrEmpty(_replyTextLabel.text) ? kEmptyString : _replyTextLabel.text ?? kEmptyString)
    }
    
    @IBAction private func _handleDeleteMyRatingEvent(_ sender: UIButton) {
        self.parentBaseController?.confirmAlert(message: "delete_review_confirm".localized(), okHandler: { action in
            self._deleteReview()
        })
    }
    
}
