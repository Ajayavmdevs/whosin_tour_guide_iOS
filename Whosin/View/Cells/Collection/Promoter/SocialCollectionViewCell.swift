import UIKit
protocol SocialCollectionViewCellDelegate: AnyObject {
    func didTapDeleteButton(at indexPath: IndexPath)
}

class SocialCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var _stackBgView: UIStackView!
    @IBOutlet weak var _copyBtn: UIButton!
    @IBOutlet weak var _copyView: UIView!
    @IBOutlet weak var _deleteView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet private weak var _customField: CustomFormField!
    @IBOutlet weak var _titleView: UIView!
    @IBOutlet weak var _titleTextField: LeftSpaceTextField!
    weak var delegate: SocialCollectionViewCellDelegate?
    var indexPath: IndexPath?
    private var _textString: String = kEmptyString
    private var _platform: SocialPlatforms = .instagram
    public var callback: ((_ text: String?,_ platfrom: SocialPlatforms, _ titleText: String?) -> Void)?
    @IBOutlet weak var _socialMediaTitle: CustomLabel!
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var _topConstraint: NSLayoutConstraint!
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 80 }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _titleTextField.delegate = self
    }
    
    public func setupData(_ placeHolder: String, text: String = kEmptyString, icon: String, platform: SocialPlatforms, titleText: String = kEmptyString) {
        _socialMediaTitle.isHidden = true
        _textString = text
        _platform = platform
        _customField.setupData(Utils.stringIsNullOrEmpty(text) ? kEmptyString : text, subtitle: placeHolder, icon: "icon_\(icon)")
        _customField.fieldType = FormFieldType.socialForm.rawValue
        _customField.isEvent = true
        _titleTextField.isHidden = false
        _titleTextField.text = titleText
        _customField.callback = { text in
            self.callback?(text, platform, self._titleTextField.text)
        }
        _bgView.backgroundColor = UIColor(hexString: "#191A1F")
        _customField._socialBgView.backgroundColor = UIColor(hexString: "#191A1F")
        _stackBgView.backgroundColor = UIColor(hexString: "#191A1F")

    }
    
    public func setup(_ title: String, placeHolder: String, icon: String, platform: SocialPlatforms, titleText: String = kEmptyString) {
        _textString = title
        _customField._socialBgView.backgroundColor = UIColor(hexString: "#4E0054")
        _stackBgView.backgroundColor = UIColor(hexString: "#4E0054")
        _bgView.backgroundColor = UIColor(hexString: "#4E0054")
        _stackBgView.cornerRadius = 15
        _customField.setupData(title, subtitle: placeHolder, icon: "icon_\(icon)", isEnable: false)
        _customField.fieldType = FormFieldType.socialForm.rawValue
        _socialMediaTitle.isHidden = false
        _socialMediaTitle.text = titleText
        _titleView.isHidden = Utils.stringIsNullOrEmpty(titleText)
    }

    @IBAction func _handleDeleteEvent(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDeleteButton(at: indexPath)
    }
    
    @IBAction func _handleCopyEvent(_ sender: UIButton) {
        UIPasteboard.general.string = _textString
        self.parentViewController?.showToast("link_copied".localized())
    }
}

extension SocialCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        callback?(_textString, _platform, textField.text)
    }
}
