import UIKit

class AvailabelTimeSlotCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _timeLbl: CustomLabel!
    @IBOutlet weak var _slotLeftLbl: CustomLabel!
    @IBOutlet weak var _bgView: UIView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        40
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupDataTime(_ setting: TourTimeSlotModel?, isSelected: Bool = false) {
        _timeLbl.text = setting?.timeSlot
        _timeLbl.textColor = .white
        _slotLeftLbl.text = "\(setting?.available ?? 0)" + "slot_left".localized()
        _bgView.backgroundColor = isSelected ? ColorBrand.brandPink.withAlphaComponent(0.13) : ColorBrand.clear
        _bgView.borderColor = isSelected ? ColorBrand.brandPink : ColorBrand.white
    }

}
