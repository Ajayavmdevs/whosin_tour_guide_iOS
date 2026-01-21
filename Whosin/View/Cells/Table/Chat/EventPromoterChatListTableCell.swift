import UIKit

class EventPromoterChatListTableCell: UITableViewCell {
    
//    @IBOutlet weak var _timeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var _lastMessage: UILabel!
    @IBOutlet private weak var _imgBgView: UIView!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _eventName: UILabel!
    @IBOutlet private weak var _eventDate: UILabel!
    @IBOutlet private weak var _eventTime: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _countLabel: UILabel!
    @IBOutlet private weak var _unReadCountView: UIView!
    @IBOutlet private weak var _ownerNameLabel: UILabel!
    private var userRepo = UserRepository()
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
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
    
    
    func setupCMChatData(_ eventModel: PromoterChatListModel) {
        _ownerNameLabel.text = eventModel.descriptions
        _eventName.text = eventModel.venueName
        _unReadCountView.isHidden = true
        
        _imageView.loadWebImage(eventModel.venueImage, name: eventModel.venueName)
        _eventDate.text = Utils.dateToString(Utils.stringToDate(eventModel.date, format: kFormatDate), format: kFormatEventDate)
        _eventTime.text = "\(eventModel.startTime) - \(eventModel.endTime)"
        let repo = ChatRepository()
        if let lastMessage = repo.getLastMessages(chatId: eventModel.id)  {
            _lastMessage.text = Utils.stringIsNullOrEmpty(lastMessage.msg) ? kEmptyString : "~ \(lastMessage.authorName): " + lastMessage.msg
            if let time = Double(lastMessage.date) {
                _timeLabel.text = time.getDateStringFromUTC()
//                updateTimeWidthConstraint(for: time.getDateStringFromUTC(), font: FontBrand.labelFont)
            }
        } else {
            _lastMessage.text = kEmptyString
            _timeLabel.text = kEmptyString
        }
//        getLastMessages
//        let repo = ChatRepository()
        let unReadCount = repo.getUnReadMessagesCount(chatId: eventModel.id)
        if unReadCount > 0 {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = false
        } else {
            _countLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = true
        }
    }
    
    func updateTimeWidthConstraint(for text: String, font: UIFont) {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let textWidth = (text as NSString).boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).width
        
//        _timeWidthConstraint.constant = textWidth
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }

}
