import UIKit

class TicketPurchaseCell: UITableViewCell {

    @IBOutlet weak var _typeBadge: UIView!
    @IBOutlet weak var _ticketTypeText: UILabel!
    @IBOutlet weak var _ticketTitle: UILabel!
    @IBOutlet weak var _ticketDesc: UILabel!
    @IBOutlet weak var _ticketImage: UIImageView!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _duration: UILabel!
    @IBOutlet weak var _dateLabel: UILabel!
    @IBOutlet weak var _transferType: UILabel!
    @IBOutlet weak var _tourOptionsName: UILabel!
    @IBOutlet weak var _tourOptionDesc: UILabel!
    @IBOutlet weak var _ticketPrice: CustomLabel!
    @IBOutlet weak var _paxLabel: CustomLabel!
    @IBOutlet weak var _primaryGuest: CustomLabel!
    @IBOutlet weak var _viewTicketView: UIView!
    @IBOutlet weak var _discount: CustomLabel!
    @IBOutlet weak var _finalPrice: CustomLabel!
    @IBOutlet weak var _discountView: UIStackView!
    @IBOutlet weak var _finalAmountStack: UIStackView!
    @IBOutlet weak var _statusLabel: UILabel!
    @IBOutlet weak var _viewTicketBtn: UIButton!
    @IBOutlet weak var _departureTime: UILabel!
    @IBOutlet weak var _collecitonView: CustomCollectionView!
    @IBOutlet weak var _addonStack: UIStackView!
    @IBOutlet private weak var _menuBtn: UIButton!
    @IBOutlet weak var _addOnPrice: CustomLabel!
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
        _loadData(data.tourDetails.toArrayDetached(ofType: TourDetailsModel.self), type: data.bookingType)
        let titleFont = FontBrand.SFboldFont(size: 12.0)
        let subtitleFont = FontBrand.SFregularFont(size: 12.0)
        _menuBtn.isHidden = !isFromHistory
        if data.bookingType == "whosin-ticket", let model = data.tourDetails.first?.customTicket {
            _ticketTitle.text = model.title
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: model.descriptions)
            _ticketImage.loadWebImage(model.images.first ?? "")
            _tourOptionsName.text = data.tourDetails.first?.customData?.displayName
            _tourOptionDesc.text = data.tourDetails.first?.customData?.optionDescription
            _departureTime.text = data.departureTime
        } else if data.bookingType == "whosin-ticket" {
            _ticketTitle.text = data.tourDetails.first?.customData?.title
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: data.tourDetails.first?.customData?.descriptions ?? kEmptyString)
            let image = Utils.stringIsNullOrEmpty(data.tourDetails.first?.tourOption?.images.first ?? kEmptyString) ? data.tourDetails.first?.customData?.images.first ?? kEmptyString : data.tourDetails.first?.tourOption?.images.first ?? kEmptyString
            _ticketImage.loadWebImage(image)
            _tourOptionsName.text = data.tourDetails.first?.tourOption?.optionName
            _tourOptionDesc.text = data.tourDetails.first?.tourOption?.descriptions
            _departureTime.text = data.departureTime
        } else if data.bookingType == "ticket" {
            _ticketTitle.text = data.tourDetails.first?.tour?.tourName
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: data.tourDetails.first?.tour?.customData?.descriptions ?? kEmptyString)
            _ticketImage.loadWebImage(data.tourDetails.first?.tour?.customData?.images.first ?? kEmptyString)
            _tourOptionsName.text = data.tourDetails.first?.tourOption?.optionName
            _tourOptionDesc.text = data.tourDetails.first?.tourOption?.optionDescription
            _departureTime.text = data.departureTime
        } else if data.bookingType == "travel-desk" {
            _ticketTitle.text = data.tourDetails.first?.customTicket?.title
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: data.tourDetails.first?.customTicket?.descriptions ?? kEmptyString)
            var image = data.tourDetails.first?.optionData?.heroImage.toArray(ofType: String.self)
            if image?.isEmpty == true {
                image = data.tourDetails.first?.customTicket?.images.toArray(ofType: String.self)
            }
            _ticketImage.loadWebImage(image?.first ?? "")
            _tourOptionsName.text = data.tourDetails.first?.customData?.transferName
            _tourOptionDesc.text = Utils.convertHTMLToPlainText(from: data.tourDetails.first?.optionData?.descriptionText ?? kEmptyString)
            _departureTime.text = data.departureTime
        } else if data.bookingType == "big-bus" || data.bookingType == "hero-balloon" || data.bookingType == "octo" {
            _ticketTitle.text = data.tourDetails.first?.customTicket?.title
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: data.tourDetails.first?.customTicket?.descriptions ?? kEmptyString)
            var image = data.tourDetails.first?.optionData?.heroImage.toArray(ofType: String.self)
            if image?.isEmpty == true {
                image = data.tourDetails.first?.customTicket?.images.toArray(ofType: String.self)
            }
            _ticketImage.loadWebImage(image?.first ?? "")
            _tourOptionsName.text = data.tourDetails.first?.customData?.transferName
            _tourOptionDesc.text = Utils.convertHTMLToPlainText(from: data.tourDetails.first?.optionData?.descriptionText ?? kEmptyString)
            _departureTime.text = data.departureTime
        }

        let startTime = Utils.stringToDate(data.tourDetails.first?.startTime, format: "HH:mm:ss") == nil ? Utils.stringToDate(data.tourDetails.first?.startTime, format: "HH:mm") : Utils.stringToDate(data.tourDetails.first?.startTime, format: "HH:mm:ss")
        let time = (Utils.stringIsNullOrEmpty(data.details.first?.slot) || data.details.first?.slot == "00:00:00") ? startTime  : Utils.stringToDate(data.details.first?.slot, format: "HH:mm:ss")
        _timeLabel.text = Utils.dateToString(time, format: "HH:mm")
        let date = Utils.stringToDate(data.tourDetails.first?.tourDate, format: kFormatDate)
        _dateLabel.text = Utils.dateToString(date, format: kFormatEventDate)

        if let slotTime = time {
            _duration.attributedText = Utils.setAtributedTitleText(title: "", subtitle: Utils.dateToString(slotTime, format: "HH:mm"), titleFont: titleFont, subtitleFont: subtitleFont)
        } else {
            _duration.attributedText = Utils.setAtributedTitleText(title: "", subtitle: data.tourDetails.first?.tourOption?.duration ?? kEmptyString, titleFont: titleFont, subtitleFont: subtitleFont)
        }
        _transferType.attributedText = Utils.setAtributedTitleText(title: "tour_type".localized(), subtitle: data.tourDetails.first?.tour?.cityTourType ?? kEmptyString, titleFont: titleFont, subtitleFont: subtitleFont)
        _ticketPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(data.totalAmount)".withCurrencyFont(16)
        
        let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments: ["value1": "\(data.tourDetails.first?.adult ?? 0)","value2": "\(data.tourDetails.first?.child ?? 0)","value3": "\(data.tourDetails.first?.infant ?? 0)" ])
        _paxLabel.attributedText = Utils.setAtributedTitleText(title: "paxes".localized(), subtitle: paxes, titleFont: titleFont, subtitleFont: subtitleFont)
        
        let primaryGuest = data.passengers.first(where: { $0.leadPassenger == 1 })
        let primaryGuestName = "\(primaryGuest?.prefix ?? kEmptyString) \(primaryGuest?.firstName ?? kEmptyString) \(primaryGuest?.lastName ?? kEmptyString)"
        _primaryGuest.attributedText = Utils.setAtributedTitleText(title: "primary_guest".localized(), subtitle: primaryGuestName, titleFont: titleFont, subtitleFont: subtitleFont)
        
        let serviceTotal = Double(data.tourDetails.first?.serviceTotal ?? kEmptyString) ?? 0.0
        let discount = data.tourDetails.first?.tour?.customData?.discount ?? 0
        let discountValue = Utils.calculateDiscountValueDouble(originalPrice: serviceTotal, discountPercentage: discount)

        let formattedDiscountValue = Double(round(100 * discountValue) / 100)
        let formattedFinalAmount = Double(round(100 * serviceTotal) / 100)
        let discountPrice = formattedFinalAmount - formattedDiscountValue
        _ =  Double(round(100 * discountPrice) / 100)
        let ticketPrice = data.tourDetails.reduce(into: 0.0) { result, item in
            result += Double(item.whosinTotal) ?? 0.0
        }
        let hasAddon = data.tourDetails.contains { !$0.addons.isEmpty }
        _addonStack.isHidden = !hasAddon
        let addonTotal = data.tourDetails.reduce(0.0) { tourResult, tour in
            tourResult + tour.addons.reduce(0.0) { addonResult, addon in
                addonResult + (Double(addon.whosinTotal) ?? 0.0)
            }
        }

        _addOnPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(addonTotal).formattedWithoutDecimal())".withCurrencyFont(16)
        
        _ticketPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(ticketPrice).formattedWithoutDecimal())".withCurrencyFont(16)
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


extension TicketPurchaseCell: CustomCollectionViewDelegate {
    
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
