import UIKit

class ReportTableCell: UITableViewCell {
    
    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet weak var _selectImage: UIImageView!
    @IBOutlet weak var _fieldBgView: UIView!
    @IBOutlet weak var _textView: CustomTextView!
    public var updateCallBack: ((_ text: String) -> Void)?

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
        _textView.delegate = self
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        _textView.text = "please_describe_the_issue".localized()
        _textView.textColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ data: String,msgTxt: String, isSelected: Bool = false) {
        _textView.text = msgTxt
        _titleLabel.text = data
        _selectImage.image = UIImage(named: isSelected ? "icon_selectedGreen" : "icon_deselcetCode")
        _fieldBgView.isHidden = !(data == "Other")
    }
    
}

extension ReportTableCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "please_describe_the_issue".localized() {
            textView.text = ""
            textView.textColor = ColorBrand.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if Utils.stringIsNullOrEmpty(textView.text) {
            setupPlaceholder()
        } else {
            updateCallBack?(textView.text)
        }

    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == _textView, !Utils.stringIsNullOrEmpty(textView.text) {
            self.updateCallBack?(textView.text)
        }
    }
}
