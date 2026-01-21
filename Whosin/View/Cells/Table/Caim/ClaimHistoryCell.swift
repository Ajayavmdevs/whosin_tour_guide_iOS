import UIKit

class ClaimHistoryCell: UITableViewCell {

    @IBOutlet private weak var _discountCharges: UILabel!
    @IBOutlet private weak var _totalDiscountCharge: UILabel!
    @IBOutlet private weak var discountTitleTxt: UILabel!
    @IBOutlet private weak var _customVenueInfo: CustomVenueInfoView!
    @IBOutlet private weak var _claimId: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _collecitonHightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _brunchTable: UIView!
    @IBOutlet private weak var _totalDiscountStack: UIStackView!
    @IBOutlet private weak var _totalPrice: UILabel!
    @IBOutlet private weak var _discountPrice: UILabel!
    @IBOutlet private weak var _numberOfPersion: UILabel!
    @IBOutlet private weak var _discountBadge: UIButton!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: ClaimItemCollectionCell.self)
    private var _specialOffer: SpecialOffersModel?
    private var _brunches: [BrunchModel] = []
    private var _venueId: String = kEmptyString
    private var _venueDeail: VenueDetailModel?
    private var _logoHeroId: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._discountBadge.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
        setupUI()
    }
    
    private func setupUI() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 3,
                              scrollDirection: .vertical,
                              emptyDataText: kEmptyString,
                              emptyDataIconImage: UIImage(named: "empty_cart"),
                              emptyDataDescription: "empty_claim".localized(),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ClaimItemCollectionCell.self, kCellHeightKey: ClaimItemCollectionCell.height]]
    }
    

    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _brunches.forEach { data in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: data,
                kCellClassKey: ClaimItemCollectionCell.self,
                kCellHeightKey: ClaimItemCollectionCell.height
            ])
        }
        if cellData.count < 4 {
            _collecitonHightConstraint.constant = CGFloat(cellData.count * 60)
        } else {
            _collecitonHightConstraint.constant = CGFloat(3 * 60)
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    public func setupData(_ model: ClaimHistoryModel) {
        _venueDeail = model.venue
        let totalAmount = model.billAmount
        let discount = Utils.calculateDiscountValueInt(originalPrice: model.billAmount, discountPercentage: model.specialOffer?.discount)
        _customVenueInfo.setupData(venue: model.venue ?? VenueDetailModel(), isAllowClick: true)
        if model.specialOffer?.discount == 0 {
            _discountBadge.isHidden = true
        } else {
            _discountBadge.isHidden = false
        }
        _numberOfPersion.text = "\(model.totalPerson)"
        _discountBadge.setTitle("\(model.specialOffer?.discount ?? 0)%")
        let date = Utils.stringToDate(model.createdAt, format: kStanderdDate)
        _dateLabel.text = Utils.dateToString(date, format: "dd MMM yyyy - HH:mm")
        _claimId.text = model.claimId
        _specialOffer = model.specialOffer
        _brunches = model.brunch.toArrayDetached(ofType: BrunchModel.self)
        if model.type == "brunch" {
            _discountCharges.text = "discount_charges".localized()
            _totalDiscountCharge.text = "D\(model.brunch.reduce(0) { $0 + ($1.pricePerBrunch * $1.qty)})"
            _totalPrice.text = "D\(model.brunch.reduce(0) { $0 + $1.total })"
            _discountPrice.text = "D\(model.brunch.reduce(0) { $0 + $1.discount } )"
            _totalDiscountStack.isHidden = true
            _brunchTable.isHidden = false
        } else {
            _discountCharges.text = "discount_charges".localized()
            _totalDiscountCharge.text = "D\(model.totalPerson * (model.specialOffer?.pricePerPerson ?? 0))"
            _totalPrice.text = "D\(totalAmount)"
            _discountPrice.text = "D\(totalAmount - discount)"
            _brunchTable.isHidden = true
            _totalDiscountStack.isHidden = false
        }
        if _totalDiscountCharge.text == "D0" { _totalDiscountCharge.text = "free".localized() }
        _loadData()
        _venueId = model.venue?.id ?? kEmptyString
    }
}

extension ClaimHistoryCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ClaimItemCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? BrunchModel {
            cell.setupBruncData(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: ClaimItemCollectionCell.height)
    }
}
