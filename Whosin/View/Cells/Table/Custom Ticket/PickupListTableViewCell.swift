import UIKit

class PickupListTableViewCell: UITableViewCell {

    @IBOutlet private weak var _hotelName: CustomLabel!
    @IBOutlet private weak var _hotelLocation: CustomLabel!
    @IBOutlet weak var _radioSelection: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 52 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    public func setupData(_ data: PickupListModel, _ isSelected: Bool = false) {
        _hotelName.text = data.name
        _hotelLocation.text = "\(data.regionName), \(data.cityName)"
        _hotelLocation.isHidden = Utils.stringIsNullOrEmpty(data.regionName) && Utils.stringIsNullOrEmpty(data.cityName)
        _radioSelection.image = UIImage(named: isSelected ? "icon_radio_selected" : "icon_radio")
    }
    
    
}
