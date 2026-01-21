import UIKit

class FAQEditTableCell: UITableViewCell {

    @IBOutlet private weak var _textView: CustomTextView!
    public var updateCallBack: ((_ params: [String: Any]) -> Void)?
    private var params: [String: Any] = [:]
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _textView.delegate = self
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setup(_ params: [String: Any]) {
        if let info = params["faq"] as? String {
            _textView.text = info
        }
    }
    
}

extension FAQEditTableCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == _textView {
            params["faq"] = textView.text
            self.updateCallBack?(params)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == _textView {
            params["faq"] = textField.text
            self.updateCallBack?(params)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == _textView {
            params["faq"] = textField.text
        }
        self.updateCallBack?(params)
        return true
    }
}
