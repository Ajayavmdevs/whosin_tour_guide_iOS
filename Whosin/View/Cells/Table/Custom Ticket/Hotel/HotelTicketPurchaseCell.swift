import UIKit

class HotelTicketPurchaseCell: UITableViewCell {

    @IBOutlet weak var _checkOutTime: CustomLabel!
    @IBOutlet weak var _checkInStack: UIStackView!
    @IBOutlet weak var _checkInTime: CustomLabel!
    @IBOutlet weak var _endDatePax: CustomLabel!
    @IBOutlet weak var _startDateText: CustomLabel!
    @IBOutlet weak var _totalPaxInfo: CustomLabel!
    @IBOutlet weak var _typeBadge: UIView!
    @IBOutlet weak var _ticketTypeText: UILabel!
    @IBOutlet weak var _ticketTitle: UILabel!
    @IBOutlet weak var _ticketDesc: UILabel!
    @IBOutlet weak var _ticketImage: UIImageView!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _duration: UILabel!
    @IBOutlet weak var _dateLabel: UILabel!
    @IBOutlet weak var _transferType: UILabel!
    @IBOutlet weak var _ticketPrice: CustomLabel!
    @IBOutlet weak var _viewTicketView: UIView!
    @IBOutlet weak var _discount: CustomLabel!
    @IBOutlet weak var _finalPrice: CustomLabel!
    @IBOutlet weak var _discountView: UIStackView!
    @IBOutlet weak var _finalAmountStack: UIStackView!
    @IBOutlet weak var _statusLabel: UILabel!
    @IBOutlet weak var _viewTicketBtn: UIButton!
    @IBOutlet weak var _departureTime: UILabel!
    @IBOutlet weak var _collecitonView: CustomCollectionView!
    @IBOutlet private weak var _menuBtn: UIButton!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!

    private let kCellIdentifier = String(describing: TicketWalletOptionCollectionCell.self)
    private var _ticketBooking: TicketBookingModel?
    private var _voucherModel: VouchersListModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
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
                              rows: 5,
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collecitonView.showsVerticalScrollIndicator = false
        _collecitonView.showsHorizontalScrollIndicator = false
        _collecitonView.isUserInteractionEnabled = false

    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: TicketWalletOptionCollectionCell.self), kCellClassKey: TicketWalletOptionCollectionCell.self, kCellHeightKey: TicketWalletOptionCollectionCell.height] ]
    }
    
    private func _loadData(_ model: [TourDetailsModel], type: String) {
        contentView.layoutIfNeeded()
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var totalHeight: CGFloat = 0
        
        model.forEach { item in
            let cellHeight = TicketWalletOptionCollectionCell.height(for: item, type: type, width: _collecitonView.frame.width)
            totalHeight += cellHeight
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: type,
                kCellObjectDataKey: item.detached(),
                kCellClassKey: TicketWalletOptionCollectionCell.self,
                kCellHeightKey: cellHeight
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collecitonView.loadData(cellSectionData)
        
        var spacing: CGFloat = 0
        if let layout = _collecitonView.collectionViewLayout as? UICollectionViewFlowLayout {
            spacing = layout.minimumLineSpacing
        }
        let totalSpacing = model.count > 1 ? spacing * CGFloat(model.count - 1) : 0
        _collectionViewHieghtConstraint.constant = totalHeight + totalSpacing
        _collecitonView.isHidden = model.isEmpty
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: TicketBookingModel, voucher: VouchersListModel, isFromHistory: Bool = false) {
        _ticketTypeText.text = voucher.type.capitalizedSentence
        _typeBadge.isHidden = true
        _ticketBooking = data
        _voucherModel = voucher
        let titleFont = FontBrand.SFboldFont(size: 12.0)
        let subtitleFont = FontBrand.SFregularFont(size: 12.0)
        _menuBtn.isHidden = !isFromHistory
        
        if data.bookingType == "juniper-hotel", let model = data.tourDetails.first {
            _ticketTitle.text = model.customTicket?.title
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: model.customTicket?.descriptions ?? "")
            _ticketImage.loadWebImage(model.tourData?.images.first?.image ?? "")
            _departureTime.text = data.departureTime
            _checkInTime.text = model.tourData?.checkIn
            _checkOutTime.text = model.tourData?.checkOut
            _startDateText.text = model.startDate
            _endDatePax.text = model.endDate
            _checkInStack.isHidden = Utils.stringIsNullOrEmpty(model.tourData?.checkIn)
            
        }
        
        _ticketPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(data.totalAmount)".withCurrencyFont(16)
        
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPaxHotel", arguments: ["value1": "\(data.tourDetails.first?.adult ?? 0)","value2": "\(data.tourDetails.first?.child ?? 0)"])
        _totalPaxInfo.attributedText = Utils.setAtributedTitleText(title: "", subtitle: paxes, titleFont: titleFont, subtitleFont: subtitleFont)
                
        let serviceTotal = Double(data.tourDetails.first?.serviceTotal ?? kEmptyString) ?? 0.0
        let discount = data.tourDetails.first?.tour?.customData?.discount ?? 0
        let discountValue = Utils.calculateDiscountValueDouble(originalPrice: serviceTotal, discountPercentage: discount)

        let formattedDiscountValue = Double(round(100 * discountValue) / 100)
        let formattedFinalAmount = Double(round(100 * serviceTotal) / 100)
        let discountPrice = formattedFinalAmount - formattedDiscountValue
        _ =  Double(round(100 * discountPrice) / 100)
        
        _ticketPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(data.totalAmount).formattedWithoutDecimal())".withCurrencyFont(16)
        _discount.attributedText = "\(Utils.getCurrentCurrencySymbol())\(data.discount.formattedDecimal())".withCurrencyFont(16)
        _finalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(data.amount).formattedWithoutDecimal())".withCurrencyFont(16)
        _discountView.isHidden = data.discount == 0
        _finalAmountStack.isHidden = data.amount == 0
        
        let paymentStatus = Utils.stringIsNullOrEmpty(data.paymentStatus) ? kEmptyString : " (\(data.paymentStatus))"
        
        _statusLabel.attributedText = Utils.createAttributedStringWithColors(firstText: data.bookingStatus, firstTextColor: ColorBrand.brandPink, secondText: paymentStatus, secondTextColor: ColorBrand.amberColor)
        _statusLabel.isHidden = !isFromHistory
        _viewTicketView.isHidden = isFromHistory
        
        if data.bookingStatus == "initiated" {
            _viewTicketView.backgroundColor = ColorBrand.brandPink
            _viewTicketBtn.setTitleColor(ColorBrand.white, for: .normal)
            _viewTicketBtn.setTitle("check_booking_status".localized(), for: .normal)
            _statusLabel.text = data.bookingStatus
            _statusLabel.isHidden = false
        } else if data.paymentStatus == "paid" && (data.bookingStatus == "rejected" || data.bookingStatus == "failed") {
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(voucher._createdAt)

            let totalDuration: TimeInterval = 15 * 60 // 15 minutes
            let remainingTime = max(0, totalDuration - elapsedTime)
            if remainingTime == 0 {
                _statusLabel.isHidden = false
                _viewTicketView.isHidden = true
            } else {
                _viewTicketView.backgroundColor = ColorBrand.brandPink
                _viewTicketBtn.setTitleColor(ColorBrand.white, for: .normal)
                _viewTicketBtn.setTitle("check_booking_status".localized(), for: .normal)
                _statusLabel.text = "pending".localized()
                _statusLabel.isHidden = false
            }
        } else if data.paymentStatus == "paid" && data.bookingStatus == "confirmed" {
            _viewTicketView.backgroundColor = ColorBrand.brandPink
            _viewTicketBtn.setTitleColor(ColorBrand.white, for: .normal)
            _viewTicketBtn.setTitle("view_ticket".localized(), for: .normal)
            _statusLabel.isHidden = true
        } else if data.paymentStatus == "paid" && data.bookingStatus == "completed" {
            _statusLabel.attributedText = Utils.createAttributedStringWithColors(firstText: data.bookingStatus, firstTextColor: ColorBrand.brandPink, secondText: "", secondTextColor: ColorBrand.amberColor)
            _statusLabel.isHidden = false
            _viewTicketView.isHidden = true
        } else if data.bookingStatus == "failed" {
            _viewTicketBtn.setTitleColor(ColorBrand.buyNowColor, for: .normal)
            _viewTicketBtn.setTitle("booking_failed".localized(), for: .normal)
            _viewTicketView.backgroundColor = .clear
            _statusLabel.isHidden = true
            _viewTicketView.isHidden = false
        } else if data.bookingStatus == "cancelled" {
            _statusLabel.isHidden = false
            _viewTicketView.isHidden = true
        }
    }
    
    private func _requestDeletehistory( ids: [String]) {
            self.parentBaseController?.showHUD()
            WhosinServices.deleteOrder(ids: ids) { [weak self] container, error in
                guard let self = self else { return }
                self.parentBaseController?.hideHUD(error: error)
                guard let data = container else { return}
                self.parentBaseController?.showToast(data.message)
                NotificationCenter.default.post(name: .reloadHistory, object: nil)
            }
            
        }
    
    @IBAction func _handleViewTicket(_ sender: UIButton) {
        if (_ticketBooking?.bookingStatus == "confirmed" || _ticketBooking?.bookingStatus == "initiated") {
            let controller = INIT_CONTROLLER_XIB(TicketWalletDetailVC.self)
            controller.bookingModel = _ticketBooking
            controller.voucherModel = _voucherModel
            controller.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
        } else if _ticketBooking?.paymentStatus == "paid" && (_ticketBooking?.bookingStatus == "rejected" || _ticketBooking?.bookingStatus == "failed") {
            let controller = INIT_CONTROLLER_XIB(TicketWalletDetailVC.self)
            controller.bookingModel = _ticketBooking
            controller.voucherModel = _voucherModel
            controller.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }

    
    @IBAction private func handleMenuEvent( sender: UIButton) {
        guard let id = _voucherModel?.orderId else { return }
            let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { action in
                self.parentBaseController?.confirmAlert(message: "delete_order_history_confirm".localized(),okHandler: { okAction in
                    self._requestDeletehistory(ids: [id])
                }, noHandler:  { action in
                })
            }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
            parentViewController?.present(alert, animated: true, completion:{
                alert.view.superview?.subviews[0].isUserInteractionEnabled = true
                alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })

        }
}


extension HotelTicketPurchaseCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? TicketWalletOptionCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? TourDetailsModel, let type = cellDict?[kCellTagKey] as? String else { return }
        cell.setUpdata(object, type: type)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if let object = cellDict?[kCellObjectDataKey] as? TourDetailsModel,
           let type = cellDict?[kCellTagKey] as? String {
            let cellHeight = TicketWalletOptionCollectionCell.height(for: object, type: type, width: width)
            return CGSize(width: width, height: cellHeight)
        }
        return CGSize(width: width, height: TicketWalletOptionCollectionCell.baseHeight)
    }
    
}
