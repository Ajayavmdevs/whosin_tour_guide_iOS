import UIKit
import ExpandableLabel

class HotelRoomsOptionCell: UITableViewCell {
    
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet private weak var _roomtype: CustomLabel!
    @IBOutlet private weak var _checkIn: UILabel!
    @IBOutlet private weak var _checkOut: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _refundableText: UILabel!
    @IBOutlet private weak var _price: CustomLabel!
    @IBOutlet weak var _height: NSLayoutConstraint!
    @IBOutlet private weak var _roomImages: UIImageView!
    @IBOutlet private weak var _refundBgView: UIView!
    @IBOutlet weak var _timingStackView: UIStackView!
    
    private let kCellIdentifier = String(describing: RoomsCollectionCell.self)
    private var hotelInfo: JPHotelInfoModel?
    private var availibility: JPHotelAvailibilityOptionModel?
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        disableSelectEffect()
    }
    
    public func setupdata(_ model: JPHotelAvailibilityOptionModel, hotelInfo: JPHotelInfoModel?, isSelected: Bool) {
        _roomImages.loadWebImage(hotelInfo?.images.toArray(ofType: String.self).first ?? "")
        _mainView.borderColor = isSelected ? ColorBrand.brandGreen : ColorBrand.tabUnselect
        _mainView.backgroundColor = isSelected ? ColorBrand.brandGreen.withAlphaComponent(0.1) : ColorBrand.cardBgColor
        availibility = model
        self.hotelInfo = hotelInfo
        _refundableText.text = model.nonRefundable == "true" ? "non_refundable".localized() : "refundable".localized()
        _refundBgView.backgroundColor = model.nonRefundable == "true" ? ColorBrand.buyNowColor : ColorBrand.brandPink
        _checkIn.text = "CheckIn".localized() +  "\(hotelInfo?.checkTime?.checkIn ?? "")"
        _checkOut.text = "CheckOut".localized() + "\(hotelInfo?.checkTime?.checkOut ?? "")"
        _checkIn.isHidden = Utils.stringIsNullOrEmpty(hotelInfo?.checkTime?.checkIn)
        _checkOut.isHidden = Utils.stringIsNullOrEmpty(hotelInfo?.checkTime?.checkOut)
        _timingStackView.isHidden = Utils.stringIsNullOrEmpty(hotelInfo?.checkTime?.checkOut) && Utils.stringIsNullOrEmpty(hotelInfo?.checkTime?.checkIn)
        _roomtype.text = (model.board?.boardName ?? "") + " | " + (model.board?.typeCode ?? "")
        _price.attributedText = "\(Utils.getCurrentCurrencySymbol()) \(model.price?.nett ?? "")".withCurrencyFont(14)
        _height.constant = CGFloat(model.hotelRooms.count * 82)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @objc private func labelTapped() {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "description".localized()
        vc.disclaimerdescriptions = hotelInfo?.infoDescription ?? ""
        parentBaseController?.presentAsPanModal(controller: vc)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: RoomsCollectionCell.self, kCellHeightKey: RoomsCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1,
            rows: 3,
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        guard let model = availibility else { return }
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        model.hotelRooms.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: RoomsCollectionCell.self,
                kCellHeightKey: RoomsCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }
    
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension HotelRoomsOptionCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? RoomsCollectionCell, let object = cellDict?[kCellObjectDataKey] as? JPHotelRoomModel {
            cell.setupData(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
}

extension HotelRoomsOptionCell: ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        labelTapped()
        label.collapsed = false
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
    }
}
