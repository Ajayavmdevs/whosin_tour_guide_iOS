import UIKit

class OwnMessageCell: UITableViewCell {

    @IBOutlet private weak var _messageTimeLabel: UILabel!
    @IBOutlet private weak var _messageLabel: AttributedLabel!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet private weak var _replyByText: CustomLabel!
    
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
        _messageLabel.numberOfLines = 0
//        _messageLabel.lineBreakMode = .byWordWrapping
        _messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        _messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        _statusImage.isHidden = false
        _messageLabel.text = _msg.msg
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _messageTimeLabel.text = "\(date ?? "")"
        let lblMsgGetsture = UILongPressGestureRecognizer(target: self, action: #selector(openMsgSelectPopup))
        lblMsgGetsture.minimumPressDuration = 0.5
        _messageLabel.addGestureRecognizer(lblMsgGetsture)
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .white
        }
        else if _msg.receivers.contains(Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString : APPSESSION.userDetail?.id ?? kEmptyString) {
            _statusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _statusImage.tintColor = .white
        }
        else {
            _statusImage.image = #imageLiteral(resourceName: "icon_sending")
            _statusImage.tintColor = .white
            _messageTimeLabel.text = "sending...".localized()
        }
        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByText.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            if replyUser != nil {
                _replyByText.text = "~ " + (replyUser?.fullName ?? kEmptyString)
            }
        }
        layoutIfNeeded()
    }
    
    func setupContactUs(_ message: RepliesModel) {
        _messageLabel.text = message.reply
        let date = Utils.stringToDate(message.createdAt, format: kStanderdDate)
        _messageTimeLabel.text = Utils.timeOnly(date)
        _statusImage.isHidden = true
    }
    
    @objc func openMsgSelectPopup() {
        UIPasteboard.general.string = _messageLabel.text as? String
        parentBaseController?.showToast("copied_to_clipboard".localized())
    }
}


import UIKit
import TTTAttributedLabel

/**
 This class is designed and implemented to detect links inside messages and make them clickable.
*/
final class AttributedLabel: TTTAttributedLabel {
  
    /// Awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()  // Call super to ensure proper initialization
        self.numberOfLines = 0
        self.lineBreakMode = .byCharWrapping
        // Set link attributes
        self.translatesAutoresizingMaskIntoConstraints = false

        linkAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "#D5FF4B"),
            NSAttributedString.Key.font: FontBrand.SFboldFont(size: 16) // Set bold font for links
        ]
        
        activeLinkAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "#D5FF4B"),
            NSAttributedString.Key.font: FontBrand.SFboldFont(size: 16) // Set bold font for active links
        ]
        
        // Set delegate and enable text checking types
        self.delegate = self
        enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
    }
    
    /// Highlight text when searching messages in chat
    /// - Parameter text: Text to highlight in message
    func highlightText(text: String?) {
        guard let text = text else { return }
        let string = NSMutableAttributedString(attributedString: self.attributedText)
        let currentText = string.string
        let range = NSString(string: currentText.lowercased()).range(of: text.lowercased())
        
        if range.location != NSNotFound {
            var newRange = NSRange(location: range.location, length: currentText.count - range.location)
            let startIndex = currentText.index(currentText.startIndex, offsetBy: range.location + range.length)
            let subString = currentText[startIndex...]
            let firstSpaceRange = NSString(string: subString.lowercased()).range(of: " ")
            
            if firstSpaceRange.location != NSNotFound {
                newRange = NSRange(location: range.location, length: range.length + firstSpaceRange.location)
            }
            
            // Apply attributes for highlighted text
            string.addAttribute(.font, value: FontBrand.SFboldFont(size: 16), range: newRange)
            string.addAttribute(NSAttributedString.Key(rawValue: kTTTBackgroundFillColorAttributeName), value: UIColor.yellow.cgColor, range: newRange)
            string.addAttribute(NSAttributedString.Key(rawValue: kTTTBackgroundCornerRadiusAttributeName), value: 5, range: newRange)
            
            self.attributedText = string
        }
    }
}

// MARK: - TTTAttributedLabelDelegate -
extension AttributedLabel: TTTAttributedLabelDelegate {
    /// Callback method when user clicks on a link
    /// - Parameters:
    ///     - label: TTTAttributedLabel
    ///     - url: URL clicked inside label
    func attributedLabel(_ label: TTTAttributedLabel?, didSelectLinkWith url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// Callback method when user clicks on a phone number
    /// - Parameters:
    ///     - label: TTTAttributedLabel
    ///     - phoneNumber: Phone number clicked inside label
    func attributedLabel(_ label: TTTAttributedLabel?, didSelectLinkWithPhoneNumber phoneNumber: String?) {
        if let phoneNumber = phoneNumber, let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
