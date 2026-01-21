import UIKit

class OutingTimeAndDiscCell: UITableViewCell {

    @IBOutlet weak var _inviteMessageLabel: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _dateLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

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
    
    public func setupData(_ model: OutingListModel) {
        _dateLabel.text = model._date
        _timeLabel.text = Utils.formatTimeRange(start: model.startTime, end: model.endTime)
        _inviteMessageLabel.text = model.title
    }

}
