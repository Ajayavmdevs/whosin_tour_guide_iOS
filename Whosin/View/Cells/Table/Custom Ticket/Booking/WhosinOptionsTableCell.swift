import UIKit
import ExpandableLabel

class WhosinOptionsTableCell: UITableViewCell {

    @IBOutlet weak var _discountValue: CustomLabel!
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var _title: CustomLabel!
    @IBOutlet weak var _description: ExpandableLabel!
    @IBOutlet weak var _optionImage: UIImageView!
    @IBOutlet weak var _discountText: CustomLabel!
    @IBOutlet weak var _startDate: CustomLabel!
    @IBOutlet weak var _endDate: CustomLabel!
    @IBOutlet weak var _days: CustomLabel!
    @IBOutlet weak var _totalSeats: CustomLabel!
    @IBOutlet weak var _adultCount: CustomLabel!
    @IBOutlet weak var _adultPrice: CustomLabel!
    @IBOutlet weak var _childCount: CustomLabel!
    @IBOutlet weak var _childPrice: CustomLabel!
    @IBOutlet weak var _childStack: UIStackView!
    @IBOutlet weak var _infantCount: CustomLabel!
    @IBOutlet weak var _infantPrice: CustomLabel!
    @IBOutlet weak var _infantStack: UIStackView!
    @IBOutlet weak var _totalPrice: CustomLabel!
    @IBOutlet weak var _timeView: CustomLabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: WhosinTimeCollectionCell.self)
    private var _optionModel: WhosinOptionModel?
    private var _selectedIndex: Int?
    
    let titleFont = FontBrand.SFboldFont(size: 12.0)
    let subtitleFont = FontBrand.SFregularFont(size: 12.0)
    
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
        _setupUi()
        _optionImage.isUserInteractionEnabled = false
    }
    
    private func _setupUi() {
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false

    }
    
    private var _prototypes: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: WhosinTimeCollectionCell.self, kCellHeightKey: WhosinTimeCollectionCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if _optionModel?.availabilityType == "regular" {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: _optionModel?.availabilityTime ?? kEmptyString,
                kCellClassKey: WhosinTimeCollectionCell.self,
                kCellHeightKey: WhosinTimeCollectionCell.height
            ])
        } else {
            _optionModel?.availabilityTimeSlot.forEach { guest in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: guest,
                    kCellClassKey: WhosinTimeCollectionCell.self,
                    kCellHeightKey: WhosinTimeCollectionCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }

    public func setup(_ model: WhosinOptionModel, isSelected: Bool = false) {
        if model.availabilityType == "regular" {
            _selectedIndex = isSelected ? 0 : nil
        } else {
            _selectedIndex = nil
        }
        _optionModel = model
        _mainView.borderColor = isSelected ? ColorBrand.brandPink : ColorBrand.brandGray
        _mainView.borderWidth = isSelected ? 1 : 0.5
        _title.text = model.title
        _description.text = model.optionDescription
        _optionImage.loadWebImage(model.images.toArray(ofType: String.self).first ?? "")
        _startDate.attributedText = Utils.setAtributedTitleText(title: "start_date".localized(), subtitle: Utils.dateToString(model.startDate, format: kFormatDateReview), titleFont: titleFont, subtitleFont: subtitleFont)
        _endDate.attributedText = Utils.setAtributedTitleText(title: "end_Date".localized(), subtitle: Utils.dateToString(model.endDate, format: kFormatDateReview), titleFont: titleFont, subtitleFont: subtitleFont)
        _totalSeats.attributedText = Utils.setAtributedTitleText(title: "available_seats".localized(), subtitle: "\(model.availableSeats)", titleFont: titleFont, subtitleFont: subtitleFont)
//        _days.attributedText = Utils.setAtributedTitleText(title: "Available Days: ", subtitle: model.availableDays, titleFont: titleFont, subtitleFont: subtitleFont)
        _days.isHidden = true
        let adultPrice = model.amount * Double(BOOKINGMANAGER.adults)
        let childPrice = model.amountForChild * Double(BOOKINGMANAGER.childs)
        let infantPrice = model.amountForChild * Double(BOOKINGMANAGER.infants)

        let totalAmount = adultPrice + childPrice + infantPrice

        Utils.setPriceLabel(label: _adultPrice, originalPrice: model.amount, discountedPrice: model.amount)
        Utils.setPriceLabel(label: _childPrice, originalPrice: model.amountForChild, discountedPrice: model.amountForChild)
        Utils.setPriceLabel(label: _infantPrice, originalPrice: model.amountForChild, discountedPrice: model.amountForChild)
        
        _adultCount.text = LANGMANAGER.localizedString(forKey: "adult_count", arguments: ["value": "\(BOOKINGMANAGER.adults)"])
        _childCount.text = LANGMANAGER.localizedString(forKey: "child_count", arguments: ["value": "\(BOOKINGMANAGER.childs)"])
        _infantCount.text = LANGMANAGER.localizedString(forKey: "infant_count", arguments: ["value": "\(BOOKINGMANAGER.infants)"])
        _childStack.isHidden = BOOKINGMANAGER.childs <= 0
        _infantStack.isHidden = BOOKINGMANAGER.infants <= 0
        _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont(16)
        _discountValue.attributedText = "\(Utils.getCurrentCurrencySymbol()) \(model.withoutDiscountAmount)".withCurrencyFont(16)
        _discountValue.isHidden = model.withoutDiscountAmount == totalAmount
        _loadData()
    }
}

extension WhosinOptionsTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? WhosinTimeCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? String else { return }
        cell.setup(object, isSelected: _selectedIndex == indexPath.row)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: WhosinTimeCollectionCell.height)
    }

    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        _selectedIndex = indexPath.row
        _collectionView.reloadData()

    }
}
