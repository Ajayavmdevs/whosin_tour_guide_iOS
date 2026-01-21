import UIKit

class SocialTableCell: UITableViewCell {
    
    @IBOutlet weak var _discriptionText: UITextField!
    @IBOutlet weak var _customSocialView: CustomSocialView!
    public var callback: ((_ model: [SocialAccountsModel]) -> Void)?
    public var discCallback: ((_ discription: String) -> Void)?
    
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
        _discriptionText.delegate = self
        _customSocialView.updateDataCallback = { data in
            self.callback?(data)
        }
    }
    
    public func setupData(_ model: [SocialAccountsModel]) {
        _customSocialView.setupData(model)
    }
    
}

extension SocialTableCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        discCallback?(textField.text ?? kEmptyString)
    }
}
