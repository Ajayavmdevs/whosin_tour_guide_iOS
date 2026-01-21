import UIKit

class MyTicketCartCell: UITableViewCell {
    
    @IBOutlet weak var _typeBadge: UIView!
    @IBOutlet weak var _ticketTypeText: UILabel!
    @IBOutlet weak var _ticketTitle: UILabel!
    @IBOutlet weak var _ticketDesc: UILabel!
    @IBOutlet weak var _ticketImage: UIImageView!
    @IBOutlet weak var _ticketPrice: CustomLabel!
    @IBOutlet weak var _discount: CustomLabel!
    @IBOutlet weak var _finalPrice: CustomLabel!
    @IBOutlet weak var _discountView: UIStackView!
    @IBOutlet weak var _finalAmountStack: UIStackView!
    @IBOutlet weak var _addonStack: UIStackView!
    @IBOutlet weak var _collecitonView: CustomCollectionView!
    @IBOutlet weak var _addOnPrice: CustomLabel!
    @IBOutlet private weak var _menuBtn: UIButton!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    
    private let kCellIdentifier = String(describing: TicketCartOptionCollectionCell.self)
    private var _ticketBooking: BookingModel?
    private var ticketModel: TicketModel?
    public var callback: (()-> Void)?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._typeBadge.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            self._typeBadge.layer.cornerRadius = 8
            
        }
        _collecitonView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 0,
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: TicketCartOptionCollectionCell.self), kCellClassKey: TicketCartOptionCollectionCell.self, kCellHeightKey: TicketCartOptionCollectionCell.height] ]
    }
    
    private func _loadData(_ model: BookingModel) {
        
        contentView.layoutIfNeeded()
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var totalHeight = 0.0
        var optionModel: Any?
        
        
        model.tourDetails.forEach { data in
            if model.bookingType == "travel-desk" {
                optionModel = ticketModel?.travelOtions.first(where: { "\($0.id)" == data.optionId })
            } else if model.bookingType == "whosin" {
                optionModel = ticketModel?.options.first(where: { $0._id == data.optionId })
            } else if model.bookingType == "whosin-ticket" {
                optionModel = ticketModel?.options.first(where: { $0.optionId == data.optionId })
            } else if model.bookingType == "big-bus" || model.bookingType == "hero-balloon" || model.bookingType == "octo" {
                optionModel = ticketModel?.bigBusTourData.first?.options.first(where: { $0.id == data.optionId })
            } else {
                optionModel = ticketModel?.options.first(where: { $0.optionId == data.optionId })
            }
            guard let ticket = ticketModel else { return }
            let cellHeight = TicketCartOptionCollectionCell.dynamicHeight(option: optionModel, tourDetail: data, bookingType: model.bookingType, ticket: ticket, booking: model, width: _collecitonView.frame.width)
            totalHeight += cellHeight
            
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTitleKey: model.bookingType,
                kCellTagKey:  optionModel as Any,
                kCellObjectDataKey: data,
                kCellClassKey: TicketCartOptionCollectionCell.self,
                kCellHeightKey: cellHeight
            ])
        }
        if !cellData.isEmpty {
            cellSectionData.append([kSectionTitleKey: "", kSectionDataKey: cellData])
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self._collecitonView.loadData(cellSectionData)
            
            var spacing: CGFloat = 0
            if let layout = self._collecitonView.collectionViewLayout as? UICollectionViewFlowLayout {
                spacing = layout.minimumLineSpacing
            }
            let totalSpacing = model.tourDetails.count > 1 ? spacing * CGFloat(model.tourDetails.count - 1) : 0
            self._collectionViewHieghtConstraint.constant = totalHeight + Double(totalSpacing)
            self._collecitonView.isHidden = model.tourDetails.isEmpty
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ model: BookingModel,_ ticket: TicketModel) {
        ticketModel = ticket
        _ticketBooking = model
        _loadData(model)
        _ticketTitle.text = ticket.title
        _ticketDesc.text = Utils.convertHTMLToPlainText(from: ticket.descriptions)
        _ticketImage.loadWebImage(ticket.images.first(where: { !Utils.isVideo($0) }) ?? "")
        let ticketPrice = model.tourDetails.reduce(0.0) { $0 + $1.whosinTotal }
        _ticketPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(ticketPrice).formattedWithoutDecimal())".withCurrencyFont(15)
        _discount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.discount)".withCurrencyFont(15)
        _discountView.isHidden = model.discount == 0
        let addonAmount = model.tourDetails
            .flatMap { $0.Addons }
            .reduce(0.0) { $0 + $1.whosinTotal }
        _addonStack.isHidden = addonAmount == 0
        _addOnPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(addonAmount).formattedWithoutDecimal())".withCurrencyFont(15)
        _finalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(model.amount).formattedWithoutDecimal())".withCurrencyFont(15)
    }
    
    private func _removeItem() {
        guard let id = _ticketBooking?._id else { return }
        parentBaseController?.showHUD(self)
        LOGMANAGER.logTicketEvent(.removeCart, id: id, name: ticketModel?.title ?? "")
        WhosinServices.RemoveFromCart(params: ["id": id]) { [weak self] container, error in
            guard let self = self else { return }
            parentBaseController?.hideHUD(self, error: error)
            guard let container, container.code == 1 else { return }
            NotificationCenter.default.post(Notification(name: Notification.Name("addtoCartCount"), object: nil))
            self.callback?()
        }
    }
    
    @IBAction func _handleMenuOption(_ sender: UIButton) {
        guard let vc = self.parentBaseController else { return}
        showRemoveItemActionSheet(from: vc) {
            self.parentBaseController?.confirmAlert(message: "remove_item_message".localized(), okHandler: { action in
                self._removeItem()
            })
        }
    }
    
    func showRemoveItemActionSheet(from viewController: UIViewController, onRemove: @escaping () -> Void) {
        let actionSheet = UIAlertController(title: nil, message: "choose_option".localized(), preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "remove_item".localized(), style: .destructive) { _ in
            onRemove()
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                  y: viewController.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
}

extension MyTicketCartCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? TicketCartOptionCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? TourOptionDetailModel, let type = cellDict?[kCellTitleKey] as? String, let ticket = ticketModel, let booking = _ticketBooking else { return }
        if let option = cellDict?[kCellTagKey] as? TourOptionsModel {
            cell.setUpdata(option, tourDetail: object, type: type, ticket: ticket, booking: booking)
        } else if let option = cellDict?[kCellTagKey] as? TravelDeskTourModel {
            cell.setUpdata(option, tourDetail: object, ticket: ticket, booking: booking)
        } else if let option = cellDict?[kCellTagKey] as? BigBusOptionsModel {
            cell.setUpdata(option, tourDetail: object, ticket: ticket, booking: booking)
        }
        
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if let cellHeight = cellDict?[kCellHeightKey] as? CGFloat {
            return CGSize(width: width, height: cellHeight)
        }
        return CGSize(width: width, height: TicketCartOptionCollectionCell.height)
    }
    
}
             
