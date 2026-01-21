import UIKit

class ActivityInfoVC: ChildViewController {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierActivityImage = String(describing: ActivityImageTableCell.self)
    private let kCellIdentifierDescription = String(describing: VenueDescTableCell.self)
    private let kCellIdentifierRating = String(describing: RatingTableCell.self)
    private let kCellIdentifierActivityList = String(describing: ActivityListTableCell.self)
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    
    var activityModel: ActivitiesModel?
    var activityId: String = kEmptyString
    var activityName: String = kEmptyString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _loadData(true)
    }
    
    override func setupUi() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no activiy info available",
            emptyDataIconImage: UIImage(named: "empty_feed"),
            emptyDataDescription: nil,
            delegate: self)
        getActivityDetail()
        _visualEffectView.alpha = 0
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
    }
    
    private func getActivityDetail() {
        WhosinServices.getActivityDetail(activityId: activityId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else {
                self.dismissOrBack()
                return
            }
            self.activityModel = data
            self._venueInfoView.setupProviderData(venue: data.provider ?? ProviderModel())
            self._loadData(false)
        }
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        _tableView.clearAndReload()
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: "",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            guard let activityModel = activityModel else { return }

            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivityImage,
                kCellTagKey: kCellIdentifierActivityImage,
                kCellObjectDataKey: activityModel,
                kCellClassKey: ActivityImageTableCell.self,
                kCellHeightKey: ActivityImageTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDescription,
                kCellTagKey: kCellIdentifierDescription,
                kCellObjectDataKey: activityModel,
                kCellClassKey: VenueDescTableCell.self,
                kCellHeightKey: VenueDescTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierRating,
                kCellTagKey: kCellIdentifierRating,
                kCellObjectDataKey: activityModel,
                kCellClassKey: RatingTableCell.self,
                kCellHeightKey: RatingTableCell.height
            ])

            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivityList,
                kCellTagKey: kCellIdentifierActivityList,
                kCellObjectDataKey: activityModel,
                kCellClassKey: ActivityListTableCell.self,
                kCellHeightKey: ActivityListTableCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierActivityImage, kCellNibNameKey: kCellIdentifierActivityImage, kCellClassKey: ActivityImageTableCell.self, kCellHeightKey: ActivityImageTableCell.height],
            [kCellIdentifierKey: kCellIdentifierDescription, kCellNibNameKey: kCellIdentifierDescription, kCellClassKey: VenueDescTableCell.self, kCellHeightKey: VenueDescTableCell.height],
            [kCellIdentifierKey: kCellIdentifierRating, kCellNibNameKey: kCellIdentifierRating, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierActivityList, kCellNibNameKey: kCellIdentifierActivityList, kCellClassKey: ActivityListTableCell.self, kCellHeightKey: ActivityListTableCell.height]
        ]
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleReload() {
        getActivityDetail()
    }
    
}

extension ActivityInfoVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ActivityImageTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(data: object)
            cell._activityName.text = activityName
        } else if let cell = cell as? VenueDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupActivityData(object)
        } else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.delegate = self
            cell.setupActivityData(object, isFromActivity: true)
        } else if let cell = cell as? ActivityListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
}

extension ActivityInfoVC: desableScrollWhenRatingDelegate {
    func enableScrollEffect() {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._tableView.isScrollEnabled = true
        }
    }
    
    func desableScrollEffect() {
        _tableView.isScrollEnabled = false
    }
}
