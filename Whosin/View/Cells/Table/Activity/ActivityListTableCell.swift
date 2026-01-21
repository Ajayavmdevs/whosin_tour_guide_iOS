import UIKit
import ExpandableLabel

class ActivityListTableCell: UITableViewCell {
    
    @IBOutlet private weak var _disclaimerDesc: ExpandableLabel!
    @IBOutlet private weak var _disclaimerTitle: UILabel!
    @IBOutlet private weak var _disclaimerView: UIView!
    @IBOutlet weak var _reservationandActivityStack: UIStackView!
    @IBOutlet private weak var _reservationStart: UILabel!
    @IBOutlet private weak var _reservationEnd: UILabel!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet weak var _activityTimeSlot: UILabel!
    @IBOutlet private weak var _buyNowView: UIView!
    @IBOutlet private weak var _buyNowButton: UIButton!
    @IBOutlet weak var _bucketListView: UIView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _slotCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: ActivityListCollectionCell.self)
    private let kTimeCellIdentifier = String(describing: TimeCollectionCell.self)
    public var activityModel: ActivitiesModel?
    private var slots: [AvilableDateTimeModel] = []

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
        _setUplabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        //TABLE VIEW
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 2,
                              rows: 5,
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
        _slotCollectionView.setup(cellPrototypes: _prototypes,
                                  hasHeaderSection: false,
                                  enableRefresh: false,
                                  columns: 5,
                                  rows: 1,
                                  edgeInsets: UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0),
                                  
                                  scrollDirection: .vertical,
                                  emptyDataText: nil,
                                  emptyDataIconImage: nil,
                                  delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ActivityListCollectionCell.self, kCellHeightKey: ActivityListCollectionCell.height], [kCellIdentifierKey: kTimeCellIdentifier, kCellNibNameKey: kTimeCellIdentifier, kCellClassKey: TimeCollectionCell.self, kCellHeightKey: TimeCollectionCell.height]]
    }
    
    private func _loadActivityData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let features = activityModel?.avilableFeatures else { return }
        if !features.isEmpty {
            features.forEach({ data in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: data,
                    kCellClassKey: ActivityListCollectionCell.self,
                    kCellHeightKey: ActivityListCollectionCell.height
                ])
            })
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        _collectionViewHieghtConstraint.constant = 18 * CGFloat(cellData.count)
        _buyNowView.isHidden = activityModel?.isPriceZero ?? true
        _collectionView.reload()
    }
    
    private func _loadDealsData(_ model: DealsModel?) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let features = model?.features else { return }
        if !features.isEmpty {
            features.forEach({ data in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: data,
                    kCellClassKey: ActivityListCollectionCell.self,
                    kCellHeightKey: ActivityListCollectionCell.height
                ])
            })
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        _collectionViewHieghtConstraint.constant = 18 * CGFloat(cellData.count)
        _buyNowView.isHidden = model?.isZeroPrice ?? true
        _collectionView.reload()
    }
    
    private func _loadTimeData() {
        _slotCollectionView.isHidden = false
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if !slots.isEmpty {
            slots.forEach { slot in
                cellData.append([
                    kCellIdentifierKey: kTimeCellIdentifier,
                    kCellTagKey: kTimeCellIdentifier,
                    kCellObjectDataKey: slot,
                    kCellClassKey: TimeCollectionCell.self,
                    kCellHeightKey: TimeCollectionCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _slotCollectionView.loadData(cellSectionData)
    }
    
    private func _setUplabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _disclaimerDesc.isUserInteractionEnabled = true
        _disclaimerDesc.addGestureRecognizer(tapGesture)
        _disclaimerDesc.delegate = self
        _disclaimerDesc.shouldCollapse = true
        _disclaimerDesc.numberOfLines = 2
        _disclaimerDesc.ellipsis = NSAttributedString(string: "...")
        _disclaimerDesc.collapsedAttributedLink = NSAttributedString(string: "see_more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _disclaimerDesc.setLessLinkWith(lessLink: "less", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
    }
    
    @objc private func labelTapped() {
        _disclaimerDesc.collapsed.toggle()
        (self.superview as? CustomTableView)?.update()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: ActivitiesModel) {
        activityModel = model
        _reservationStart.text = model.reservationStart?.display
        _reservationEnd.text = model.reservationEnd?.display
        _startDate.text = model.startDate?.display
        _endDate.text = model.endDate?.display
        _activityTimeSlot.isHidden = model.time?.type == "slot" ? false : true
        if Utils.stringIsNullOrEmpty(model.disclaimerTitle) && Utils.stringIsNullOrEmpty(model.disclaimerDescription) {
            _disclaimerView.isHidden = true
        } else {
            _disclaimerView.isHidden = false
            _disclaimerTitle.text = model.disclaimerTitle
            _disclaimerDesc.text = model.disclaimerDescription
        }
        _buyNowButton.setTitle(model.isReservationEnd ? "expired".localized() : "buy_now".localized())
        _buyNowButton.setTitleColor(model.isReservationEnd ? ColorBrand.brandPink : ColorBrand.white, for: .normal)
        _buyNowView.backgroundColor = model.isReservationEnd ? .clear : ColorBrand.brandBtnBgColor
        _buyNowButton.isEnabled = model.isReservationEnd ? false : true
        _bucketListView.isHidden = model.isActivityExpired ? true : false
        
        _loadActivityData()
        guard let slot = model.time?.slot.toArrayDetached(ofType: AvilableDateTimeModel.self) else { return }
        slots = slot
        if !slot.isEmpty { _loadTimeData() }
    }

    public func setupDealsData(_ model: DealsModel) {
        _reservationandActivityStack.isHidden = true
        _loadDealsData(model)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleAddToBucketListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(BucketListBottomSheet.self)
        presentedViewController.activityId = activityModel?.id ?? kEmptyString
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
        guard let model = activityModel else { return }
        let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        vc.isFromActivity = true
        vc.type = "activity"
        vc.activityModel.append(model)
        vc.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ActivityListTableCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ActivityListCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? AvilableFeaturesModel {
                cell.setupData(object)

            } else if let object = cellDict?[kCellObjectDataKey] as? CommonSettingsModel {
                cell.setupDealsData(object)
            }
        } else if let cell = cell as? TimeCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? AvilableDateTimeModel else { return }
            cell.setUpdata(object.time, isActivity: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if collectionView == _slotCollectionView {
            return CGSize(width: 100, height: TimeCollectionCell.height)
        }
        return CGSize(width: collectionView.frame.width / 2, height: ActivityListCollectionCell.height)
    }
}

extension ActivityListTableCell:  ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
}
