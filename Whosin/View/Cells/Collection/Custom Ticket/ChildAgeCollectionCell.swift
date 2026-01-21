import UIKit
import DropDown

class ChildAgeCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _childAgeTitle: CustomLabel!
    @IBOutlet private weak var _selectedAge: CustomLabel!
    @IBOutlet private weak var _selectBtn: CustomButton!
    
    let dropDown = DropDown()
    
    // Callback when a child age is picked (age in years)
    var onAgePicked: ((Int) -> Void)?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 62.0 }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Setup
    // --------------------------------------

    public func setup(_ title: String, yrs: String?) {
        _selectedAge.text = (yrs == nil || yrs == "-1") ? "select_age".localized() : "\(yrs ?? "") yrs"
        _childAgeTitle.text = title
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------


    @IBAction private func _handleSelectAgeEvent(_ sender: CustomButton) {
        dropDown.dataSource = ["0 yrs","1 yrs","2 yrs","3 yrs","4 yrs","5 yrs","6 yrs","7 yrs","8 yrs","9 yrs","10 yrs","11 yrs","12+ yrs"]
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        dropDown.direction = .bottom
        dropDown.backgroundColor = ColorBrand.cardBgColor
        dropDown.textColor = ColorBrand.white
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self._selectedAge.text = item
            let digits = item.compactMap { $0.isNumber ? Int(String($0)) : nil }
            let parsed = digits.reduce(0) { $0 * 10 + $1 }
            let age = min(parsed, 11)
            self.onAgePicked?(age)
        }

    }
    
}

