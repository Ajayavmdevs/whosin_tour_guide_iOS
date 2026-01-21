import UIKit

class BucketChatListTableCell: UITableViewCell {

    
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _msgLabel: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _unReadCountLabel: UILabel!
    @IBOutlet weak var _unReadCountView: UIView!
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupData(_ bucket: BucketDetailModel) {
        _unReadCountLabel.isHidden = false
        _unReadCountView.isHidden = true
        
        _titleLabel.text = bucket.name
        _imageView.loadWebImage(bucket.coverImage, name: bucket.name)
        
        _msgLabel.text = kEmptyString
        _timeLabel.text = kEmptyString
        
        if let _lastMsg =  bucket.lastMsg {
            
            if _lastMsg.type == MessageType.image.rawValue {
                _msgLabel.text = "🖼 Photo"
            } else if _lastMsg.type == MessageType.audio.rawValue {
                _msgLabel.text = "🎙️ Audio"
            } else {
                _msgLabel.text = _lastMsg.msg
            }
            guard let time = Double(_lastMsg.date) else { return }
            _timeLabel.text = time.getDateStringFromUTC()
            
        }
        
        let repo = ChatRepository()
        let unReadCount = repo.getUnReadMessagesCount(chatId: bucket.id)
        if unReadCount > 0 {
            _unReadCountLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = false
        } else {
            _unReadCountLabel.text = "\(unReadCount)"
            _unReadCountView.isHidden = true
        }

    }

}
