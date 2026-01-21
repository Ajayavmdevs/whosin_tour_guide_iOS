import UIKit
import SwiftUI

class HistoryVC: ChildViewController {
    
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: PurchaseVoucherCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kCellIdentifierActivity = String(describing: MyActivityTableCell.self)
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
        NotificationCenter.default.addObserver(self, selector: #selector(_handleReloadEvent(_:)), name: .reloadHistory, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _requestHistory()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    @objc private func _handleReloadEvent(_ sender: Notification) {
        _vouchersList.removeAll()
        _requestHistory()
    }
    
    private func _requestHistory() {
        WhosinServices.requestHistory { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.hideHUD(error: error)
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
            emptyDataIconImage: UIImage(named: "empty_history"),
            emptyDataDescription: "empty_history".localized(),
            delegate: self)
        _requestHistory()
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: "_vouchersList",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {            
            _vouchersList.forEach { vouchersList in
                if vouchersList.type == "activity" {
                    if vouchersList.items.contains(where: { $0.id == vouchersList.activity?.id }), vouchersList.items.first?.usedQty != 0 {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierActivity,
                            kCellTagKey: vouchersList.id,
                            kCellObjectDataKey: vouchersList,
                            kCellClassKey: MyActivityTableCell.self,
                            kCellHeightKey: MyActivityTableCell.height
                        ])
                    }
                } else if vouchersList.type == "offer" {
                    if let offerPackagesIds = vouchersList.offer?.packages.map({ $0.id }) {
                        if vouchersList.items.contains(where: { offerPackagesIds.contains($0.packageId) }), (vouchersList.items.reduce(0) { $0 + $1.usedQty } != 0) {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifier,
                                kCellTagKey: vouchersList.id,
                                kCellObjectDataKey: vouchersList,
                                kCellClassKey: PurchaseVoucherCell.self,
                                kCellHeightKey: PurchaseVoucherCell.height
                            ])
                        }
                    }
                } else if vouchersList.type == "deal" {
                    if vouchersList.items.contains(where: { $0.id == vouchersList.deal?.id }), (vouchersList.items.reduce(0) { $0 + $1.usedQty } != 0) {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: vouchersList.id,
                            kCellObjectDataKey: vouchersList,
                            kCellClassKey: PurchaseVoucherCell.self,
                            kCellHeightKey: PurchaseVoucherCell.height
                        ])
                    }
                } else if vouchersList.type == "event" {
                    if let offerPackagesIds = vouchersList.event?.packages.map({ $0.id }),(vouchersList.items.reduce(0) { $0 + $1.usedQty } != 0) {
                        if vouchersList.items.contains(where: { offerPackagesIds.contains($0.packageId ) }) {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifier,
                                kCellTagKey: vouchersList.id,
                                kCellObjectDataKey: vouchersList,
                                kCellClassKey: PurchaseVoucherCell.self,
                                kCellHeightKey: PurchaseVoucherCell.height
                            ])
                        }
                    }
                } else if vouchersList.type == "ticket", let ticket = vouchersList.ticket {
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
                } else if vouchersList.type == "big-bus" || vouchersList.type == "hero-balloon" {
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
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: PurchaseVoucherCell.self, kCellHeightKey: PurchaseVoucherCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: MyActivityTableCell.self, kCellHeightKey: MyActivityTableCell.height],
            [kCellIdentifierKey: kCellIdentifierTicket, kCellNibNameKey: kCellIdentifierTicket, kCellClassKey: TicketPurchaseCell.self, kCellHeightKey: TicketPurchaseCell.height],
            [kCellIdentifierKey: kCellIdentifierHotel, kCellNibNameKey: kCellIdentifierHotel, kCellClassKey: HotelTicketPurchaseCell.self, kCellHeightKey: HotelTicketPurchaseCell.height],
        ]
    }
    
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension HistoryVC: CustomTableViewDelegate {
    func refreshData() {
        _requestHistory()
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PurchaseVoucherCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VouchersListModel  else { return }
            cell.setupData(object, isFrom: "history")
        } else if let cell = cell as? MyActivityTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VouchersListModel  else { return }
            cell.setupData(object, true)
        } else if let cell = cell as? TicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel, let voucher = cellDict?[kCellTagKey] as? VouchersListModel else { return }
            cell.setupData(object, voucher: voucher, isFromHistory: true)
        }  else if let cell = cell as? HotelTicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel,let voucherModel = cellDict?[kCellTagKey] as? VouchersListModel else { return }
            cell.setupData(object, voucher: voucherModel)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }

    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PurchaseVoucherCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VouchersListModel  else { return }
            if object.type == "offer" {
                let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
                controller.offerId = object.offer?.id ?? kEmptyString
                controller.venueModel = object.offer?.venue
                controller.timingModel = object.offer?.venue?.timing.toArrayDetached(ofType: TimingModel.self)
                controller.modalPresentationStyle = .overFullScreen
                controller.vanueOpenCallBack = { venueId, venueModel in
                    let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                    vc.venueId = venueId
                    vc.venueDetailModel = venueModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                controller.buyNowOpenCallBack = { offer, venue, timing in
                    let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                    vc.isFromActivity = false
                    vc.type = "offers"
                    vc.timingModel = timing
                    vc.offerModel = offer
                    vc.venue = venue
                    vc.setCallback {
                        let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                        controller.modalPresentationStyle = .overFullScreen
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                navigationController?.presentAsPanModal(controller: controller)
            } else if object.type == "event" {
                let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
                controller.eventId = object.event?.id ?? kEmptyString
                navigationController?.pushViewController(controller, animated: true)
            } else if object.type == "deal" {
                let controller = INIT_CONTROLLER_XIB(DealsDetailVC.self)
                controller.dealsModel = object.deal
                navigationController?.pushViewController(controller, animated: true)
            }
        } else if let cell = cell as? MyActivityTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VouchersListModel  else { return }
            let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            controller.activityId = object.activity?.id ?? kEmptyString
            controller.activityName = object.activity?.name ?? kEmptyString
            controller.activityModel = object.activity
            navigationController?.pushViewController(controller, animated: true)
        } else if cell is TicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel, let voucher = cellDict?[kCellTagKey] as? VouchersListModel else { return }
                        let controller = INIT_CONTROLLER_XIB(TicketWalletDetailVC.self)
            controller.bookingModel = object
            controller.voucherModel = voucher
            controller.isHistory = true
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } else if cell is HotelTicketPurchaseCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketBookingModel, let voucher = cellDict?[kCellTagKey] as? VouchersListModel else { return }
                        let controller = INIT_CONTROLLER_XIB(TicketWalletDetailVC.self)
            controller.bookingModel = object
            controller.voucherModel = voucher
            controller.isHistory = true
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
