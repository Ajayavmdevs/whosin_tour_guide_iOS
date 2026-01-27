import UIKit

class BankDetailVC: ChildViewController {
    
    // --------------------------------------
    // MARK: Outlets
    // --------------------------------------
    
    @IBOutlet weak var _headerView: UIView!
    @IBOutlet weak var _backButton: UIButton!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _editButton: UIButton!
    
    @IBOutlet weak var _scrollView: UIScrollView!
    @IBOutlet weak var _contentView: UIView!
    @IBOutlet weak var _stackView: UIStackView!
    
    @IBOutlet weak var _accountNameTextField: UITextField!
    @IBOutlet weak var _accountNumberTextField: UITextField!
    @IBOutlet weak var _bankNameTextField: UITextField!
    @IBOutlet weak var _branchTextField: UITextField!
    @IBOutlet weak var _ibanTextField: UITextField!
    @IBOutlet weak var _swiftTextField: UITextField!
    
    // New Outlets for UI updates
    @IBOutlet weak var _ibanContainerView: UIView!
    @IBOutlet weak var _ibanHintLabel: UILabel!
    @IBOutlet weak var _countryContainerView: UIView!
    @IBOutlet weak var _footerContainerView: UIView!
    
    private var isEditingEnabled: Bool = false {
        didSet {
            _updateEditingState()
        }
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _setupInitialState()
        isEditingEnabled = false
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleEditEvent(_ sender: UIButton) {
        if isEditingEnabled {
            _saveBankDetails()
        } else {
            isEditingEnabled = true
        }
    }
    
    // --------------------------------------
    // MARK: Private Methods
    // --------------------------------------
    
    private func _setupInitialState() {
        _editButton.setTitle("Edit", for: .normal)
        _editButton.setTitleColor(.white, for: .normal)
        _editButton.titleLabel?.font = UIFont(name: "SFUIText-Medium", size: 16)
        
        // Configure text fields
        let fields = [_accountNameTextField, _accountNumberTextField, _bankNameTextField, _branchTextField, _ibanTextField, _swiftTextField]
        fields.forEach { field in
            field?.textColor = .white
            field?.font = UIFont(name: "SFUIText-Regular", size: 16)
        }
        
        // Configure IBAN hint
        _ibanHintLabel.text = "Tap Edit to view full IBAN"
        _ibanHintLabel.font = UIFont(name: "SFUIText-Regular", size: 12)
        _ibanHintLabel.textColor = UIColor(named: "BrandLightGray") ?? .lightGray
        
        _loadBankDetails()
    }
    
    private func _updateEditingState() {
        let fields = [_accountNameTextField, _accountNumberTextField, _bankNameTextField, _branchTextField, _ibanTextField, _swiftTextField]
        
        fields.forEach { field in
            field?.isUserInteractionEnabled = isEditingEnabled
            field?.alpha = isEditingEnabled ? 1.0 : 0.7
        }
        
        _editButton.setTitle(isEditingEnabled ? "Save" : "Edit", for: .normal)
        
        _updateIBANDisplay()
    }
    
    private func _updateIBANDisplay() {
        if isEditingEnabled {
            _ibanTextField.text = _realIBAN
            _ibanHintLabel.isHidden = true
        } else {
            _ibanTextField.text = _maskIBAN(_realIBAN)
            _ibanHintLabel.isHidden = false
        }
    }
    
    private var _realIBAN: String = ""
    private var _bankModel: BankModel?
    
    private func _maskIBAN(_ iban: String) -> String {
        guard iban.count > 8 else { return iban }
        let prefix = iban.prefix(4)
        let suffix = iban.suffix(4)
        return "\(prefix) •••• •••• •••• \(suffix)"
    }
    
    private func _saveBankDetails() {
        _realIBAN = _ibanTextField.text ?? ""
        
        guard let accName = _accountNameTextField.text, !accName.isEmpty,
              let accNum = _accountNumberTextField.text, !accNum.isEmpty else {
            alert(message: "Please fill all required fields".localized())
            return
        }
        
        var params: [String: Any] = [:]
        params["holderName"] = accName
        params["holderType"] = "INDIVIDUAL"
        params["country"] = "AE"
        params["currency"] = "AED"
        
        var bankDetails: [String: Any] = [:]
        bankDetails["accountNumber"] = accNum
        bankDetails["bankName"] = _bankNameTextField.text
        bankDetails["iban"] = _realIBAN
        bankDetails["swiftCode"] = _swiftTextField.text
        bankDetails["bsb"] = _branchTextField.text
        
        params["bankDetails"] = bankDetails
        
        showHUD()
        WhosinServices.updateBankDetail(params: params) { [weak self] (response, error) in
            guard let self = self else { return }
            self.hideHUD()
            if let error = error {
                self.alert(message: error.localizedDescription)
                return
            }
            self.alert(message: "Bank details updated successfully".localized()) { _ in
                 self.isEditingEnabled = false
                 self._loadBankDetails()
            }
        }
    }
    
    private func _loadBankDetails() {
        showHUD()
        WhosinServices.getBankDetail { [weak self] (response, error) in
            guard let self = self else { return }
            self.hideHUD()
            if let error = error {
                self.alert(message: error.localizedDescription)
                return
            }
            
            if let data = response?.data {
                self._bankModel = data
                self._accountNameTextField.text = data.holderName
                
                if let bankDetails = data.bankDetails {
                    self._accountNumberTextField.text = bankDetails.accountNumber
                    self._bankNameTextField.text = bankDetails.bankName
                    self._branchTextField.text = bankDetails.bsb
                    self._realIBAN = bankDetails.iban
                    self._swiftTextField.text = bankDetails.swiftCode
                }
                
                self._updateIBANDisplay()
            }
        }
    }
}
