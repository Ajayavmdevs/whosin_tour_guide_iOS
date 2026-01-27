import UIKit
import StripeCore
import IQKeyboardManagerSwift

class HotelBookingPreviewVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _promoCodeTextField: UITextField!
    @IBOutlet private weak var _applyPromoBtn: CustomActivityButton!
    @IBOutlet private weak var _savingsView: UIView!
    @IBOutlet private weak var _savingPriceLabel: UILabel!
    @IBOutlet private weak var _promoView: UIView!
    @IBOutlet private weak var _invalidText: UILabel!
    @IBOutlet private weak var _invalidView: UIView!
    @IBOutlet private weak var _verificationIcon: CustomActivityButton!
    @IBOutlet private weak var promoCodeStack: UIStackView!
    @IBOutlet private weak var _appliedPromoView: UIView!
    @IBOutlet private weak var _appliedPromoTitle: CustomLabel!
    @IBOutlet private weak var _priceBreakDownView: UIView!
    @IBOutlet private weak var _promoCodeDiscountedView: UIStackView!
    @IBOutlet private weak var _offerDiscountedSavingView: UIStackView!
    @IBOutlet private weak var _offerDiscountSavingText: UILabel!
    @IBOutlet private weak var _promoDiscountLabel: CustomLabel!
    @IBOutlet weak var _btnStackView: UIStackView!
    
    private var kCellHeaderIdentifier = String(describing: CheckOutTicketDetailHeaderCell.self)
    private var kCellInfoIdentifier = String(describing: HotelBookingDateCell.self)
    private var kCellDescIdentifier = String(describing: HotelGuestDetailCell.self)
    private var kCellRoomIdentifier = String(describing: RoomsPreviewCell.self)
    private var kCellIdentifierTotal = String(describing: OptionsAmountTableCell.self)
    private var kCellPolicyIdentifier = String(describing: CancellationPolicyTableCell.self)
    private var kCellIdentifierDesc = String(describing: CancellationDescTableCell.self)

    
    private var _promoCode: String = kEmptyString
    private var _raynaTourPolicyModel: [TourPolicyModel] = []
    private var promoBaseModel: PromoBaseModel? = nil

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkSession()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
        NotificationCenter.default.addObserver(self, selector: #selector(closeSuccess), name: Notification.Name("dissmissVC"), object: nil)
    }


    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        let tapPriceGesture = UITapGestureRecognizer(target: self, action: #selector(hideShowPriceBreakdown))
        _savingsView.isUserInteractionEnabled = true
        _savingsView.addGestureRecognizer(tapPriceGesture)
        _promoCodeTextField.delegate = self
        
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "preview_empty".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
        
    }
    
    // --------------------------------------
    // MARK: Servies
    // --------------------------------------
    
    private func applyPromoCode(_ metaData: [[String: Any]]) {
        guard let promo = _promoCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !promo.isEmpty else {
            hideHUD()
            return
        }
        self.showHUD()
        _applyPromoBtn.showActivity()
        WhosinServices.applyPromoCode(promoCode: promo, metadata: metaData) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            self._applyPromoBtn.hideActivity()
            guard let data = container?.data, error == nil else {
                self._applyPromoBtn.hideActivity()
                self._applyPromoBtn.isHidden = true
                self._verificationIcon.isHidden = false
                self._invalidView.isHidden = false
                self._invalidText.text = error?.localizedDescription
                self._promoView.borderColor = ColorBrand.buyNowColor
                self._promoView.backgroundColor = ColorBrand.buyNowColor.withAlphaComponent(0.1)
                self._verificationIcon.setImage(UIImage(named: "icon_invalidCode"), for: .normal)
                return
            }
            self.promoBaseModel = data
            self._promoView.isHidden = true
            self._appliedPromoView.isHidden = false
            self._invalidView.isHidden = true
            self._applyPromoBtn.hideActivity()
            
            let totalDiscount = promoBaseModel?.totalDiscount ?? 0
            let itemsDiscount = promoBaseModel?.itemsDiscount ?? 0
            let promoDiscount = promoBaseModel?.promoDiscount ?? 0
            
            self._savingPriceLabel.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", totalDiscount).withCurrencyFont(14)
            self._appliedPromoTitle.attributedText = Utils.makePromoTitleText(discount: promoDiscount, promoCode: promo, defaultFont: FontBrand.SFregularFont(size: 14), dirhamFont: FontBrand.dirhamText(size: 14))
            self._offerDiscountSavingText.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", itemsDiscount).withCurrencyFont(14)
            self._promoDiscountLabel.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", promoDiscount).withCurrencyFont(14)
            self._promoCodeDiscountedView.isHidden = false
            
            self._savingsView.isHidden = (promoDiscount == 0 && itemsDiscount == 0 && itemsDiscount == 0 && promoDiscount == 0)
            _loadData()
        }
        
    }
    
    func makePromoTitleText(discount: Double, promoCode: String, defaultFont: UIFont, dirhamFont: UIFont) -> NSAttributedString {
        let formattedText = String(format: "\(Utils.getCurrentCurrencySymbol())%.2f \("saved_with".localized()) %@", discount, promoCode)
        let attributed = NSMutableAttributedString(string: formattedText, attributes: [.font: defaultFont])
        
        if let dRange = formattedText.range(of: "D"), APPSESSION.userDetail?.currency == "AED" {
            let nsRange = NSRange(dRange, in: formattedText)
            attributed.addAttribute(.font, value: dirhamFont, range: nsRange)
        }
        
        return attributed
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellHeaderIdentifier, kCellNibNameKey: String(describing: CheckOutTicketDetailHeaderCell.self), kCellClassKey: CheckOutTicketDetailHeaderCell.self, kCellHeightKey: CustomTicketDetailHeaderCell.height],
                 [kCellIdentifierKey: kCellInfoIdentifier, kCellNibNameKey: String(describing: HotelBookingDateCell.self), kCellClassKey: HotelBookingDateCell.self, kCellHeightKey: HotelBookingDateCell.height],
                 [kCellIdentifierKey: kCellDescIdentifier, kCellNibNameKey: String(describing: HotelGuestDetailCell.self), kCellClassKey: HotelGuestDetailCell.self, kCellHeightKey: HotelGuestDetailCell.height],
                 [kCellIdentifierKey: kCellIdentifierTotal, kCellNibNameKey: String(describing: OptionsAmountTableCell.self), kCellClassKey: OptionsAmountTableCell.self, kCellHeightKey: OptionsAmountTableCell.height],
                 [kCellIdentifierKey: kCellRoomIdentifier, kCellNibNameKey: String(describing: RoomsPreviewCell.self), kCellClassKey: RoomsPreviewCell.self, kCellHeightKey: RoomsPreviewCell.height],
                 [kCellIdentifierKey: kCellPolicyIdentifier, kCellNibNameKey: String(describing: CancellationPolicyTableCell.self), kCellClassKey: CancellationPolicyTableCell.self, kCellHeightKey: CancellationPolicyTableCell.height],
                 [kCellIdentifierKey: kCellIdentifierDesc, kCellNibNameKey: String(describing: CancellationDescTableCell.self), kCellClassKey: CancellationDescTableCell.self, kCellHeightKey: CancellationDescTableCell.height],
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellHeaderIdentifier,
            kCellTagKey: kCellHeaderIdentifier,
            kCellObjectDataKey: BOOKINGMANAGER.ticketModel,
            kCellClassKey: CheckOutTicketDetailHeaderCell.self,
            kCellHeightKey: CheckOutTicketDetailHeaderCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellDescIdentifier,
            kCellTagKey: kCellDescIdentifier,
            kCellObjectDataKey: HOTELBOOKINGMANAGER.bookingModel.passengers.toArrayDetached(ofType: JPPassengerModel.self),
            kCellClassKey: HotelGuestDetailCell.self,
            kCellHeightKey: HotelGuestDetailCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellInfoIdentifier,
            kCellTagKey: HOTELBOOKINGMANAGER.availibilityModel?.hotelInfo,
            kCellObjectDataKey: HOTELBOOKINGMANAGER.bookingRuls?.hotelBookingRequiredFields,
            kCellClassKey: HotelBookingDateCell.self,
            kCellHeightKey: HotelBookingDateCell.height
        ])
        
        HOTELBOOKINGMANAGER.bookingRuls?.priceInformation.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellRoomIdentifier,
                kCellTagKey: kCellRoomIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: RoomsPreviewCell.self,
                kCellHeightKey: RoomsPreviewCell.height
            ])

        })
        
        if HOTELBOOKINGMANAGER.bookingRuls?.cancellationPolicy?.PolicyRules.isEmpty == false {
            cellData.append([
                kCellIdentifierKey: kCellPolicyIdentifier,
                kCellTagKey: kCellPolicyIdentifier,
                kCellObjectDataKey: true,
                kCellClassKey: CancellationPolicyTableCell.self,
                kCellHeightKey: CancellationPolicyTableCell.height
            ])
            
            HOTELBOOKINGMANAGER.bookingRuls?.cancellationPolicy?.PolicyRules.forEach { policies in
                cellData.append([
                    kCellIdentifierKey: kCellPolicyIdentifier,
                    kCellTagKey: kCellPolicyIdentifier,
                    kCellObjectDataKey: policies,
                    kCellClassKey: CancellationPolicyTableCell.self,
                    kCellHeightKey: CancellationPolicyTableCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()
        
        if !(HOTELBOOKINGMANAGER.bookingModel.tourDetails.isEmpty) {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierTotal,
                kCellTagKey: kCellIdentifierTotal,
                kCellObjectDataKey: HOTELBOOKINGMANAGER.selectedHotelOption?.price,
                kCellClassKey: OptionsAmountTableCell.self,
                kCellHeightKey: OptionsAmountTableCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func _promocodeMetaData() {
        guard let promoCode = _promoCodeTextField.text, !promoCode.isEmpty else {
            alert(message: "enter_promo_code".localized())
            return
        }
        
        var metaData = [[String: Any]]()
        _offerDiscountedSavingView.isHidden = true
        let priceCalculation = HOTELBOOKINGMANAGER.calculateTourTotals(promo: promoBaseModel)
        let item: [String: Any] = ["amount": priceCalculation.totalAmount, "ticketId": BOOKINGMANAGER.ticketModel?._id ?? "", "type": "juniper-hotel", "discount": 0, "qty": 1]
        metaData.append(item)
        
        _applyPromoBtn.setTitle("", for: .normal)
        _applyPromoBtn.showActivity()
        applyPromoCode(metaData)
    }
    
    private func _removePromoCode() {
        _applyPromoBtn.isHidden = false
        _verificationIcon.isHidden = true
        _invalidView.isHidden = true
        self._btnStackView.isHidden = self._applyPromoBtn.isHidden == true && self._verificationIcon.isHidden == false
        _promoView.borderColor = UIColor(hexString: "D9D9D9").withAlphaComponent(0.2)
        _promoView.backgroundColor = .clear
        _appliedPromoView.isHidden = true
        _promoCodeTextField.text = kEmptyString
        _promoView.isHidden = false
        _savingsView.isHidden = true
        _offerDiscountedSavingView.isHidden = true
        _promoCodeDiscountedView.isHidden = true
        _priceBreakDownView.isHidden = true
        _promoCodeDiscountedView.isHidden = true
        promoBaseModel = nil
        _loadData()
    }
    
    private func _addToCart(_ params: [String: Any]) {
        showHUD()
        WhosinServices.AddToCart(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            BOOKINGMANAGER.clearManager()
            NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
            self.showSuccessMessage("added_to_cart".localized(), subtitle: "item_added_successfully".localized())
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func hideShowPriceBreakdown() {
        _priceBreakDownView.isHidden.toggle()
        _promoCodeDiscountedView.isHidden = promoBaseModel == nil
    }
    
    @IBAction private func _handleApplyPromoEvent(_ sender: CustomActivityButton) {
        _promocodeMetaData()
    }
    
    @IBAction private func _handleRemovePromoEvent(_ sender: CustomActivityButton) {
        _removePromoCode()
    }
    
    @IBAction private func _closeEvent(_ sender: Any) {
        dismissOrBack()
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
    @IBAction private func _handleClearPromoEvent(_ sender: CustomActivityButton) {
        _removePromoCode()
    }
    
    @IBAction private func _handleCheckOutEvent(_ sender: UIButton) {
        if Preferences.isGuest {
            alert(message: "guest_login_alert".localized(), okActionTitle: "continue".localized(), cancelActionTitle: "login".localized(),okHandler: { alert in
                self._checkoutEvent()
            }) { alert in
                let vc = INIT_CONTROLLER_XIB(LoginVC.self)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            _checkoutEvent()
        }
    }
    
    private func _checkoutEvent() {
        let priceCalculation = HOTELBOOKINGMANAGER.calculateTourTotals(promo: promoBaseModel)

        HOTELBOOKINGMANAGER.bookingModel.currency = "aed"
        HOTELBOOKINGMANAGER.bookingModel.totalAmount = priceCalculation.priceWithPromo
        HOTELBOOKINGMANAGER.bookingModel.amount = priceCalculation.priceWithPromo
        BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
        let promoCode = _promoCodeTextField.text ?? ""
        HOTELBOOKINGMANAGER.bookingModel.promoCode = promoCode
        var jsonDict = HOTELBOOKINGMANAGER.bookingModel.toJSON()
        if let promoBaseModel = promoBaseModel {
            jsonDict["promoCodeData"] = promoBaseModel.metadata.toArrayDetached(ofType: PromoCodeApplyModel.self).toJSON()
        }
        if !jsonDict.isEmpty {
            print("Ticket booking params===========",jsonDict.toJSONString)
            PAYMENTMANAGER.showPaymentOptions(in: self, params: jsonDict,isTabbyDisable: HOTELBOOKINGMANAGER.bookingModel.amount < 10, purchaseType: .raynaTour) { result in
                switch result {
                case .success:
                    self.hideHUD()
                    LOGMANAGER.logTicketEvent(.purchase, id: BOOKINGMANAGER.ticketModel?._id ?? "", name: BOOKINGMANAGER.ticketModel?.title ?? "", price: priceCalculation.priceWithPromo, currency: APPSESSION.userDetail?.currency ?? "AED")
                    NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil, userInfo: nil)
                    BOOKINGMANAGER.clearManager()
                    let destinationViewController = PurchaseSuccessVC()
                    let navigationController = UINavigationController(rootViewController: destinationViewController)
                    navigationController.modalPresentationStyle = .overFullScreen
                    if !destinationViewController.isVisible {
                        self.present(navigationController, animated: true, completion: nil)
                    }
                case .cancelled:
                    LOGMANAGER.logTicketEvent(.paymentCancelled, id: BOOKINGMANAGER.ticketModel?._id ?? "", name: BOOKINGMANAGER.ticketModel?.title ?? "", price: priceCalculation.priceWithPromo, currency: APPSESSION.userDetail?.currency ?? "AED")
                    self.hideHUD()
                case .failure(let error):
                    LOGMANAGER.logTicketEvent(.paymentFailed, id: BOOKINGMANAGER.ticketModel?._id ?? "", name: BOOKINGMANAGER.ticketModel?.title ?? "", price: priceCalculation.priceWithPromo, currency: APPSESSION.userDetail?.currency ?? "AED")
                    self.hideHUD(error: error as NSError?)
                }
            }
        }
    }
    
    @IBAction func _handleAddToCartEvent(_ sender: UIButton) {
        let priceCalculation = BOOKINGMANAGER.calculateTourTotals(promo: promoBaseModel)
        BOOKINGMANAGER.bookingModel.amount = Utils.convertToAED(price: priceCalculation.priceWithPromo).roundedValue()
        BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
        BOOKINGMANAGER.bookingModel.totalAmount = Utils.convertToAED(price: priceCalculation.totalAmount).roundedValue()
        BOOKINGMANAGER.bookingModel.discount = priceCalculation.discountPrice.formatted()
        BOOKINGMANAGER.bookingModel.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
        let currency = APPSESSION.userDetail?.currency.lowercased() ?? "aed"
        BOOKINGMANAGER.bookingModel.currency = currency.isEmpty ? "aed" : currency.uppercased()
        BOOKINGMANAGER.bookingModel.bookingType = BOOKINGMANAGER.ticketModel?.bookingType ?? "rayna"
        let promoCode = _promoCodeTextField.text ?? ""
        BOOKINGMANAGER.bookingModel.promoCode = promoCode
        var bookingJSON = BOOKINGMANAGER.bookingModel.toJSON()
        if var tourDetail = bookingJSON["tourDetail"] as? [String: Any], tourDetail["hotelId"] as? Int == -1 {
            tourDetail.removeValue(forKey: "hotelId")
            bookingJSON["tourDetail"] = tourDetail
        }
        _addToCart(bookingJSON)
        
    }
    
    @objc func closeSuccess() {
        navigationController?.popToRootViewController(animated: true)
    }

}

// --------------------------------------
// MARK: <CustomTableViewDelegate>
// --------------------------------------

extension HotelBookingPreviewVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? CheckOutTicketDetailHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setupData(object)
        }
        else if let cell = cell as? HotelGuestDetailCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [JPPassengerModel] else { return }
            cell.setupdata(object)
        }
        else if let cell = cell as? HotelBookingDateCell {
            guard let object = cellDict?[kCellObjectDataKey] as? JPHotelBookingRequiredFields, let model = cellDict?[kCellTagKey] as? JPHotelInfoModel  else { return }
            cell.setupdata(object, info: model)
        }
        else if let cell = cell as? RoomsPreviewCell {
            if let object = cellDict?[kCellObjectDataKey] as? JPPriceInformation {
                cell.setupData(object)
            }
        }
        else if let cell = cell as? CancellationPolicyTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? JPCancellationPolicyModel {
               cell.setupData(object)
                let lastRow = 4 + (HOTELBOOKINGMANAGER.bookingRuls?.cancellationPolicy?.PolicyRules.count ?? 0)
               let isLastRow = indexPath.row == lastRow
               cell.setCorners(lastRow: isLastRow, firstRow: false)
           } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
               cell.setupFirstCellData()
           }
       }
        else if let cell = cell as? CancellationDescTableCell {
           if let object = cellDict?[kCellObjectDataKey] as? String {
               cell._descLabel.text = Utils.convertHTMLToPlainText(from: object)
           }
       }
        else if let cell = cell as? OptionsAmountTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? JPPriceModel {
                cell.setupData(object, discount: BOOKINGMANAGER.ticketModel?.discount ?? 0, promo: promoBaseModel)
            }
        }
    }
    
}

extension HotelBookingPreviewVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == _promoCodeTextField {
            let textCount = textField.text?.count ?? 0
            
            if textField.text != _promoCode {
                _btnStackView.isHidden = false
                _applyPromoBtn.isHidden = false
                _verificationIcon.isHidden = true
                _invalidView.isHidden = true
                _promoView.borderColor = UIColor(hexString: "D9D9D9").withAlphaComponent(0.2)
                _promoView.backgroundColor = .clear
                promoBaseModel = nil
                let amount = 0
                if amount > 0 {
                    _savingPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Int(amount))".withCurrencyFont(14)
                    let totalAmount = 0
                    _savingPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount - Int(amount))".withCurrencyFont(14)
                    _offerDiscountSavingText.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount - Int(amount))".withCurrencyFont(14)
                    _savingsView.isHidden = (totalAmount - Int(amount)) == 0
                }
            }
            
            if textCount == 0 {
                _applyPromoBtn.isHidden = true
                _verificationIcon.isHidden = true
                _invalidView.isHidden = true
                _promoView.borderColor = UIColor(hexString: "D9D9D9").withAlphaComponent(0.2)
                _promoView.backgroundColor = .clear
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return newLength <= 8
    }
    
}

