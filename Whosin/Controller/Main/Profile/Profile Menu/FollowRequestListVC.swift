
import UIKit

class FollowRequestListVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: FollowRequestCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _requestPendingFollowRequest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupUi() {
        hideNavigationBar()
        hideLeftBarButton(true)
        //TABLE VIEW
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_following") ,
            emptyDataDescription: "Your follow request list is looking a bit lonely.Time to spice it up",
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.isScrollEnabled = true
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCollectionDefaultMargin, right: 0)
        _visualEffectView.alpha = 0.0
        _loadData()

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _requestPendingFollowRequest() {
        WhosinServices.followRequestList { [weak self]container, error in
            guard let self = self else { return }
            self.showError(error)
            guard let data = container?.data else { return }
            APPSETTING.pendingRequestList = data
            _loadData()
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(_ isLoading: Bool = false) {
        self.hideHUD()
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            APPSETTING.pendingRequestList.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellClassKey: FollowRequestCell.self,
                    kCellHeightKey: FollowRequestCell.height
                ])
            }
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        DISPATCH_ASYNC_MAIN {
            self._tableView.loadData(cellSectionData)
        }
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: FollowRequestCell.self, kCellHeightKey: FollowRequestCell.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
    @IBAction func _handleSelectHomeTabEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// --------------------------------------
// MARK: <CustomTableViewDelegate>
// --------------------------------------

extension FollowRequestListVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
        
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
        if let cell = cell as? FollowRequestCell, let model = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setup(model)
            cell.callback = {
                self._requestPendingFollowRequest()
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        if model.id != userDetail.id {
            if model.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = model.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if model.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = model.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = model.id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

}
