import UIKit

class AddOnTimeSlotTableCell: UITableViewCell {
    
    @IBOutlet weak var _timeSlot: CustomLabel!
    @IBOutlet weak var _availableSlot: CustomLabel!
    @IBOutlet weak var _radioSelection: UIImageView!
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var stackview: UIStackView!

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
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: TourTimeSlotModel, _ isSelected: Bool = false) {
        if Utils.stringIsNullOrEmpty(data.timeSlot) {
            _timeSlot.text = data.availabilityTime
        } else {
            _timeSlot.text = data.timeSlot
        }
        if !Utils.stringIsNullOrEmpty(data.availabilityTime), !Utils.stringIsNullOrEmpty(data.id) {
            _availableSlot.text = "(\(data.totalSeats)" + "available".localized() + ")"
            _availableSlot.isHidden = data.totalSeats == 0
        } else {
            _availableSlot.text = "(\(data.available)" + "available".localized() + ")"
            _availableSlot.isHidden = data.available == 0
        }
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")
        _mainView.borderColor = isSelected ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
    }
}
