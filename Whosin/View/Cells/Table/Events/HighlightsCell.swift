import UIKit

class HighlightsCell: UITableViewCell {

    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _timeLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    public func setupMessageData(_ model: MessageModel) {
        _userImage.loadWebImage(model.authorImage, name: model.authorName)
        let attributedString = NSMutableAttributedString(string: "\(model.authorName) \(model.msg)")
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: FontBrand.SFsemiboldFont(size: 12)]
        let range = (attributedString.string as NSString).range(of: model.authorName)
        attributedString.addAttributes(boldFontAttribute, range: range)
        _nameLabel.attributedText = attributedString
        let timestamp = (TimeInterval(model.date) ?? 0.0) / 1000 

        _timeLabel.text = timeAgoSinceDate(timestamp)
    }
    
    func timeAgoSinceDate(_ timestamp: TimeInterval, numericDates: Bool = false) -> String {
        let currentDate = Date()
        let date = Date(timeIntervalSince1970: timestamp)
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: currentDate)

        return localizedTimeAgo(from: components)
    }
    
    func localizedTimeAgo(from components: DateComponents) -> String {
        if let year = components.year, year > 0 {
            return LANGMANAGER.localizedString(
                forKey: year == 1 ? "time_year" : "time_years",
                arguments: ["value": "\(year)"]
            )
        } else if let month = components.month, month > 0 {
            return LANGMANAGER.localizedString(
                forKey: month == 1 ? "time_month" : "time_months",
                arguments: ["value": "\(month)"]
            )
        } else if let day = components.day, day > 0 {
            return LANGMANAGER.localizedString(
                forKey: day == 1 ? "time_day" : "time_days",
                arguments: ["value": "\(day)"]
            )
        } else if let hour = components.hour, hour > 0 {
            return LANGMANAGER.localizedString(
                forKey: hour == 1 ? "time_hour" : "time_hours",
                arguments: ["value": "\(hour)"]
            )
        } else if let minute = components.minute, minute > 0 {
            return LANGMANAGER.localizedString(
                forKey: minute == 1 ? "time_minute" : "time_minutes",
                arguments: ["value": "\(minute)"]
            )
        } else if let second = components.second, second > 0 {
            return LANGMANAGER.localizedString(
                forKey: second == 1 ? "time_second" : "time_seconds",
                arguments: ["value": "\(second)"]
            )
        } else {
            return LANGMANAGER.localizedString(forKey: "time_just_now")
        }
    }


}

