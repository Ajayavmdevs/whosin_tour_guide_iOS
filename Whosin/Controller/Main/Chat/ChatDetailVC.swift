import UIKit
import PanModal
import SDWebImage
import SwiftUI
import GrowingTextView
import ObjectMapper
import IQKeyboardManagerSwift

class ChatDetailVC: ChildViewController {
    
    @IBOutlet weak var _menuBtn: UIButton!
    @IBOutlet weak var _onlyOwnerTxt: CustomLabel!
    @IBOutlet private weak var _messageView: UIView!
    @IBOutlet private weak var _openCameraButton: UIButton!
    @IBOutlet private weak var _sendButton: UIButton!
    @IBOutlet private weak var _voiceChatButton: UIButton!
    @IBOutlet private weak var _headerView: UIView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _bottomVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _textieldView: UIView!
    @IBOutlet private weak var _messageTextView: GrowingTextView!
    @IBOutlet private var matchedOnTimeLbl: UIView!
    @IBOutlet private weak var _statuslbl: UILabel!
    @IBOutlet private weak var _profileImage: UIImageView!
    @IBOutlet private weak var _chatTableView: UITableView!
    @IBOutlet private weak var _chatUserNameLbl: UILabel!
    @IBOutlet private weak var _bgImage: UIImageView!
    @IBOutlet private weak var _scrollDownButton: UIButton!
    @IBOutlet private weak var _unReadMsgCountLbl: UILabel!
    @IBOutlet weak var _eventView: UIView!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _viewTicketButton: CustomButton!
    @IBOutlet weak var _loadingButton: CustomActivityButton!
    
    private let kCoptitorMessageCellIdentifire = String(describing: CompititorMessageCell.self)
    private let kOwnMessageCellIdentifire = String(describing: OwnMessageCell.self)
    private let kOwnImageCellIdentifire = String(describing: OwnImageCell.self)
    private let kComptitorImageCellIdentifire = String(describing: CompititorImageCell.self)
    private let kEventCellIdentifire = String(describing: CompititorImageCell.self)
    private let kOwnAudioCellIdentifire = String(describing: OwnAudioChatCell.self)
    private let kCoptitorAudioCellIdentifire = String(describing: CompititorAudioChatCell.self)
    private let kOwnVenueCell = String(describing: OwnVenueCell.self)
    private let kComptitorVenueCell = String(describing: CompititorVenueCell.self)
    private let kOwnStoryCell = String(describing: OwnStoryCell.self)
    private let kComptitorStoryCell = String(describing: CompititorStoryCell.self)
    private let kOwnUserCell = String(describing: OwnContactShareCell.self)
    private let kComptitorUserCell = String(describing: CompititorContactShareCell.self)
    private let kOwnOfferCell = String(describing: OwnOfferCell.self)
    private let kComptitorOfferCell = String(describing: CompititorOfferCell.self)
    private let kOwnYachtOfferCell = String(describing: OwnYachtOfferCell.self)
    private let kComptitorYachtOfferCell = String(describing: CompititorYachtOfferCell.self)
    private let kOwnYachtClubCell = String(describing: OwnYachtClubCell.self)
    private let kComptitorYachtClubCell = String(describing: CompititorYachtClubCell.self)
    private let kOwnPromoterEventCell = String(describing: OwnPromoterEventCell.self)
    private let kCompetitiorPromoterEventCell = String(describing: CompititorPromoterEventCell.self)
    private let kCompetitiorReplyPromoterEventCell = String(describing: CompititorReplyPromoterEventCell.self)
    private let kOwnReplyPromoterEventCell = String(describing: OwnReplyPromoterEventCell.self)
    private let kCMReplyPromoterEventCell = String(describing: CompititorReplyTicketCell.self)
    private let kOwnReplyTicketCell = String(describing: OwnReplyTicketCell.self)
    private let kOwnTicketCell = String(describing: OwnTicketCell.self)
    private let kCompititorTicketCell = String(describing: CompititorTicketCell.self)
    
    private var isViewVisible: Bool = false
    private var _msgList: [MessageModel] = []
    private var _isUpdating = false
    
    
    private var imagePicker = UIImagePickerController()
    private var recordButton = RecordButton()
    @IBOutlet private weak var bottomConatraint: NSLayoutConstraint!
    private var timer : Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }
    
    private var _timerForTyping: Timer?
    private var _page: Int = 0
    public var chatModel: ChatModel?
    public var chatType: ChatType = .user
    public var outingmodel: OutingListModel?
    public var isFromPromoter: Bool = false
    public var isPromoter: Bool = false
    public var isComplementry: Bool = false
    public var venueName: String = kEmptyString
    public var venueImage: String = kEmptyString
    private var cmEventDetail: PromoterEventsModel?
    private let chatRepository = ChatRepository()
    public var _eventChatJSON: String = kEmptyString
    public var ticketChatJSON: String = kEmptyString
    
    private var _currentTypingModel: TypingEventModel?
    
    private let currentUser = APPSESSION.userDetail
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        checkSession()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._messageView.addGradientBorderWithColor(cornerRadius: 20, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
            self._eventView.cornerRadius = 15.0
            self._eventView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMsgNotification(_:)), name: kMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateNewMsgNotification(_:)), name: kUpdateMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTypingNotification(_:)), name: kTypingNotification, object: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    override func setupUi() {
        hideNavigationBar()
        if #available(iOS 15.0, *) { _chatTableView.sectionHeaderTopPadding = 0 }
        recordButton = _voiceChatButton.setUpAudioRecordButton(slideToCancelTextColor: ColorBrand.brandPink, durationTimerColor: ColorBrand.white, view: _textieldView, delegate: self)
        if chatModel?.chatType == ChatType.promoterEvent.rawValue, isPromoter {
            _profileImage.loadWebImage(venueImage, name: venueName)
            _chatUserNameLbl.text = venueName
        } else {
            _profileImage.loadWebImage(chatModel?.image ?? kEmptyString, name: chatModel?.title ?? kEmptyString)
            if chatModel?.chatType == "outing" || chatModel?.chatType == "event" {
                _chatUserNameLbl.attributedText = chatModel?.title.createAttributedString()
            } else {
                _chatUserNameLbl.text = chatModel?.title
            }
        }
        
        _registerTableCells()
        
        if isPromoter {
            _textieldView.isHidden = !isPromoter
            _onlyOwnerTxt.isHidden = isPromoter
        } else if isComplementry {
            _textieldView.isHidden = !isPromoter
            _onlyOwnerTxt.isHidden = isPromoter
            _eventView.isHidden = isPromoter
            _venueName.text = venueName
            _venueImage.loadWebImage(venueImage)
        } else {
            _onlyOwnerTxt.isHidden = true
        }
        _chatTableView.delegate = self
        _chatTableView.dataSource = self
        _messageTextView.delegate = self
        _visualEffectView.alpha = 1
        _bottomVisualEffectView.alpha = 1
        
        if isComplementry {
            _requestComplementaryEventDetail()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        _chatTableView.addGestureRecognizer(tapGesture)
        _menuBtn.isHidden = !(chatModel?.chatType == "friend")
        guard let userDetail = APPSESSION.userDetail else { return }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        let userId = chatModel?.detached().members.first(where: { $0 != id})
        if Preferences.blockedUsers.contains(userId ?? "") {
            _textieldView.isHidden = true
            _onlyOwnerTxt.isHidden = false
            _onlyOwnerTxt.text = LANGMANAGER.localizedString(forKey: "blocked_unblock_to_send_message", arguments: ["value": chatModel?.title ?? ""])
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func _registerTableCells() {
        _chatTableView.register(UINib(nibName: kCoptitorMessageCellIdentifire, bundle: nil), forCellReuseIdentifier: kCoptitorMessageCellIdentifire)
        _chatTableView.register(UINib(nibName: kOwnMessageCellIdentifire, bundle: nil), forCellReuseIdentifier: kOwnMessageCellIdentifire)
        _chatTableView.register(UINib(nibName: kOwnImageCellIdentifire, bundle: nil), forCellReuseIdentifier: kOwnImageCellIdentifire)
        _chatTableView.register(UINib(nibName: kComptitorImageCellIdentifire, bundle: nil), forCellReuseIdentifier: kComptitorImageCellIdentifire)
        _chatTableView.register(UINib(nibName: kOwnAudioCellIdentifire, bundle: nil), forCellReuseIdentifier: kOwnAudioCellIdentifire)
        _chatTableView.register(UINib(nibName: kCoptitorAudioCellIdentifire, bundle: nil), forCellReuseIdentifier: kCoptitorAudioCellIdentifire)
        _chatTableView.register(UINib(nibName: kOwnVenueCell, bundle: nil), forCellReuseIdentifier: kOwnVenueCell)
        _chatTableView.register(UINib(nibName: kComptitorVenueCell, bundle: nil), forCellReuseIdentifier: kComptitorVenueCell)
        _chatTableView.register(UINib(nibName: kOwnStoryCell, bundle: nil), forCellReuseIdentifier: kOwnStoryCell)
        _chatTableView.register(UINib(nibName: kComptitorStoryCell, bundle: nil), forCellReuseIdentifier: kComptitorStoryCell)
        _chatTableView.register(UINib(nibName: kOwnUserCell, bundle: nil), forCellReuseIdentifier: kOwnUserCell)
        _chatTableView.register(UINib(nibName: kComptitorUserCell, bundle: nil), forCellReuseIdentifier: kComptitorUserCell)
        _chatTableView.register(UINib(nibName: kOwnOfferCell, bundle: nil), forCellReuseIdentifier: kOwnOfferCell)
        _chatTableView.register(UINib(nibName: kComptitorOfferCell, bundle: nil), forCellReuseIdentifier: kComptitorOfferCell)
        _chatTableView.register(UINib(nibName: kOwnYachtOfferCell, bundle: nil), forCellReuseIdentifier: kOwnYachtOfferCell)
        _chatTableView.register(UINib(nibName: kComptitorYachtOfferCell, bundle: nil), forCellReuseIdentifier: kComptitorYachtOfferCell)
        _chatTableView.register(UINib(nibName: kOwnYachtClubCell, bundle: nil), forCellReuseIdentifier: kOwnYachtClubCell)
        _chatTableView.register(UINib(nibName: kComptitorYachtClubCell, bundle: nil), forCellReuseIdentifier: kComptitorYachtClubCell)
        _chatTableView.register(UINib(nibName: kOwnPromoterEventCell, bundle: nil), forCellReuseIdentifier: kOwnPromoterEventCell)
        _chatTableView.register(UINib(nibName: kCompetitiorPromoterEventCell, bundle: nil), forCellReuseIdentifier: kCompetitiorPromoterEventCell)
        _chatTableView.register(UINib(nibName: kCompetitiorReplyPromoterEventCell, bundle: nil), forCellReuseIdentifier: kCompetitiorReplyPromoterEventCell)
        _chatTableView.register(UINib(nibName: kOwnReplyPromoterEventCell, bundle: nil), forCellReuseIdentifier: kOwnReplyPromoterEventCell)
        _chatTableView.register(UINib(nibName: kOwnReplyTicketCell, bundle: nil), forCellReuseIdentifier: kOwnReplyTicketCell)
        _chatTableView.register(UINib(nibName: kOwnTicketCell, bundle: nil), forCellReuseIdentifier: kOwnTicketCell)
        _chatTableView.register(UINib(nibName: kCompititorTicketCell, bundle: nil), forCellReuseIdentifier: kCompititorTicketCell)
        _chatTableView.register(UINib(nibName: kCMReplyPromoterEventCell, bundle: nil), forCellReuseIdentifier: kCMReplyPromoterEventCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        _chatTableView.reloadData()
        _chatTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        IQKeyboardManager.shared.enable = false
        getChatMessage()
        guard let chatId = chatModel?.chatId else { return }
        let bgList = Preferences.chatWallpapers
        
        if let dict = bgList.first(where: { $0.keys.contains(chatId) }) {
            if let imgData = dict[chatId] as? Data {
                _bgImage.image = UIImage(data: imgData)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kUpdateMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kTypingNotification, object: nil)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _startTableViewUpdates() {
        guard !_isUpdating else { return } // Prevent multiple beginUpdates calls
        _isUpdating = true
        _chatTableView.beginUpdates()
    }
    
    private func _endTableViewUpdates() {
        guard _isUpdating else { return } // Only end updates if they were started
        _chatTableView.endUpdates()
        _isUpdating = false
    }
    
    private func _openMediaPicker(_ sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            self.showCustomAlert(title: "warning".localized(), message: "you_dont_have_access_of_source".localized(), yesButtonTitle: "ok".localized(), noButtonTitle: kEmptyString) { UIAlertAction in
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        guard self.timer == nil else { return }
        _statuslbl.isHidden = false
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.stopTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
        self._statuslbl.isHidden = true
    }
    
    private func hideUnHideView(isHidden: Bool) {
        _messageTextView.isHidden = isHidden
        _openCameraButton.isHidden = isHidden
        _messageView.isHidden = isHidden
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    func filterConcurrently(_ array: [MessageModel]) {
        guard let userDetail = APPSESSION.userDetail  else {
            return
        }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        let queue = DispatchQueue.global(qos: .userInitiated) // Use a background thread for filtering
        queue.async {
            let unSeens = array.filter { !$0.isSent(id) && !$0.seenBy.contains(id)}
            DispatchQueue.main.async {
                if !unSeens.isEmpty {
                    SOCKETMANAGER.sendSeenEvent(msgs: unSeens)
                }
            }
        }
    }
    
    private func getChatMessage() {
        isRequesting = true
        guard let chatId = chatModel?.chatId else { return }
        chatRepository.getChatMessages(chatId: chatId) { [weak self] container  in
            guard let self = self else { return }
            guard let data = container else { return }
            if _page == 0 {
                self._msgList = data
            } else {
                self._msgList.append(contentsOf: data)
            }
            filterConcurrently(data)
            self.isRequesting = false
            self._chatTableView.reloadData()
        }
    }
    
    private func getNewMessages() {
        guard let msgModel = self._msgList.last else { return }
        chatRepository.getNewMessage(model: msgModel) { [weak self] model in
            guard let self = self else { return }
            guard let data = model else { return }
            self._msgList.insert(contentsOf: data, at: 0)
            var indexs: [IndexPath] = []
            var i = 0
            data.forEach { d in
                let newRowIndexPath = IndexPath(row: i, section: 0)
                indexs.append(newRowIndexPath);
                i = i + 1
            }
            self._startTableViewUpdates()
            self._chatTableView.insertRows(at: indexs, with: .none)
            self._endTableViewUpdates()
            filterConcurrently(data)
        }
    }
    
    private func updateMessageList(updatedList: [MessageModel]) {
        var indexs: [IndexPath] = []
        for updatedMessage in updatedList {
            if let index = self._msgList.firstIndex(where: { $0.id == updatedMessage.id }) {
                _msgList[index] = updatedMessage
                let newRowIndexPath = IndexPath(row: index, section: 0)
                indexs.append(newRowIndexPath);
            }
        }
        if _chatTableView.numberOfRows(inSection: 0) < 1 {
            getChatMessage()
            return
        }
        _startTableViewUpdates()
        _chatTableView.reloadRows(at: indexs, with: .none)
        _endTableViewUpdates()
        
    }
    
    private func updateMessages(_ msgIds:[String]) {
        chatRepository.updateNewMessage(msgIds: msgIds){ [weak self] model in
            guard let self = self else { return }
            guard let data = model else { return }
            updateMessageList(updatedList: data)
            filterConcurrently(data)
        }
    }
    
    private func _requestUploadFile(_ urlString: URL, msgType: MessageType = .audio) {
        guard let _chatModel = self.chatModel else { return }
        let replyToModel = ReplyToModel()
        if !Utils.stringIsNullOrEmpty(_eventChatJSON) {
            replyToModel.id = Utils.generateMessageId("\(_eventChatJSON.hashValue)")
            replyToModel.type = "Prmoter-event"
            replyToModel.data = _eventChatJSON
        }
        if !Utils.stringIsNullOrEmpty(ticketChatJSON) {
            replyToModel.id = Utils.generateMessageId("\(ticketChatJSON.hashValue)")
            replyToModel.type = "ticket"
            replyToModel.data = ticketChatJSON
        }
        let msgModel = MessageModel(msg: urlString.absoluteString, chatModel: _chatModel, type: msgType.rawValue, replyTo: Utils.stringIsNullOrEmpty(_eventChatJSON) ? Utils.stringIsNullOrEmpty(ticketChatJSON) ? nil : replyToModel : replyToModel)
        let _duretion = Utils.getAudioDuration(filePath: urlString.absoluteString)
        if _duretion > 0 {
            msgModel.audioDuration = Utils.getStringInMinuteAndSecond(durationInSecond: Int(_duretion))
        }
        let tmp = msgModel.detached()
        _msgList.insert(tmp, at: 0)
        
        let newRowIndexPath = IndexPath(row: 0, section: 0)
        _startTableViewUpdates()
        _chatTableView.insertRows(at: [newRowIndexPath], with: .none)
        _endTableViewUpdates()
        
        chatRepository.addChatMessage(messageData: msgModel) { model in
            guard let _model = model?.detached() else { return }
            WhosinServices.uploadFile(fileUrl: urlString) { [weak self] container , error in
                guard let self = self else { return }
                self.hideHUD(error: error)
                guard let photoUrl = container?.data else { return }
                _model.msg = photoUrl
                if msgType == .image {
                    SDWebImagePrefetcher.shared.prefetchURLs([URL(string: photoUrl)!])
                }
                self.chatRepository.addChatMessage(messageData: _model) { newModel in
                    guard let _newModel = newModel?.detached() else { return }
                    self._eventChatJSON = kEmptyString
                    self.ticketChatJSON = kEmptyString
                    SOCKETMANAGER.sendMessage(model: _newModel)
                }
                
            }
        }
    }
    
    private func _requestComplementaryEventDetail(_ isLoading: Bool = false) {
        guard let id = chatModel?.chatId else { return }
        _venueImage.isHidden = true
        _venueName.isHidden = true
        _viewTicketButton.isHidden = true
        _loadingButton.showActivity()
        WhosinServices.getComplementaryEventDetail(eventId: id) { [weak self] container, error in
            guard let self = self else { return }
            _loadingButton.hideActivity()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.cmEventDetail = data
            _venueName.isHidden = false
            _venueImage.isHidden = false
            _venueName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
            _venueImage.loadWebImage(data.venueType == "venue" ? data.venue?.slogo  ?? kEmptyString : data.customVenue?.image ?? kEmptyString)
            if data.invite?.promoterStatus == "accepted" && data.invite?.inviteStatus == "in" {
                _viewTicketButton.isHidden = false
            } else {
                _viewTicketButton.isHidden = true
            }
        }
    }
    
    private func _requestReportUser(userId: String, reason: String, msg: String) {
        showHUD()
        let params: [String: Any] = [
            "userId": userId,
            "message": msg,
            "reason": reason,
            "type": "chat",
            "typeId": chatModel?.lastMsg?.id ?? ""
        ]
        WhosinServices.addReportUser(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            if !Preferences.blockedUsers.contains(userId) {
                Preferences.blockedUsers.append(userId)
            }
            self.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_reported" + "\(self.venueName)")
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                NotificationCenter.default.post(name: .openReportSuccessCard, object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func _requestBlockUser(blockId: String) {
        showHUD()
        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            self.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_blocked".localized() + "\(self.venueName)")
            if !Preferences.blockedUsers.contains(blockId) {
                Preferences.blockedUsers.append(blockId)
            }
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func _unBlockUser(_ id: String) {
        showHUD()
        WhosinServices.unblockUser(blockId: id) { [weak self] container, error in
            guard let self = self else { return}
            self.hideHUD()
            guard let data = container else { return }
            Preferences.blockedUsers.removeAll(where: { $0 == id})
            guard let _chatModel = self.chatModel else { return }
            self.showSuccessMessage("\(_chatModel.title)" + "has_been_unblocked".localized(), subtitle: "")
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kUpdateMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kTypingNotification, object: nil)
        if self.isPresented {
            dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func _handleProfileEvent(_ sender: UIButton) {
        guard let _chatModel = self.chatModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        if _chatModel.chatType == ChatType.promoterEvent.rawValue, APPSESSION.userDetail?.isPromoter == true {
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.id = _chatModel.chatId
            vc.isComplementary = false
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if _chatModel.chatType != ChatType.promoterEvent.rawValue {
            let controller = INIT_CONTROLLER_XIB(ChatProfileVC.self)
            let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
            if chatType == .user || chatType == .promoterEvent {
                let userId = _chatModel.detached().members.first(where: { $0 != id})
                controller.userId = userId
            }
            if chatType == .outing {
                controller._outingModel = self.outingmodel
            }
            controller.chatModel = _chatModel.detached()
            controller.chatType = chatType
            if self.isPresented {
                let navControll = NavigationController(rootViewController: controller)
                navControll.modalPresentationStyle = .fullScreen
                self.present(navControll, animated: true, completion: nil)
            }else {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction private func _handleshowShareItemButtonEvent(_ sender: UIButton) {
        _messageTextView.resignFirstResponder()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraOption = UIAlertAction(title: "camera".localized(), style: .default) { _ in
            self._openMediaPicker(.camera)
        }
        
        let galleryOption = UIAlertAction(title: "photo_library".localized(), style: .default) { _ in
            self._openMediaPicker(.savedPhotosAlbum)
        }
        
        cameraOption.setValue(UIImage(named: "icon_camera_line"), forKey: "image")
        cameraOption.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        galleryOption.setValue(UIImage(named: "icon_gallery_line"), forKey: "image")
        galleryOption.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel)
        actionSheet.addAction(cameraOption)
        actionSheet.addAction(galleryOption)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction private func _handleSendMessageEvent(_ sender: UIButton) {
        guard let _chatModel = chatModel else { return }
        if _messageTextView.text.trim.isEmpty { return }
        let replyById = Preferences.isSubAdmin ? APPSESSION.userDetail?.id ?? kEmptyString : kEmptyString
        let msgText = _messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if msgText.isEmpty { return }
        let replyToModel = ReplyToModel()
        if !Utils.stringIsNullOrEmpty(_eventChatJSON) {
            replyToModel.id = Utils.generateMessageId("\(_eventChatJSON.hashValue)")
            replyToModel.type = "Prmoter-event"
            replyToModel.data = _eventChatJSON
        }
        if !Utils.stringIsNullOrEmpty(ticketChatJSON) {
            replyToModel.id = Utils.generateMessageId("\(ticketChatJSON.hashValue)")
            replyToModel.type = "ticket"
            replyToModel.data = ticketChatJSON
        }
        let msgModel = MessageModel(msg: msgText, chatModel: _chatModel, replyBy: replyById, replyTo: Utils.stringIsNullOrEmpty(_eventChatJSON) ? Utils.stringIsNullOrEmpty(ticketChatJSON) ? nil : replyToModel : replyToModel )
        DISPATCH_ASYNC_MAIN {
            let detachedMessage = msgModel.detached()
            if self._msgList.isEmpty {
                self._msgList.insert(detachedMessage, at: 0)
                self._chatTableView.reloadData()
            } else {
                self._msgList.insert(detachedMessage, at: 0)
                let newRowIndexPath = IndexPath(row: 0, section: 0)
                self._chatTableView.performBatchUpdates {
                    self._chatTableView.insertRows(
                        at: [newRowIndexPath],
                        with: .automatic
                    )
                }
            }
//            if self._msgList.isEmpty == false {
//                self._msgList.insert(detachedMessage, at: 0)
//                let newRowIndexPath = IndexPath(row: 0, section: 0)
//                self._chatTableView.performBatchUpdates {
//                    self._chatTableView.insertRows(at: [newRowIndexPath], with: .automatic)
//                }
//            } else {
//                self._msgList.insert(msgModel.detached(), at: 0)
//            }
        }
        chatRepository.addChatMessage(messageData: msgModel.detached()) {[weak self] error in
            guard let self = self else { return }
            SOCKETMANAGER.sendMessage(model: msgModel.detached())
            self._eventChatJSON = kEmptyString
            self.ticketChatJSON = kEmptyString
        }
        _messageTextView.text = kEmptyString
        _sendButton.isHidden = !_messageTextView.hasText
        _voiceChatButton.isHidden = _messageTextView.hasText
        recordButton.isHidden = _messageTextView.hasText
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._messageView.addGradientBorderWithColor(cornerRadius: 20, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
        }
    }
    
    @IBAction private func _handleScrollDownEvent(_ sender: UIButton) {
        guard !_msgList.isEmpty else { return }
        DISPATCH_ASYNC_MAIN { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) { self._chatTableView.scrollToRow(at: indexPath, at: .top, animated: true) }
        }
    }
    
    @IBAction func _handleOpenEventView(sender: UIButton) {
        guard let model = chatModel else { return }
        let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        vc.id = model.chatId
        vc.isComplementary = true
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func _handleViewTicketEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(CMConfirmedEventVC.self)
        vc.eventModel = cmEventDetail
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func _handleMenuOptionEvent(_ sender: UIButton) {
        _optionsBottomSheet()
    }
    
    private func _optionsBottomSheet() {
        guard let _chatModel = self.chatModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        _messageTextView.resignFirstResponder()
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        let userId = _chatModel.detached().members.first(where: { $0 != id})
        let isBlocked = Preferences.blockedUsers.contains(userId ?? "")
        let controller = INIT_CONTROLLER_XIB(ReportOptionsSheet.self)
        controller.isUserBlocked = isBlocked
        controller.didUpdateCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case "report" :
                openReport(type)
            case "block":
                alert(title: kAppName, message:isBlocked ? "do_you_want_to_unblock".localized() + "\(_chatModel.title)?" : LANGMANAGER.localizedString(forKey: "block_user_alert", arguments: ["value": _chatModel.title]), okActionTitle: "yes".localized()) { UIAlertAction in
                    if isBlocked {
                        self._unBlockUser(userId ?? "")
                    } else {
                        self._requestBlockUser(blockId: userId ?? "")
                    }
                } cancelHandler: { UIAlertAction in
                    self.dismiss(animated: true)
                }
            case "both":
                openReport(type)
            default :
                return
            }
        }
        if controller is PanModalPresentable {
            presentPanModal(controller)
        } else {
            self.presentAsPanModal(controller: controller)
        }

    }
    
    private func openReport(_ type: String) {
        guard let _chatModel = self.chatModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        let userId = _chatModel.detached().members.first(where: { $0 != id})
        let vc = INIT_CONTROLLER_XIB(ReportBottomSheet.self)
        vc.type = type
        vc.didUpdateCallback = { [weak self] type, reason, msg in
            guard let self = self else { return }
            if type == "both" {
                _requestBlockUser(blockId: userId ?? "")
                _requestReportUser(userId: userId ?? "", reason: reason, msg:msg )
            } else {
                self._requestReportUser(userId: userId ?? "", reason: reason, msg: msg)
            }
        }
        self.presentAsPanModal(controller: vc)
        
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.row < _chatTableView.numberOfRows(inSection: indexPath.section)
    }
    
    // --------------------------------------
    // MARK: Notification Event
    // --------------------------------------
    
    @objc func handleTypingNotification(_ notification: Notification) {
        guard let model = notification.object as? TypingEventModel else { return }
        if model.chatId == chatModel?.chatId && model.isForStartTyping {
            _currentTypingModel = model
            _statuslbl.text = "\(model.userName)" + "typing".localized()
            _statuslbl.isHidden = false
            startTimer()
        } else if _currentTypingModel?.userId == model.userId {
            _statuslbl.text = ""
            _statuslbl.isHidden = true
        }
    }
    
    @objc func handleNewMsgNotification(_ notification: Notification) {
        if let chatId = notification.userInfo?["chatId"] as? String {
            if chatId == chatModel?.chatId {
                let msgModel = _msgList.filter({ $0.chatId == chatId })
                let msdIds = msgModel.map { $0.id }
                
                if let msgs = notification.userInfo?["id"] as? [String] {
                    
                    if msgs.contains(where: msdIds.contains) {
                        updateMessages(msdIds)
                    } else {
                        getNewMessages()
                    }
                    
                    if !self._scrollDownButton.isHidden {
                        if var newCount: Int = Int(self._unReadMsgCountLbl.text ?? "0") {
                            newCount += msgs.count
                            self._unReadMsgCountLbl.text = "\(newCount)"
                            self._unReadMsgCountLbl.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleUpdateNewMsgNotification(_ notification: Notification) {
        if let chatId = notification.userInfo?["chatId"] as? String {
            if chatId == chatModel?.chatId {
                if notification.object is [MessageModel] {
                    DISPATCH_ASYNC_BG {
                        let msgModel = self._msgList.filter({ $0.chatId == chatId })
                        let msdIds = msgModel.map { $0.id }
                        DISPATCH_ASYNC_MAIN {
                            self.updateMessages(msdIds)
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.bottomConatraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.bottomConatraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// --------------------------------------
// MARK: TableView Delegate,DataSource
// --------------------------------------

extension ChatDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _msgList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = _msgList[indexPath.row]
        let id = Preferences.isSubAdmin ? currentUser?.promoterId : currentUser?.id
        if  model.isSent(id ?? "") {
            if model.replyTo?.type == "Prmoter-event" {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnReplyPromoterEventCell, for: indexPath) as! OwnReplyPromoterEventCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if model.replyTo?.type == "ticket" {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnReplyTicketCell, for: indexPath) as! OwnReplyTicketCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.image.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnImageCellIdentifire, for: indexPath) as! OwnImageCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.audio.rawValue){
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnAudioCellIdentifire,for: indexPath) as! OwnAudioChatCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.venue.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnVenueCell,for: indexPath) as! OwnVenueCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.story.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnStoryCell,for: indexPath) as! OwnStoryCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.user.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnUserCell,for: indexPath) as! OwnContactShareCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.offer.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnOfferCell,for: indexPath) as! OwnOfferCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.yacht.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnYachtOfferCell,for: indexPath) as! OwnYachtOfferCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.yachtClub.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnYachtClubCell,for: indexPath) as! OwnYachtClubCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.promoterEvent.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnPromoterEventCell,for: indexPath) as! OwnPromoterEventCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.ticket.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnTicketCell,for: indexPath) as! OwnTicketCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kOwnMessageCellIdentifire, for: indexPath) as! OwnMessageCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            }
        } else {
            if model.replyTo?.type == "Prmoter-event" {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCompetitiorReplyPromoterEventCell,for: indexPath) as! CompititorReplyPromoterEventCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if model.replyTo?.type == "ticket" {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCMReplyPromoterEventCell,for: indexPath) as! CompititorReplyTicketCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.image.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorImageCellIdentifire, for: indexPath) as! CompititorImageCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            }else if (model.type == MessageType.audio.rawValue){
                let cell = tableView.dequeueReusableCell(withIdentifier: kCoptitorAudioCellIdentifire,for: indexPath) as! CompititorAudioChatCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.venue.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorVenueCell,for: indexPath) as! CompititorVenueCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.story.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorStoryCell,for: indexPath) as! CompititorStoryCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.user.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorUserCell,for: indexPath) as! CompititorContactShareCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.offer.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorOfferCell,for: indexPath) as! CompititorOfferCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.yacht.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorYachtOfferCell,for: indexPath) as! CompititorYachtOfferCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.yachtClub.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kComptitorYachtClubCell,for: indexPath) as! CompititorYachtClubCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.promoterEvent.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCompetitiorPromoterEventCell,for: indexPath) as! CompititorPromoterEventCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else if (model.type == MessageType.ticket.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCompititorTicketCell,for: indexPath) as! CompititorTicketCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: kCoptitorMessageCellIdentifire, for: indexPath) as! CompititorMessageCell
                cell.setup(model)
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = _msgList[indexPath.row]
        if (model.type == MessageType.venue.rawValue) {
            guard let venueModel = Mapper<VenueDetailModel>().map(JSONString: model.msg) else { return }
            let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            controller.venueId = venueModel.id
            controller.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: venueModel.id)
            self.navigationController?.pushViewController(controller, animated: true)
        } else if model.type == MessageType.user.rawValue {
            guard let userModel = Mapper<UserDetailModel>().map(JSONString: model.msg), let userDetail = APPSESSION.userDetail else { return }
            if APPSESSION.userId == userModel.id {
                let controller = NavigationController(rootViewController: INIT_CONTROLLER_XIB(ProfileVC.self))
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true, completion: nil)
            } else {
                if userModel.isPromoter, userDetail.isRingMember {
                    let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                    vc.promoterId = userModel.id
                    vc.isFromPersonal = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if userModel.isRingMember, userDetail.isPromoter {
                    let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                    vc.complimentryId = userModel.id
                    vc.isFromPersonal = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let controller = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                    controller.contactId = userModel.id
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else if model.type == MessageType.offer.rawValue {
            guard let offerModel = Mapper<OffersModel>().map(JSONString: model.msg) else { return }
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.offerId = offerModel.id
            vc.venueModel = offerModel.venue
            vc.timingModel = offerModel.venue?.timing.toArrayDetached(ofType: TimingModel.self)
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            vc.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: vc)
        } else if model.type == MessageType.yacht.rawValue {
            guard let offerModel = Mapper<YachtOfferDetailModel>().map(JSONString: model.msg) else { return }
            let vc = INIT_CONTROLLER_XIB(YachtOfferDetailVC.self)
            vc.offerId = offerModel.id
            vc.yachDetailModel = offerModel
            self.navigationController?.pushViewController(vc, animated: true)
        } else if model.type == MessageType.yachtClub.rawValue {
            guard let model = Mapper<YachtClubModel>().map(JSONString: model.msg) else { return }
            let vc = INIT_CONTROLLER_XIB(YachtClubDetailVC.self)
            vc.yachtClubId = model.id
            vc.yachDetailModel = model
            self.navigationController?.pushViewController(vc, animated: true)
        } else if model.type == MessageType.promoterEvent.rawValue {
            guard let model = Mapper<PromoterEventsModel>().map(JSONString: model.msg) else { return }
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.isComplementary = APPSESSION.userDetail?.isRingMember ?? true
            vc.id = model.eventId
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }  else if model.type == MessageType.ticket.rawValue {
            guard let model = Mapper<TicketModel>().map(JSONString: model.msg) else { return }
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = model._id
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //        else if model.replyTo?.type == "Prmoter-event"  {
        //            guard let model = Mapper<PromoterEventsModel>().map(JSONString: model.replyTo?.data ?? "") else { return }
        //            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        //            vc.isComplementary = APPSESSION.userDetail?.isRingMember ?? true
        //            vc.id = model.eventId
        //            vc.hidesBottomBarWhenPushed = true
        //            self.navigationController?.pushViewController(vc, animated: true)
        //        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 250 {
            _unReadMsgCountLbl.text = "0"
            _unReadMsgCountLbl.isHidden = true
            _scrollDownButton.isHidden = true
        } else {
            if !_msgList.isEmpty {
                _scrollDownButton.isHidden = false
            }
        }
    }
    
    private func performPagination() {
        
    }
    
}

// --------------------------------------
// MARK: GrowingTextView Delegate
// --------------------------------------

extension ChatDetailVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._messageView.addGradientBorderWithColor(cornerRadius: 20, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
        }
        
        let msgText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        _sendButton.isHidden = msgText.trim.isEmpty
        _voiceChatButton.isHidden = !msgText.trim.isEmpty
        recordButton.isHidden = !msgText.trim.isEmpty
        
        
        guard let _chatModel = chatModel else { return }
        if let _timer = self._timerForTyping, _timer.isValid  {
            _timer.invalidate()
        } else {
            SOCKETMANAGER.sendTypingStatus(chatId: _chatModel.chatId, members: _chatModel.members.toArray(ofType: String.self), chatType: chatType, status: true )
        }
        self._timerForTyping = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            SOCKETMANAGER.sendTypingStatus(chatId: _chatModel.chatId, members: _chatModel.members.toArray(ofType: String.self), chatType: self.chatType, status: false )
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._messageView.addGradientBorderWithColor(cornerRadius: 22, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
        }
    }
    
}

// --------------------------------------
// MARK: ImagePcker Delegate, NavigationController Delegate
// --------------------------------------

extension ChatDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true) {
            guard let pickedImage = info[.originalImage] as? UIImage else { return }
            self.showImageCropper(for: pickedImage)
        }
    }
    
    private func showImageCropper(for image: UIImage) {
        let imageCropperViewController = ImagePreviewVC()
        imageCropperViewController.delegate = self
        imageCropperViewController.imageToCrop = image
        imageCropperViewController.modalPresentationStyle = .overFullScreen
        present(imageCropperViewController, animated: true, completion: nil)
    }
}

extension ChatDetailVC: ImagePreviewVCDelegate {
    func cancelImageCropper(imagePreviewVC: ImagePreviewVC) {
        imagePreviewVC.dismiss(animated: true, completion: nil)
    }
    
    func handleCroppedImage(imagePreviewVC: ImagePreviewVC, image: UIImage) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let imageName = Utils.generateMessageId(userDetail.id) + ".jpg"
        Utils.saveFileToLocal(image, fileName: imageName)
        let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(imageName)
        self._requestUploadFile(fileUrl, msgType: .image)
        imagePreviewVC.dismiss(animated: true, completion: nil)
    }
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension ChatDetailVC: RecordViewDelegate {
    func onStart() {
        resetAudioPlayer()
        startRecording()
    }
    
    func onCancel() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.hideUnHideView(isHidden: false)
        }
    }
    
    func onFinished(duration: CGFloat) {
        let isSuccess = duration > 0.0
        finishRecording(success: isSuccess)
        hideUnHideView(isHidden: false)
    }
    
    func onPhoneCall() { }
    
    func prepareToStartRecording() {
        hideUnHideView(isHidden: true)
    }
    
    private func resetAudioPlayer() {
        AudioCellPlayer.shared.pause()
        AudioCellPlayer.shared.resetPlayer()
        _chatTableView.reloadData()
    }
    
    func startRecording() {
        AudioRecorderManager.shared.startRecording()
    }
    
    func finishRecording(success: Bool) {
        let status = AudioRecorderManager.shared.checkAudioRecordPermission() && success
        AudioRecorderManager.shared.finishRecording(success: status)
        hideUnHideView(isHidden: success)
        let fileName = AudioRecorderManager.shared.fileName
        guard fileName != "recording.m4a" else { return }
        guard let audioFilename = AudioRecorderManager.shared.applicationDocumentsDirectory?.appendingPathComponent(fileName) else { return }
        
        if success {
            if FileManager().fileExists(atPath: audioFilename.path) {
                _requestUploadFile(audioFilename, msgType: .audio)
            }
        }
    }
}

