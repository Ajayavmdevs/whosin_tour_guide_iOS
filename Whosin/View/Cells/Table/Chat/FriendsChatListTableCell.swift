import UIKit
import ObjectMapper

class FriendsChatListTableCell: UITableViewCell {

    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _msgCountLabel: UILabel!
    @IBOutlet private weak var _msgCountView: UIView!
    @IBOutlet private weak var _nameLAbel: UILabel!
    @IBOutlet private weak var _userImageView: UIImageView!
    @IBOutlet private weak var _msgTypeImageView: UIImageView!
    @IBOutlet private weak var _lastMessage: UILabel!
        
    private let userRepo = UserRepository()
    private var model: ChatModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        75
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
        
    func setupChatData(_ data: ChatModel, user: UserDetailModel) {
        self.model = data
        if data.isInvalidated { return }

        _nameLAbel.text = user.fullName
        _userImageView.loadWebImage(user.image, name: user.fullName)
        _msgCountView.isHidden = true
        let chatRepo = ChatRepository()
        _msgTypeImageView.isHidden = true
        if let _lastMsg = data.lastMsg {
            if _lastMsg.isInvalidated { return }
            if _lastMsg.type == MessageType.image.rawValue {
                _msgTypeImageView.isHidden = false
                _lastMessage.text = "Photo"
            } else if _lastMsg.type == MessageType.audio.rawValue {
                _lastMessage.text = "🎙️ Audio"
            } else if _lastMsg.type == MessageType.venue.rawValue {
                guard let model = Mapper<ChatVenueModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent() ? LANGMANAGER.localizedString(forKey: "shared_venue", arguments: ["value": model.name]) : LANGMANAGER.localizedString(forKey: "recived_venue", arguments: ["value": model.name])
            } else if _lastMsg.type == MessageType.story.rawValue {
                guard let model = Mapper<ChatVenueModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_story", arguments: ["value": model.name])
                    : LANGMANAGER.localizedString(forKey: "recived_story", arguments: ["value": model.name])
            } else if _lastMsg.type == MessageType.user.rawValue {
                guard let model = Mapper<ChatUserModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_profile", arguments: ["value": model.fullName])
                    : LANGMANAGER.localizedString(forKey: "recived_profile", arguments: ["value": model.fullName])
            } else if _lastMsg.type == MessageType.offer.rawValue {
                guard let model = Mapper<OffersModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_offer", arguments: ["value": model.title])
                    : LANGMANAGER.localizedString(forKey: "recived_offer", arguments: ["value": model.title])
            } else if _lastMsg.type == MessageType.yacht.rawValue {
                guard let model = Mapper<YachtOfferDetailModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_yacht", arguments: ["value": model.title])
                    : LANGMANAGER.localizedString(forKey: "recived_yacht", arguments: ["value": model.title])
            }  else if _lastMsg.type == MessageType.yachtClub.rawValue {
                guard let model = Mapper<YachtClubModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_yachtclub", arguments: ["value": model.name])
                    : LANGMANAGER.localizedString(forKey: "recived_yachtclub", arguments: ["value": model.name])
            } else if _lastMsg.type == MessageType.promoterEvent.rawValue {
                guard let model = Mapper<PromoterEventsModel>().map(JSONString: _lastMsg.msg) else { return }
                let eventName = model.venueType == "venue" ? "venue" : (model.customVenue?.name ?? "")
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_event", arguments: ["value": eventName])
                    : LANGMANAGER.localizedString(forKey: "recived_event", arguments: ["value": eventName])
            } else if _lastMsg.type == MessageType.ticket.rawValue {
                guard let model = Mapper<TicketModel>().map(JSONString: _lastMsg.msg) else { return }
                _lastMessage.text = _lastMsg.isSent()
                    ? LANGMANAGER.localizedString(forKey: "shared_ticket", arguments: ["value": model.title])
                    : LANGMANAGER.localizedString(forKey: "recived_ticket", arguments: ["value": model.title])
            } else {
                _lastMessage.text = _lastMsg.msg
            }
            guard let time = Double(_lastMsg.date) else { return }
            _timeLabel.text = time.getDateStringFromUTC()
        } else {
            _lastMessage.text = kEmptyString
        }
        self._msgCountView.isHidden = true
        chatRepo.getUnReadMessagesCount(chatId: data.chatId) { unReadCount in
            if unReadCount > 0 {
                self._msgCountLabel.text = "\(unReadCount)"
                self._msgCountView.isHidden = false
            } else {
                self._msgCountLabel.text = "\(unReadCount)"
                self._msgCountView.isHidden = true
            }
        }
        
//        let unReadCount = chatRepo.getUnReadMessagesCount(chatId: data.chatId)
//        if unReadCount > 0 {
//            _msgCountLabel.text = "\(unReadCount)"
//            _msgCountView.isHidden = false
//        } else {
//            _msgCountLabel.text = "\(unReadCount)"
//            _msgCountView.isHidden = true
//        } 
    }

}
