import UIKit

class InboxChatCell: UITableViewCell {

    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _titalLabel: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _descriptionLabel: UILabel!
    
    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupData(_ data: RepliesModel) {
        let date = Utils.stringToDate(data.createdAt, format: kStanderdDate)
        if data.replyBy == "admin" {
            _titalLabel.text = "Whos'In Admin"
            _timeLabel.text = Utils.timeOnly(date)
            _imageView.image = UIImage(named: "icon_admin")
            _descriptionLabel.text = data.reply
        } else {
            _titalLabel.text = APPSESSION.userDetail?.fullName
            _timeLabel.text = Utils.timeOnly(date)
            _imageView.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString)
            _descriptionLabel.text = data.reply
        }
    }

}
