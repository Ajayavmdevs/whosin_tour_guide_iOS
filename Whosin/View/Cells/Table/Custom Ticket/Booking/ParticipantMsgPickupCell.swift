import UIKit

class ParticipantMsgPickupCell: UITableViewCell {
    
    @IBOutlet private weak var _optionTitle: CustomLabel!
    @IBOutlet private weak var _messageField: CustomTextField!
    @IBOutlet private weak var _pickupTextField: CustomTextField!
    @IBOutlet private weak var _messageView: UIStackView!
    @IBOutlet private weak var _pickupStack: UIStackView!
    @IBOutlet weak var _dropdownView: UIImageView!
    @IBOutlet weak var _pickupView: UIView!
    @IBOutlet weak var _importantNotice: CustomLabel!
    @IBOutlet weak var _noteView: UIView!
    @IBOutlet weak var _noteTitle: CustomLabel!
    @IBOutlet weak var _noteDesc: CustomLabel!
    private var optionDetail: TourOptionDetailModel?
    var isDirectReporting: Bool = true
    
    public var callback: (() -> Void)?
    
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
        _noteTitle.text = "important_info_pickup".localized()
        _noteDesc.text = "shared_transfer_info".localized()
        _setup()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setup() {
        _pickupTextField.delegate = self
        _messageField.delegate = self
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TourOptionDetailModel) {
        optionDetail = data
        if let selectedOption = BOOKINGMANAGER.optionsList.first(where: { BOOKINGMANAGER.matchesOption($0, optionId: data.optionId, transferId: data.transferId) }) {
            _optionTitle.text = selectedOption.optionDetail?.optionName
            let allowedTypes = [41843, 41844]
            _pickupTextField.text = Utils.stringIsNullOrEmpty(data.pickup) ? "select_pickup_location".localized() : data.pickup
            updateBorder(for: _pickupView, isValid: !Utils.stringIsNullOrEmpty(data.pickup))
            _dropdownView.isHidden = true
            _pickupStack.isHidden = !allowedTypes.contains(selectedOption.transferId)
            _importantNotice.isHidden = !allowedTypes.contains(selectedOption.transferId)
            _noteView.isHidden = !allowedTypes.contains(selectedOption.transferId)
        } else if let travelModel = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == data.optionId}) {
            _optionTitle.text = travelModel.name
            isDirectReporting = travelModel.isDirectReporting
            if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                _pickupTextField.text = Utils.stringIsNullOrEmpty(data.pickup) ? "select_pickup_location".localized() : data.pickup
                updateBorder(for: _pickupView, isValid: !Utils.stringIsNullOrEmpty(data.pickup))
                _dropdownView.isHidden = false
                _pickupStack.isHidden = false
                _importantNotice.isHidden = true
                _noteView.isHidden == true
            }
        } else if let whosinTicket = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == data.optionId}) {
            _optionTitle.text = whosinTicket.displayName
            _pickupTextField.text = Utils.stringIsNullOrEmpty(data.pickup) ? "select_pickup_location".localized() : data.pickup
            updateBorder(for: _pickupView, isValid: !Utils.stringIsNullOrEmpty(data.pickup))
            _dropdownView.isHidden = true
            _pickupStack.isHidden = !whosinTicket.isPickup
            _importantNotice.isHidden = true
            _noteView.isHidden = true
        }
 
        callback?()
    }
    
    private func updateBorder(for view: UIView, isValid: Bool) {
        view.borderColor = isValid ? ColorBrand.brandGray : .red
        view.borderWidth = isValid ? 0.5 : 0.75
    }

    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleLocationPickerEvent(_ sender: UIButton) {
        if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            let vc = INIT_CONTROLLER_XIB(PickupListVC.self)
            vc.optionId = optionDetail?.optionId ?? ""
            vc.optionDetail = self.optionDetail
            vc.isDirectReporting = self.isDirectReporting
            vc.modalPresentationStyle = .pageSheet
            vc.callback = { [weak self] model in
                guard let self = self else { return }
                _pickupTextField.text = model.name
                optionDetail?.pickup = model.name
                optionDetail?.hotelId = model.id
                optionDetail?.message = _messageField.text ?? ""
                self.updateBorder(for: self._pickupView, isValid: !Utils.stringIsNullOrEmpty(self.optionDetail?.pickup))
                callback?()
            }
            parentBaseController?.navigationController?.present(vc, animated: true)
        } else {
            let vc = INIT_CONTROLLER_XIB(LocationPickerVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.isRestricted = true
            vc.completion = { location in
                self._pickupTextField.text = location?.address ?? ""
                self.optionDetail?.pickup = location?.address ?? ""
                self.optionDetail?.pickupLat = "\(location?.coordinate.latitude ?? 0)"
                self.optionDetail?.pickupLong = "\(location?.coordinate.longitude ?? 0)"
                self.updateBorder(for: self._pickupView, isValid: !Utils.stringIsNullOrEmpty(self.optionDetail?.pickup))
                self.callback?()
            }
            parentBaseController?.navigationController?.present(vc, animated: true)
        }
    }
    
}

extension ParticipantMsgPickupCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = self.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === _messageField {
            optionDetail?.message = textField.text ?? ""
        }
    }

}
