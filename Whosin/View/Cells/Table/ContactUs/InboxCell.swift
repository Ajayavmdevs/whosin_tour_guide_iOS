import UIKit

class InboxCell: UITableViewCell {

    @IBOutlet weak var _notifyDot: UIView!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    class var height: CGFloat { UITableView.automaticDimension }

    public func setupData(_ data: InboxListModel) {
        _notifyDot.isHidden = data.replies.allSatisfy({ $0.isRead == true })
        _imageView.loadWebImage(data.image, placeholder: UIImage(named: "icon_user_avatar_default"))
        _titleLabel.text = data.subject
        _subtitleLabel.text = data.replies.last?.reply ?? data.message
        let date = Utils.stringToDate(data.lastMessagecreatedAt, format: kStanderdDate)
        _timeLabel.text = getDateStringFromUTC(date: date)
    }
    
    func getDateStringFromUTC(date: Date?) -> String {
        guard let date = date else { return kEmptyString}
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = kFormatDateTimeUS
        } else {
            dateFormatter.dateFormat = kFormatDateWith24Hour
        }
        dateFormatter.timeZone = TimeZone.current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }

}
