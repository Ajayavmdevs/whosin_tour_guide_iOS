import UIKit

class ComplementaryPublicProfileVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierHeader = String(describing: PromoterProfileHeaderCell.self)
    private let KCelllProfileScore = String(describing: ProfileScoreTableCell.self)
    private let kcellDiscription = String(describing: CompDescriptionCell.self)
    private let kCellIdentifierMyCircles = String(describing: PublicCMCircleCell.self)
    private let kCellIdentifierSocial = String(describing: PromoterSocialCell.self)
    private let kCellIdentifierReview = String(describing: RatingTableCell.self)
    private var _complimentaryModel: PromoterProfileModel?
    public var complimentryId: String = kEmptyString
    public var isFromPersonal: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        checkSession()
        setupUi()
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
        _userName.alpha = 0
        _userImg.alpha = 0
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        _requestGetProfile()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestGetProfile() {
        showHUD()
        WhosinServices.getComplementaryPublicProfile(complimentryId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self._complimentaryModel = data
            self._loadData()
        }
    }
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: PromoterProfileHeaderCell.self, kCellHeightKey: PromoterProfileHeaderCell.height],
            [kCellIdentifierKey: KCelllProfileScore, kCellNibNameKey: KCelllProfileScore, kCellClassKey: ProfileScoreTableCell.self, kCellHeightKey: ProfileScoreTableCell.height],
            [kCellIdentifierKey: kcellDiscription, kCellNibNameKey: kcellDiscription, kCellClassKey: CompDescriptionCell.self, kCellHeightKey: CompDescriptionCell.height],
            [kCellIdentifierKey: kCellIdentifierReview, kCellNibNameKey: kCellIdentifierReview, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kCellIdentifierSocial, kCellNibNameKey: kCellIdentifierSocial, kCellClassKey: PromoterSocialCell.self, kCellHeightKey: PromoterSocialCell.height],
            [kCellIdentifierKey: kCellIdentifierMyCircles, kCellNibNameKey: kCellIdentifierMyCircles, kCellClassKey: PublicCMCircleCell.self, kCellHeightKey: PublicCMCircleCell.height]

        ]
    }
    
    private func _loadData(isLoading: Bool = false,selectedIndex: Int = 0) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let model = _complimentaryModel else { return }

        _userName.text = model.profile?.fullName
        _userImg.loadWebImage(model.profile?.image  ?? kEmptyString, name: model.profile?.fullName ?? kEmptyString)

        cellData.append([
            kCellIdentifierKey: kCellIdentifierHeader,
            kCellTagKey: kCellIdentifierHeader,
            kCellObjectDataKey: model,
            kCellClassKey: PromoterProfileHeaderCell.self,
            kCellHeightKey: PromoterProfileHeaderCell.height
        ])
        
        if model.isAdminPromoter, let data = model.rings?.ringList.first(where: { $0.userId == APPSESSION.userDetail?.id })?.circles.toArrayDetached(ofType: UserDetailModel.self), !data.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierMyCircles,
                kCellTagKey: kCellIdentifierMyCircles,
                kCellObjectDataKey: data,
                kCellClassKey: PublicCMCircleCell.self,
                kCellHeightKey: PublicCMCircleCell.height
            ])
        }
        
//        cellData.append([
//            kCellIdentifierKey: KCelllProfileScore,
//            kCellTagKey: KCelllProfileScore,
//            kCellObjectDataKey: model.score,
//            kCellClassKey: ProfileScoreTableCell.self,
//            kCellHeightKey: ProfileScoreTableCell.height
//        ])
        

        
        cellData.append([
            kCellIdentifierKey: kcellDiscription,
            kCellTagKey: kcellDiscription,
            kCellObjectDataKey: model.profile,
            kCellItemsKey: model.logs.toArrayDetached(ofType: LogsModel.self),
            kCellClassKey: CompDescriptionCell.self,
            kCellHeightKey: CompDescriptionCell.height
        ])
        
//        cellData.append([
//            kCellIdentifierKey: kCellIdentifierReview,
//            kCellTagKey: kCellIdentifierReview,
//            kCellObjectDataKey: model.review,
//            kCellClassKey: RatingTableCell.self,
//            kCellHeightKey: RatingTableCell.height
//        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierSocial,
            kCellObjectDataKey: model.profile,
            kCellClassKey: PromoterSocialCell.self,
            kCellHeightKey: PromoterSocialCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @objc func handleReload() {
        _requestGetProfile()
    }

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if isFromPersonal {
            guard let controller = self.navigationController?.viewControllers.first(where: {$0.isKind(of: NewSearchVC.self)}) else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.navigationController?.popToViewController(controller, animated: true)
        } else {
            if self.isVCPresented {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension ComplementaryPublicProfileVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 70
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
                self._userName.alpha = 1.0
                self._userImg.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
                self._userName.alpha = 0.0
                self._userImg.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? PromoterProfileHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  PromoterProfileModel else { return }
            cell.isFromPersonal = isFromPersonal
            cell.setupData(object, isComplemenatary: true, isPublic: true, isSubAdmin: Preferences.isSubAdmin)
        } else if let cell = cell as? ProfileScoreTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ProfileScoreModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? PromoterSocialCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CompDescriptionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            let logsModel = cellDict?[kCellItemsKey] as? [LogsModel] ?? []
            cell.setupData(object, logs: logsModel)
        } else  if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingListModel  else { return }
            cell.setupPublicRattings(object, user: _complimentaryModel?.profile, isFromComplementry: true)
        } else if let cell = cell as? PublicCMCircleCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
    }
    
}
