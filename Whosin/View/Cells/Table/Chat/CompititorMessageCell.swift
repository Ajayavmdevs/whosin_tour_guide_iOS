import UIKit

class CompititorMessageCell: UITableViewCell {

    @IBOutlet weak var _senderNameLabel: UILabel!
    @IBOutlet weak var _messageTimeLabel: UILabel!
    @IBOutlet weak var _messageLabel: AttributedLabel!
    @IBOutlet private weak var _bgView: UIView!
    
    private var _msgModel: MessageModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        _senderNameLabel.isUserInteractionEnabled = true
        _senderNameLabel.addGestureRecognizer(tapGesture2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func userTapped(sender: UITapGestureRecognizer) {
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ message: MessageModel?) {
        _msgModel = message
        _senderNameLabel.text = message?.authorName
        _messageLabel.text = message?.msg
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _messageTimeLabel.text = date
        let lblMsgGetsture = UILongPressGestureRecognizer(target: self, action: #selector(openMsgSelectPopup))
        lblMsgGetsture.minimumPressDuration = 0.5
        _messageLabel.addGestureRecognizer(lblMsgGetsture)

    }
    
    @objc func openMsgSelectPopup() {
        UIPasteboard.general.string = _messageLabel.text as? String
        parentBaseController?.showToast("copied_to_clipboard".localized())
    }

    func setupContactUs(_ message: RepliesModel) {
        _senderNameLabel.text = "Whos'In Admin"
        _messageLabel.text = message.reply
        let date = Utils.stringToDate(message.createdAt, format: kStanderdDate)
        _messageTimeLabel.text = Utils.timeOnly(date)
    }

}
