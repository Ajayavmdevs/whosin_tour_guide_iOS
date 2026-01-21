import UIKit
import MHLoadingButton
import SwiftUI

class BucketListBottomSheet: PanBaseViewController {
    
    @IBOutlet private weak var _slideActionButton: SlideToActionButton!
    @IBOutlet private weak var _tableView: CustomTableView!
    private var _bucketList: [BucketDetailModel] = []
    private let kCellIdentifierVenueDetail = String(describing: BucketListTableCell.self)
    private let kLoadingCellIdenntifire = String(describing: LoadingCell.self)
    public var offerId:String = kEmptyString
    public var eventId:String = kEmptyString
    public var activityId:String = kEmptyString
    public var _bucketId: String = kEmptyString
    public var isFromMoveToAnother: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        self._loadData(true)
        self._requestBucketList()
    }
    
    // --------------------------------------
    // MARK: Service Method
    // --------------------------------------
    
    private func _requestBucketList() {
        let chatRepo = ChatRepository()
        chatRepo.getGroupChatLit { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.showError(error)
            guard let data = container else { return }
            self._bucketList = data.bucketList.toArrayDetached(ofType: BucketDetailModel.self)
            self._loadData(false)
        }
    }
    
    private func _requestAddToBucket(bucketId: String, offerId: String = kEmptyString, eventId: String = kEmptyString, activityId: String = kEmptyString, _ shouldRefresh: Bool = true) {
        var params: [String: Any] = [:]
        params["id"] = bucketId
        params["action"] = "add"
        if !Utils.stringIsNullOrEmpty(eventId) {
            params["eventId"] = eventId
        } else if !Utils.stringIsNullOrEmpty(offerId) {
            params["offerId"] = offerId
        }else if !Utils.stringIsNullOrEmpty(activityId) {
            params["activityId"] = activityId
        }
        if shouldRefresh { showHUD() }
        WhosinServices.addRemoveBucketList(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            if let container = container {
                self.view.makeToast(container.message)
                if self.isFromMoveToAnother {
                    self._requestRemoveItem(offerId: self.offerId,eventId: self.eventId, activityId: self.activityId)
                } else {
                    DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                        self.dismiss(animated: true) {
                            self.hideHUD()
                        }
                    }
                }
            }
        }
    }
    
    private func _requestRemoveItem(offerId: String,eventId: String, activityId: String ) {
        var params: [String: Any] = [:]
        params["id"] = _bucketId
        params["action"] = "delete"
        if !Utils.stringIsNullOrEmpty(offerId) {
            params["offerId"] = offerId
        } else if !Utils.stringIsNullOrEmpty(eventId) {
            params["eventId"] = eventId
        } else if !Utils.stringIsNullOrEmpty(activityId) {
            params["activityId"] = activityId
        }
        WhosinServices.addRemoveBucketList(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    public func _setupUi() {
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    override func setupUi() {
        _slideActionButton.delegate = self
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_bucketList"),
            emptyDataDescription: "Bucket list looking a bit empty? Toss in some vouchers and kickstart those adventures",
            delegate: self)
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 80, right: 0)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadList(_:)), name: kReloadBucketList, object: nil)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: BucketListTableCell.self, kCellHeightKey: BucketListTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdenntifire, kCellNibNameKey: kLoadingCellIdenntifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdenntifire,
                kCellTagKey: kLoadingCellIdenntifire,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if !_bucketList.isEmpty {
                _bucketList.forEach { bucketlistModel in
                    if bucketlistModel.id != _bucketId {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierVenueDetail,
                            kCellTagKey: kCellIdentifierVenueDetail,
                            kCellObjectDataKey: bucketlistModel,
                            kCellClassKey: BucketListTableCell.self,
                            kCellHeightKey: BucketListTableCell.height
                        ])
                    }
                }
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    @objc func handleReloadList(_ notification: Notification) {
        guard let bucketId = notification.object as? String else {
            _requestBucketList()
            return
        }
        _requestAddToBucket(bucketId: bucketId, offerId: offerId, eventId: eventId, activityId: activityId, false)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            self.hideHUD()
        }
    }
}


// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension BucketListBottomSheet: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? BucketListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            cell.setupData(object,userModel: APPSETTING.users ?? [], isFromSheet: true)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? BucketListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            _requestAddToBucket(bucketId: object.id, offerId: offerId, eventId: eventId, activityId: activityId)
            cell.selectedBackgroundView?.backgroundColor = .lightGray
        }
    }
    
}

extension BucketListBottomSheet: SlideToActionButtonDelegate {
    func didFinish() {
        let presentedViewController = INIT_CONTROLLER_XIB(CreateBucketBottomSheet.self)
        presentAsPanModal(controller: presentedViewController)
        _slideActionButton.reset()
    }
}

extension BucketListBottomSheet: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
