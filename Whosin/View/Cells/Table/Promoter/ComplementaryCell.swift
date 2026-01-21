import UIKit

class ComplementaryCell: UITableViewCell {

    @IBOutlet private weak var _textFieldFive: OTPTextField!
    @IBOutlet private weak var _textFieldFour: OTPTextField!
    @IBOutlet private weak var _textFieldThree: OTPTextField!
    @IBOutlet private weak var _textFieldTwo: OTPTextField!
    @IBOutlet private weak var _textFieldOne: OTPTextField!
    private var _otpCodeList: [UITextField] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    func setupUi() {
        _otpCodeList = [
            _textFieldOne, _textFieldTwo, _textFieldThree, _textFieldFour, _textFieldFive
        ]
        for field in _otpCodeList {
            field.text = ""
            field.textAlignment = .center
            field.delegate = self
            field.keyboardType = field == _textFieldOne ? .alphabet : .numberPad
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func _validateVerifyButton() {
        let isValid = _otpCodeList.first(where: { Utils.stringIsNullOrEmpty($0.text) }) == nil
        if isValid {
            var otpCodes: [String] = []
            for txt in _otpCodeList { otpCodes.append(txt.text ?? kEmptyString) }
            
            if otpCodes.count == _otpCodeList.count {
                let code = otpCodes.joined()
                endEditing(true)
                PromoterApplicationVC.promoterParams["code"] = formatString(code)
            }
        }
    }
    
    func formatString(_ input: String) -> String {
        guard input.count > 1 else { return input }
        let index = input.index(input.startIndex, offsetBy: 1)
        let formattedString = input.prefix(1) + "-" + input.suffix(from: index)
        return String(formattedString)
    }
}

extension ComplementaryCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length == 0 && string.isEmpty) {
            self.textFieldDidDelete(textField)
            return false }
        
        if (range.length == 1 && string.isEmpty) {
            textField.text = kEmptyString
            _validateVerifyButton()
            return false
        }
        
        if string.count == 0 {
            _validateVerifyButton()
            return false
        }
        
        if textField != _textFieldOne {
            if !(string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil) {
                _validateVerifyButton()
                return false
            }
        }
        
        textField.text = string
        self.textFieldDidChange(textField)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        _validateVerifyButton()
        var index = 0
        for textField in _otpCodeList {
            index += 1
            if textField.isFirstResponder && index < _otpCodeList.count {
                _otpCodeList[index].becomeFirstResponder()
                break
            }
        }
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        guard var index = _otpCodeList.firstIndex(of: textField) else { return }
        index -= 1
        if index >= 0 {
            let textField = _otpCodeList[index]
            textField.becomeFirstResponder()
            textField.text = kEmptyString
            _validateVerifyButton()
        }
    }
}
