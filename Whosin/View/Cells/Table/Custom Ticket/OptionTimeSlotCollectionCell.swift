import UIKit

class OptionTimeSlotCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _timeSlot: CustomLabel!
    @IBOutlet weak var _availableSlot: CustomLabel!
    @IBOutlet weak var _radioSelection: UIImageView!
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var stackview: UIStackView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 52 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    public func setupData(_ data: OctoAvailibilityModel, _ isSelected: Bool = false) {
        _timeSlot.text = "\(data.openingHours.first?.from ?? "") - \(data.openingHours.first?.to ?? "")"
//            _availableSlot.text = "(\(data.totalPaxCount) Available)"
            _availableSlot.isHidden = true
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")
        _mainView.borderColor = isSelected ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
    }
    
    public func setupData(_ data: TravelDeskAvailibilityModel, _ isSelected: Bool = false) {
        guard let availability = data.availability else { return }
        _timeSlot.text = availability.slotText
        _availableSlot.text = "(\(availability.left)" + "available".localized() + ")"
        _availableSlot.isHidden = availability.left == 0
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")
        _mainView.borderColor = isSelected ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
    }
    
    public func setupData(_ data: PickupListModel, _ isSelected: Bool = false) {
        stackview.axis = .vertical
        _timeSlot.text = data.name
        _availableSlot.text = "\(data.regionName), \(data.cityName)"
        _availableSlot.textColor = ColorBrand.white.withAlphaComponent(0.6)
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")
        _mainView.borderColor = isSelected ? UIColor(hexString: "#2BA735") : ColorBrand.brandGray
    }

}
