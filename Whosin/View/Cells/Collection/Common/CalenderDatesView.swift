import UIKit

class CalenderDatesView: UICollectionViewCell {

    @IBOutlet weak var _moreDateView: UIView!
    @IBOutlet weak var _dateView: UIView!
    @IBOutlet weak var _weekLabel: CustomLabel!
    @IBOutlet weak var _dayLabel: CustomLabel!
    @IBOutlet weak var _monthLabel: CustomLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class var height: CGFloat {
        70
    }


    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ date: Date?, isLast: Bool = false, isSelected: Bool = false) {
        if isLast {
            _dateView.isHidden = true
            _moreDateView.isHidden = false
        } else {
            _dateView.isHidden = false
            _moreDateView.isHidden = true
            guard let date = date else { return }
            configure(date: date, isSelected: isSelected)
        }
        
    }

    func configure(date: Date, isSelected: Bool) {
        _weekLabel.text = Utils.dateToString(date, format: "E").uppercased()
        _dayLabel.text = Utils.dateToString(date, format: "dd").uppercased()
        _monthLabel.text = Utils.dateToString(date, format: "MMM").uppercased()
        _dateView.borderColor = isSelected ? ColorBrand.brandGreen : .clear
        _dateView.borderWidth = 1
    }
    
}
