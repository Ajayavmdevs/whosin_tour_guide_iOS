import UIKit

class ActivityOfferTableCell: UITableViewCell {
    
    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _avilableDays: UILabel!
    @IBOutlet private weak var _menuButton: UIButton!
    @IBOutlet private weak var _featuresNameSec: UILabel!
    @IBOutlet private weak var _featuresImageSec: UIImageView!
    @IBOutlet private weak var _featuresNameFirst: UILabel!
    @IBOutlet private weak var _featuresIconFirst: UIImageView!
    @IBOutlet private weak var _activityTitle: UILabel!
    @IBOutlet private weak var _priceView: CustomBadgeView!
    @IBOutlet private weak var _ratingLabel: UILabel!
    @IBOutlet private weak var _avgRatingView: UIView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _reservationStart: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet private weak var _reservationEnd: UILabel!
    @IBOutlet private weak var _description: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _activityTimeSlot: UILabel!
    @IBOutlet private weak var _paxasStackone: UIStackView!
    @IBOutlet private weak var _paxasStackTwo: UIStackView!
    @IBOutlet private weak var _buyNowView: UIView!
    @IBOutlet private weak var _buyNowButton: UIButton!
    @IBOutlet weak var _bucketListView: UIView!
    public var delegate: ReloadBucketList?
    
    private var slots: [AvilableDateTimeModel] = []
    private var activityId: String = kEmptyString
    public var bucketId:String = kEmptyString
    private var _activityModel: ActivitiesModel?
    private let kTimeCellIdentifier = String(describing: TimeCollectionCell.self)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _priceView.roundCorners(corners: [.bottomLeft], radius: 10)
        _setupUi()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _collectionView.reload()
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestRemoveItem() {
        var params: [String: Any] = [:]
        params["id"] = bucketId
        params["action"] = "delete"
        params["activityId"] = activityId
        WhosinServices.addRemoveBucketList(params: params) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self.parentViewController?.view.makeToast(data.message)
            self.delegate?.reload()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kTimeCellIdentifier, kCellNibNameKey: kTimeCellIdentifier, kCellClassKey: TimeCollectionCell.self, kCellHeightKey: TimeCollectionCell.height]
        ]
    }
    
    private func _loadTimeData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        slots.forEach { slot in
            cellData.append([
                kCellIdentifierKey: kTimeCellIdentifier,
                kCellTagKey: kTimeCellIdentifier,
                kCellObjectDataKey: slot,
                kCellClassKey: TimeCollectionCell.self,
                kCellHeightKey: TimeCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private func _openActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "remove".localized(), style: .destructive, handler: {action in
            DISPATCH_ASYNC_MAIN {
                self.parentBaseController?.showCustomAlert(title: kAppName, message: "remove_offer_from_bucket".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
                    self._requestRemoveItem()
                }, noHandler:  { UIAlertAction in
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "move_to_another_bucket".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self._moveToanotherBucket() }
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
    
    private func _moveToanotherBucket() {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.activityId = activityId
        presentedViewController._bucketId = bucketId
        presentedViewController.isFromMoveToAnother = true
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: ActivitiesModel, isFromBucket: Bool = false) {
        _activityModel = model
        _priceView.isHidden = isFromBucket
        _menuButton.isHidden = !isFromBucket
        _paxasStackone.isHidden = model.avilableFeatures.isEmpty
        _paxasStackTwo.isHidden = !(model.avilableFeatures.count > 1)
        _collectionView.isHidden = model.time?.type == "slot" ? false: true
        _activityTimeSlot.isHidden = model.time?.type == "slot" ? false : true
        _venueInfoView.setupProviderData(venue: model.provider ?? ProviderModel())
        activityId = model.id
        _activityTitle.text = model.name
        _coverImage.loadWebImage(model.cover)
        _description.text = model.descriptions
        _ratingLabel.text = String(format: "%.1f", model.avgRating)
        _reservationStart.text = model.reservationStart?.display
        _reservationEnd.text = model.reservationEnd?.display
        _startDate.text = model._startDate
        _endDate.text = model._endDate
        
        _buyNowButton.setTitle(model.isReservationEnd ? "expired".localized() : "buy_now".localized())
        _buyNowButton.setTitleColor(model.isReservationEnd ? ColorBrand.brandPink : ColorBrand.white, for: .normal)
        _buyNowView.backgroundColor = model.isReservationEnd ? .clear : ColorBrand.brandBtnBgColor
        _buyNowButton.isEnabled = model.isReservationEnd ? false : true
        _bucketListView.isHidden = model.isActivityExpired ? true : false
        
        if model.avilableFeatures.count > 0  {
            _featuresNameFirst.text = model.avilableFeatures[0].feature
            _featuresNameSec.text = model.avilableFeatures[1].feature
            _featuresIconFirst.loadWebImage(model.avilableFeatures[0].icon , placeholder: UIImage(named: "icon_activity"))
            _featuresImageSec.loadWebImage(model.avilableFeatures[1].icon , placeholder: UIImage(named: "icon_activity"))
        }
        
        _priceView.setupData(originalPrice: model.price, discountedPrice: model._disocuntedPrice, isNoDiscount: model._isNoDiscount)
        
        _avilableDays.text = model.availableDays
        
        if model.avgRating == 0.0 {
            _avgRatingView.isHidden = true
        }

        guard let slot = model.time?.slot.toArrayDetached(ofType: AvilableDateTimeModel.self) else { return }
        slots = slot
        _buyNowView.isHidden = model.isPriceZero
        _loadTimeData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleAddToBukectListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.activityId = activityId
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
    }
    
    @IBAction private func _handlemenuAction(_ sender: UIButton) {
        _openActionSheet()
    }
    
    @IBAction func _handleOpenVenueEvent(_ sender: UIButton) {
    }
    
    
}

extension ActivityOfferTableCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? TimeCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? AvilableDateTimeModel else { return }
            cell.setUpdata(object.time, isActivity: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: TimeCollectionCell.height)
    }
    
}
