import UIKit

class MyItemsVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kCellIdentifierTicket = String(describing: TicketPurchaseCell.self)
    private let kCellIdentifierHotel = String(describing: HotelTicketPurchaseCell.self)
    private var _vouchersList: [VouchersListModel] = []

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        _loadData(isLoading: true)
        _requestVoucherList()
        NotificationCenter.default.addObserver(self, selector: #selector(_handleReloadEvent(_:)), name: Notification.Name("reloadMyWallet"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _requestVoucherList()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestVoucherList() {
        WhosinServices.getPurchaseOrderList { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.showError(error)
            if error != nil {
                self._loadData(isLoading: false)
            }
            guard let data = container?.data else { return }
            self._vouchersList = data.sorted { voucher1, voucher2 in
                return voucher1._createdAt > voucher2._createdAt
            }
            self._loadData(isLoading: false)
        }
    }

    // --------------------------------------
    // MARK: private
    // --------------------------------------
    
    @objc private func _handleReloadEvent(_ sender: Notification) {
        _requestVoucherList()
    }
    
    private func _setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_items"),
            emptyDataDescription: "wallet_empty_message".localized(),
            delegate: self)
        _requestVoucherList()
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: _vouchersList,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            _vouchersList.forEach { vouchersList in
                if vouchersList.type == "ticket", let ticket = vouchersList.ticket {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellTagKey: vouchersList,
                        kCellObjectDataKey: ticket,
                        kCellClassKey: TicketPurchaseCell.self,
                        kCellHeightKey: TicketPurchaseCell.height
                    ])
                } else if vouchersList.type == "whosin-ticket", let ticket = vouchersList.whosinTicket {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellTagKey: vouchersList,
                        kCellObjectDataKey: ticket,
                        kCellClassKey: TicketPurchaseCell.self,
                        kCellHeightKey: TicketPurchaseCell.height
                    ])
                } else if vouchersList.type == "travel-desk", let ticket = vouchersList.traveldeskTicket {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellTagKey: vouchersList,
                        kCellObjectDataKey: ticket,
                        kCellClassKey: TicketPurchaseCell.self,
                        kCellHeightKey: TicketPurchaseCell.height
                    ])
                } else if vouchersList.type == "big-bus" || vouchersList.type == "hero-balloon" || vouchersList.type == "octo" {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellTagKey: vouchersList,
                        kCellObjectDataKey: vouchersList.octoTicket,
                        kCellClassKey: TicketPurchaseCell.self,
                        kCellHeightKey: TicketPurchaseCell.height
                    ])
                } else if vouchersList.type == "juniper-hotel" {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierHotel,
                        kCellTagKey: vouchersList,
                        kCellObjectDataKey: vouchersList.juniperHotel,
                        kCellClassKey: HotelTicketPurchaseCell.self,
                        kCellHeightKey: HotelTicketPurchaseCell.height
                    ])
                }
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierTicket, kCellNibNameKey: kCellIdentifierTicket, kCellClassKey: TicketPurchaseCell.self, kCellHeightKey: TicketPurchaseCell.height],
            [kCellIdentifierKey: kCellIdentifierHotel, kCellNibNameKey: kCellIdentifierHotel, kCellClassKey: HotelTicketPurchaseCell.self, kCellHeightKey: HotelTicketPurchaseCell.height],
        ]
    }

}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension MyItemsVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? TicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel,let voucherModel = cellDict?[kCellTagKey] as? VouchersListModel else { return }
            cell.setupData(object, voucher: voucherModel)
        } else if let cell = cell as? HotelTicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel,let voucherModel = cellDict?[kCellTagKey] as? VouchersListModel else { return }
            cell.setupData(object, voucher: voucherModel)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is TicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel, let voucherModel = cellDict?[kCellTagKey] as? VouchersListModel  else { return }
            let controller = INIT_CONTROLLER_XIB(TicketWalletDetailVC.self)
            controller.bookingModel = object
            controller.voucherModel = voucherModel
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } else if cell is HotelTicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel, let voucherModel = cellDict?[kCellTagKey] as? VouchersListModel  else { return }
            let controller = INIT_CONTROLLER_XIB(TicketWalletDetailVC.self)
            controller.bookingModel = object
            controller.voucherModel = voucherModel
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func refreshData() {
        _tableView.startRefreshing()
        _requestVoucherList()
    }
}
