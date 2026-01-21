import UIKit

class EventChatListTableCell: UITableViewCell {
    
    @IBOutlet private weak var _imgBgView: UIView!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _eventName: UILabel!
    @IBOutlet private weak var _lastMessage: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _countLabel: UILabel!
    @IBOutlet private weak var _unReadCountView: UIView!
    @IBOutlet private weak var _ownerNameLabel: UILabel!
    private var userRepo = UserRepository()
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        70
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._imgBgView.roundCorners(corners: [.allCorners], radius: 9)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupData(_ eventModel: EventModel) {
        _ownerNameLabel.text = eventModel.chatHomeOrgName
        _eventName.text = eventModel.title
        _unReadCountView.isHidden = true
        
        
        _imageView.loadWebImage(eventModel.image, name: eventModel.title)
        _lastMessage.text = kEmptyString
        _timeLabel.text = kEmptyString
        
        if let msgModel = eventModel.lastMsg {
            if msgModel.type == MessageType.image.rawValue {
                _lastMessage.text = "🖼 Photo"
            } else if msgModel.type == MessageType.audio.rawValue {
                _lastMessage.text = "🎙️ Audio"
            } else {
                _lastMessage.text = msgModel.msg
            }
            guard let time = Double(msgModel.date) else { return }
            _timeLabel.text = time.getDateStringFromUTC()
        }
        
        let repo = ChatRepository()
        let unReadCount = repo.getUnReadMessagesCount(chatId: eventModel.id)
        if unReadCount > 0 {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = false
        } else {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = true
        }
        
    }
    
    func setupoutingData(_ outingModel: OutingListModel) {
        _ownerNameLabel.text = outingModel.chatHomeOrgName
        _eventName.text = outingModel.chatHomeEventName
        _unReadCountView.isHidden = true
        
        _imageView.loadWebImage(outingModel.venue?.cover ?? kEmptyString, name: outingModel.title)
        _lastMessage.text = kEmptyString
        _timeLabel.text = kEmptyString
        
        if let msgModel = outingModel.lastMsg {
            if msgModel.type == MessageType.image.rawValue {
                _lastMessage.text = "🖼 Photo"
            } else if msgModel.type == MessageType.audio.rawValue {
                _lastMessage.text = "🎙️ Audio"
            } else {
                _lastMessage.text = msgModel.msg
            }
            guard let time = Double(msgModel.date) else { return }
            _timeLabel.text = time.getDateStringFromUTC()
        }
        
        let repo = ChatRepository()
        let unReadCount = repo.getUnReadMessagesCount(chatId: outingModel.id)
        if unReadCount > 0 {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = false
        } else {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = true
        }
    }
    
    func setupCMChatData(_ eventModel: PromoterChatListModel) {
        _ownerNameLabel.text = eventModel.owner?.fullName
        _eventName.text = eventModel.venueName
        _unReadCountView.isHidden = true
        
        
        _imageView.loadWebImage(eventModel.venueImage, name: eventModel.venueName)
        _lastMessage.text = eventModel.lastMessage?.msg
        _timeLabel.text = kEmptyString
        let lastMsg = ChatRepository().getLastMessages(chatId: eventModel.id)
        if let msgModel = lastMsg {
            if msgModel.type == MessageType.image.rawValue {
                _lastMessage.text = "🖼 Photo"
            } else if msgModel.type == MessageType.audio.rawValue {
                _lastMessage.text = "🎙️ Audio"
            } else {
                _lastMessage.text = msgModel.msg
            }
            guard let time = Double(msgModel.date) else { return }
            _timeLabel.text = time.getDateStringFromUTC()
        }
        
        let repo = ChatRepository()
        let unReadCount = repo.getUnReadMessagesCount(chatId: eventModel.id)
        if unReadCount > 0 {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = false
        } else {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = true
        }
        
    }
}
