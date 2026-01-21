import UIKit

class ClaimSuccessfullVC: ChildViewController {
    
    @IBOutlet private weak var _discountPerPx: UILabel!
    @IBOutlet private weak var _totalDiscountCharge: UILabel!
    @IBOutlet private weak var _subtitleDiscount: UILabel!
    @IBOutlet private weak var _titleOfDiscount: UILabel!
    @IBOutlet private weak var _badgeBtn: UIButton!
    @IBOutlet private weak var _packagePrice: UILabel!
    @IBOutlet private weak var _totalSavingPrice: UILabel!
    @IBOutlet private weak var _discountPrice: UILabel!
    @IBOutlet private weak var _brunchView: UIView!
    @IBOutlet private weak var _packagesTable: CustomNoKeyboardTableView!
    @IBOutlet private weak var _totalbillStack: UIStackView!
    @IBOutlet private weak var _discountTotalBill: UILabel!
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _venueImage: UIImageView!
    @IBOutlet private weak var _claimId: UILabel!
    @IBOutlet private weak var _hightConstraint: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: ClaimItemCell.self)
    public var isFromBrunch: Bool = false
    public var model: ClaimHistoryModel?
    public var specialOffer: SpecialOffersModel?
    public var venueModel: VenueDetailModel?
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._badgeBtn.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
        guard let model = model else { return }
        let totalAmount = model.billAmount
        let discount = Utils.calculateDiscountValueInt(originalPrice: model.billAmount, discountPercentage: specialOffer?.discount)
        
        self._discountPrice.attributedText = isFromBrunch ? "\(Utils.getCurrentCurrencySymbol())\(model.brunch.reduce(0) { $0 + $1.discount } )".withCurrencyFont(13, false) : "\(Utils.getCurrentCurrencySymbol())\(totalAmount - discount)".withCurrencyFont(13, false)
        self._totalSavingPrice.attributedText = isFromBrunch ? "\(Utils.getCurrentCurrencySymbol())\(model.brunch.reduce(0) { $0 + $1.discount })".withCurrencyFont(13, false) : "\(Utils.getCurrentCurrencySymbol())\(totalAmount)".withCurrencyFont(13, false)
        self._packagePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.billAmount)".withCurrencyFont(13, false)
        _discountPerPx.isHidden = isFromBrunch
        _discountPerPx.attributedText = isFromBrunch ? "(\(Utils.getCurrentCurrencySymbol())\(model.brunch.first?.pricePerBrunch ?? 0))".withCurrencyFont(13, false) : "(\(Utils.getCurrentCurrencySymbol())\(specialOffer?.pricePerPerson ?? 0)/px)".withCurrencyFont(13, false)
        let totalDiscountCharge: String

        if isFromBrunch {
//            if specialOffer?.discount == 50 {
//                totalDiscountCharge = "D\(model.brunch.reduce(0) { $0 + ($1.pricePerBrunch * max(1, $1.qty / 2)) })"
//            } else {
                totalDiscountCharge = "\(Utils.getCurrentCurrencySymbol())\(model.brunch.reduce(0) { $0 + ($1.pricePerBrunch * $1.qty) })"
//            }
        } else {
            totalDiscountCharge = "\(Utils.getCurrentCurrencySymbol())\(model.totalPerson * (specialOffer?.pricePerPerson ?? 0))"
        }
        _totalDiscountCharge.attributedText = totalDiscountCharge.withCurrencyFont(13, false)
        if _totalDiscountCharge.text == "\(Utils.getCurrentCurrencySymbol())0" { _totalDiscountCharge.text = "Free" }
        _subtitleDiscount.isHidden = isFromBrunch
        _badgeBtn.setTitle("\(specialOffer?.discount ?? 0)%")
        _titleOfDiscount.text = specialOffer?.title
        _subtitleDiscount.text = specialOffer?.descriptions
        _claimId.text = model.claimId
        let totalQty = model.brunch.reduce(0) { $0 + $1.qty }
        _discountTotalBill.text = isFromBrunch ? "\(totalQty)" : "\(model.totalPerson)"
        let venue = venueModel//APPSETTING.venueModel?.filter({ $0.id == model.venueId }).first
        _venueName.text = venue?.name
        _venueImage.loadWebImage(venue?.logo ?? "")
        _venueAddress.text = venue?.address
        _brunchView.isHidden = !isFromBrunch
        _totalbillStack.isHidden = isFromBrunch
        _packagesTable.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: "Somthing wrong..!",
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ClaimItemCell.self, kCellHeightKey: ClaimItemCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        model?.brunch.forEach { data in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: data,
                kCellTitleKey: specialOffer?.discount,
                kCellClassKey: ClaimItemCell.self,
                kCellHeightKey: ClaimItemCell.height
            ])
        }
        _hightConstraint.constant = CGFloat(cellData.count * 56)
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _packagesTable.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ClaimSuccessfullVC: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ClaimItemCell {
            if let object = cellDict?[kCellObjectDataKey] as? PackageModel,let specialDiscount = cellDict?[kCellTitleKey] as? Int {
                cell.setupData(object,specialDiscount: specialDiscount, isFromSucces: true) { (data ,error) in
                    let discountPrice = Utils.calculateDiscountValue(originalPrice: object.actualPrice, discountPercentage: Int(object.discount))
                    let discount = object.qty * Int(discountPrice)!
                    let totalAmount = object.qty * object.actualPrice
                    self._discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount - discount)".withCurrencyFont(13, false)
                    self._totalSavingPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discount)".withCurrencyFont(13, false)
                    self._packagePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount)".withCurrencyFont(13, false)
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? BrunchModel {
                cell.setupBruncData(object)
            }
        }
        
    }
}
