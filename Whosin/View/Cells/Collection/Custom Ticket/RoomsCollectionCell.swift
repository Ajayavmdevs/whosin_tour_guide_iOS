import UIKit

class RoomsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var _roomTitle: CustomLabel!
    @IBOutlet weak var _type: CustomLabel!
    @IBOutlet weak var _availibleRooms: CustomLabel!
    @IBOutlet weak var _infoBtn: UnderlinedButton!
    @IBOutlet weak var _roomCapacity: CustomLabel!
    
    private var roomModel: JPHotelRoomModel?
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 98 }

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Setup
    // --------------------------------------

    public func setupData(_ model: JPHotelRoomModel, isNoBackground: Bool = false, hideCapacity: Bool = false) {
        _mainView.backgroundColor = isNoBackground ? .clear : ColorBrand.cardBgColor
        _mainView.borderWidth = isNoBackground ? 0 : 0.5
        roomModel = model
        if Utils.stringIsNullOrEmpty(model.roomCategory) {
            _roomTitle.text = model.name
        } else {
            _roomTitle.text = model.name + " | " + model.roomCategory
        }
        if model.features.isEmpty {
            _infoBtn.isHidden = true
        } else {
            _infoBtn.isHidden = isNoBackground
        }
        if let maxOccupancy = model.roomOccupancy?.maxOccupancy, !maxOccupancy.isEmpty, maxOccupancy != "0" {
            _type.text = LANGMANAGER.localizedString(forKey: "maxOccupancy", arguments: ["value": maxOccupancy])
        } else {
            _type.isHidden = true
        }
        _availibleRooms.text = "available".localized() + ": " + model.availRooms
        _availibleRooms.isHidden = model.availRooms == "0"
        _roomCapacity.isHidden = hideCapacity
        var parts: [String] = []
        if let adults = model.roomOccupancy?.adults, !adults.isEmpty, adults != "0" {
            parts.append("\("adults_title".localized()): \(adults)")
        }
        if let children = model.roomOccupancy?.children, !children.isEmpty, children != "0"  {
            parts.append("\("children_title".localized()): \(children)")
        }
        if let occupancy = model.roomOccupancy?.occupancy, !occupancy.isEmpty, occupancy != "0"  {
            parts.append("\("occupancy".localized()) \(occupancy)")
        }

        _roomCapacity.text = parts.joined(separator: " | ")
    }

    @IBAction private func _handleFeaturesEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "Features"
        let featuresArray = roomModel?.features.toArray(ofType: String.self) ?? []
        vc.features = featuresArray
        parentBaseController?.presentAsPanModal(controller: vc)
    }
    
}
