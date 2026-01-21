import UIKit

class TimeCalenderCell: UICollectionViewCell {
    
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _timeView: UIView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { 35 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(date: TimePeriod, isSelected: Bool, isEnable: Bool) {
        _timeLabel.text = "\(date.startTime) - \(date.endTime)"
        _timeView.borderColor = ColorBrand.white
        _timeView.backgroundColor = isSelected ? ColorBrand.white : ColorBrand.clear
        _timeLabel.textColor = isSelected ? ColorBrand.brandGray : ColorBrand.white
    }
}
