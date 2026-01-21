import UIKit

class ExploreBannerTableCell: UITableViewCell {
    
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _subTitleText: CustomLabel!
    private let kCellIdentifier = String(describing: ExploreBannerCollectionCell.self)
    private var _bannerList: [ExploreBannerModel] = []
    private var bannerRatio: CGFloat = 1.0
    private var screenWidth = kScreenWidth
    private var hasInitializedLayout = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    private func resetLayoutState() {
        hasInitializedLayout = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetLayoutState()
        _collectionHeight.constant = 0 // Reset height
        _bannerList.removeAll()
    }
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeightIfNeeded()
        _collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                            verticalFittingPriority: UILayoutPriority) -> CGSize {
            // Always calculate fresh height based on current ratio
            _collectionView.layoutIfNeeded()
            let height = screenWidth / bannerRatio
            if _collectionHeight.constant != height {
                _collectionHeight.constant = height
                setNeedsLayout()
            }
            
            return super.systemLayoutSizeFitting(targetSize,
                                               withHorizontalFittingPriority: horizontalFittingPriority,
                                               verticalFittingPriority: verticalFittingPriority)
        }
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ExploreBannerCollectionCell.self, kCellHeightKey: ExploreBannerCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _bannerList.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: ExploreBannerCollectionCell.self,
                kCellHeightKey: screenWidth / bannerRatio,
            ])
            
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        updateCollectionViewHeightIfNeeded()
    }
    
    private func updateCollectionViewHeightIfNeeded() {
        guard !hasInitializedLayout else { return }

        let calculatedHeight = screenWidth / bannerRatio
        if _collectionHeight.constant != calculatedHeight {
            _collectionHeight.constant = calculatedHeight
            setNeedsLayout()
        }
    }
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    
    public func setup(_ model: HomeBlockModel) {
        if !self.hasInitializedLayout {
            if let ratioString = model.size?.ratio {
                self.bannerRatio = Utils.parseRatio(ratioString)
            } else {
                self.bannerRatio = 1.0
            }
            self.screenWidth = kScreenWidth - 20
            self.updateCollectionViewHeightIfNeeded()
            self.hasInitializedLayout = true
            self._collectionView.collectionViewLayout.invalidateLayout()
        }
        self._titleText.text = model.title
        self._subTitleText.text = model.descriptions
        self._titleText.isHidden = !model.showTitle
        self._subTitleText.isHidden = !model.showTitle
        self._bannerList = model.bannerList
        self._loadData()
    }
    
}

extension ExploreBannerTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ExploreBannerCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? ExploreBannerModel {
                cell.setupData(object.mediaType == "video" ? object.thumbnail : object.media,title: object.title, subtitle: object.descriptions)
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        screenWidth = _bannerList.count == 1 ? collectionView.frame.width - 28 : kScreenWidth * 0.9
        let height = screenWidth / bannerRatio
        return CGSize(width: screenWidth, height: height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if let object = cellDict?[kCellObjectDataKey] as? ExploreBannerModel {
            if (object.type == "ticket") {
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = object.typeId
                vc.hidesBottomBarWhenPushed = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else if (object.type == "category") {
                let controller = INIT_CONTROLLER_XIB(ExploreDetailVC.self)
                controller.selectedFilter = object.typeId
                controller.titleText = APPSETTING.exploreCategories?.first(where: { $0.id == object.typeId })?.title ?? object.title
                controller.hidesBottomBarWhenPushed = false
                parentViewController?.navigationController?.pushViewController(controller, animated: true)
            } else if (object.type == "city") {
                let controller = INIT_CONTROLLER_XIB(ExploreDetailVC.self)
                controller.isFromCities = true
                controller.selectedFilter = object.typeId
                controller.titleText = APPSETTING.cityList?.first(where: { $0.id == object.typeId })?.name ?? object.title
                controller.hidesBottomBarWhenPushed = false
                parentViewController?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
}
