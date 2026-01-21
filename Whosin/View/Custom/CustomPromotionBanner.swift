import UIKit
import Lightbox
import SnapKit

class CustomPromotionBanner: UIView {
    
    @IBOutlet weak var _collecitonView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: PromotionalBannerCollectionCell.self)
    private var _bannerList: [BannerModel] = []
    private var bannerRatio: CGFloat = 1.0
    private var screenWidth = kScreenWidth
    private var hasInitializedLayout = false
    var currentPage = 0
    var _pageControl: CustomPageControll!

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setup()
    }
    
    private func _setup() {
        setupUi()
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: PromotionalBannerCollectionCell.self, kCellHeightKey: PromotionalBannerCollectionCell.height]]
    }
    
    private func setupUi() {
        _collecitonView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              rows: 1,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collecitonView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
        _collecitonView.isPagingEnabled = false
        _collecitonView.proxyDelegate = self
    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _bannerList.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: PromotionalBannerCollectionCell.self,
                kCellHeightKey: screenWidth / bannerRatio,
            ])
            
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collecitonView.loadData(cellSectionData)
    }
    
    public func pauseVideos() {
        _collecitonView.visibleCells.forEach { cell in
            if let videoCell = cell as? PromotionalBannerCollectionCell {
                videoCell.pauseVideo()
            }
        }
    }
    
    public func resumeVideos() {
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            if let currentCell = self._collecitonView.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? PromotionalBannerCollectionCell {
                let isVideo = self._bannerList[self.currentPage].mediaUrls.first?.hasSuffix(".mp4")
                if isVideo  == true {
                    currentCell.resumeVideo()
                } else {
                    currentCell.pauseVideo()
                }
            }
        }
    }


    public func setup(_ model: PromotionalBannerItemModel) {
        setupUi()
        if let ratioString = model.size?.ratio {
            self.bannerRatio = Utils.parseRatio(ratioString)
        } else {
            self.bannerRatio = 1.0
        }
        self.screenWidth = kScreenWidth - 20
        self._collecitonView.collectionViewLayout.invalidateLayout()
        self._bannerList = model.banners
        self._loadData()
    }


    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomPromotionBanner", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    
}

extension CustomPromotionBanner: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate, UIScrollViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PromotionalBannerCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? BannerModel {
                cell.setupData(object, url: object.mediaUrls.first ?? "")
                if Utils.isVideo(object.mediaUrls.first ?? "") {
                    cell.resumeVideo()
                }
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        screenWidth = _bannerList.count == 1 ? collectionView.frame.width - 28 : kScreenWidth * 0.9
        let height = screenWidth / bannerRatio
        return CGSize(width: screenWidth, height: height)
    }
    
    func willDisplay(_ collectionView: UICollectionView, cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PromotionalBannerCollectionCell {
            cell.resumeVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PromotionalBannerCollectionCell {
            cell.pauseVideo()
        }
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = _collecitonView.frame.size.width - _collecitonView.contentInset.left - _collecitonView.contentInset.right
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        print("Page ===", currentPage)
        self.currentPage = currentPage
        
        
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._collecitonView.visibleCells.forEach { tmpCell in
                if let tmpCell = tmpCell as? PromotionalBannerCollectionCell {
                    tmpCell.pauseVideo()
                }
            }
            
            if let currentCell = self._collecitonView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as? PromotionalBannerCollectionCell {
                let isVideo = self._bannerList[currentPage].mediaUrls.first?.hasSuffix(".mp4")
                if isVideo == true {
                    currentCell.resumeVideo()
                } else {
                    currentCell.pauseVideo()
                }
            }
        }
    }

    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PromotionalBannerCollectionCell else { return }
        cell.pauseVideo()
        guard let object = cellDict?[kCellObjectDataKey] as? BannerModel else { return }
        parentBaseController?.feedbackGenerator?.impactOccurred()
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
        } else if object.type == "link" {
            _openURL(urlString: object.typeId)
        } else if object.type == "activity" {
            _openActivity(id: object.typeId, name: "")
        }
    }
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func _openActivity(id: String, name: String) {
    }

}
