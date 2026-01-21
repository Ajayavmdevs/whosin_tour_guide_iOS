import UIKit
import StripePayments
import StripePaymentSheet
import PassKit
import Hero

class MyTicketCartVC: ChildViewController {

    @IBOutlet private weak var _removePromoBtn: CustomActivityButton!
    @IBOutlet private weak var _checkOutBtn: GradientView!
    @IBOutlet private weak var _navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _checkoutPriceView: UIView!
    @IBOutlet private weak var _totalPriceLabel: CustomLabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _promoView: UIView!
    @IBOutlet private weak var _invalidText: UILabel!
    @IBOutlet private weak var _invalidView: UIView!
    @IBOutlet private weak var _verificationIcon: CustomActivityButton!
    @IBOutlet private weak var promoCodeStack: UIStackView!
    @IBOutlet private weak var _promoCodeTextField: UITextField!
    @IBOutlet private weak var _applyPromoBtn: CustomActivityButton!
    @IBOutlet private weak var _savingsView: UIView!
    @IBOutlet private weak var _savingPriceLabel: CustomLabel!
    @IBOutlet private weak var _appliedPromoView: UIView!
    @IBOutlet private weak var _appliedPromoTitle: CustomLabel!
    @IBOutlet private weak var _priceBreakDownView: UIView!
    @IBOutlet private weak var _promoCodeDiscountedView: UIStackView!
    @IBOutlet private weak var _offerDiscountedSavingView: UIStackView!
    @IBOutlet private weak var _offerDiscountSavingText: CustomLabel!
    @IBOutlet private weak var _promoDiscountLabel: CustomLabel!
    
    private var _promoCode: String = kEmptyString
    private let kCellIdentifierVenueDetail = String(describing: MyTicketCartCell.self)
    private let kCellIdentifiercontact = String(describing: ConnectUSTableViewCell.self)
    private var promoBaseModel: PromoBaseModel? = nil
    private var ticketCartModel: TicketCartListModel?

    var paymentSheet: PaymentSheet?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        ticketCartModel = APPSETTING.ticketCartModel
        _setupUi()
        _loadData()
        getCartData()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLabel(_:)), name: Notification.Name("addtoCartCount"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _removePromoCode()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        hideNavigationBar()
        if let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height {
            _navigationHeightConstraint.constant = statusBarHeight
        } else {
            _navigationHeightConstraint.constant = 44
        }
        let tapPriceGesture = UITapGestureRecognizer(target: self, action: #selector(hideShowPriceBreakdown))
        _savingsView.isUserInteractionEnabled = true
        _savingsView.addGestureRecognizer(tapPriceGesture)
        _promoCodeTextField.delegate = self
        view.hero.id = String(describing: MyCartVC.self)
        view.hero.modifiers = HeroAnimationModifier.stories
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_cart"),
            emptyDataDescription: "empty_cart_message".localized(),
            delegate: self)
        _tableView.proxyDelegate = self

    }
    
    @objc private func hideShowPriceBreakdown() {
        _priceBreakDownView.isHidden.toggle()
        _promoCodeDiscountedView.isHidden = promoBaseModel == nil
    }
    
    private func _loadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            if promoBaseModel != nil {
                let floatAmount = promoBaseModel?.amount ?? "0"
                _ = promoBaseModel?.totalDiscount ?? 0
                let totalDiscount = promoBaseModel?.totalDiscount ?? 0
                let itemsDiscount = promoBaseModel?.itemsDiscount ?? 0
                let promoDiscount = promoBaseModel?.promoDiscount ?? 0
                self._totalPriceLabel.text = "\(Utils.getCurrentCurrencySymbol()) \(Utils.convertCurrent(Double(floatAmount) ?? 0 ).formattedWithoutDecimal())"
                self._savingPriceLabel.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", totalDiscount).withCurrencyFont(14)
                self._appliedPromoTitle.attributedText = Utils.makePromoTitleText(discount: promoDiscount, promoCode: _promoCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", defaultFont: FontBrand.SFregularFont(size: 14), dirhamFont: FontBrand.dirhamText(size: 14))
                self._offerDiscountSavingText.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", itemsDiscount).withCurrencyFont(14)
                self._promoDiscountLabel.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", promoDiscount).withCurrencyFont(14)
                self._promoCodeDiscountedView.isHidden = false
                self._savingsView.isHidden = (promoDiscount == 0 && itemsDiscount == 0 && itemsDiscount == 0 && promoDiscount == 0)
            } else {
                let price = ticketCartModel?.items.map { $0.amount }.reduce(0, +) ?? 0
                let discount = ticketCartModel?.items.map { $0.discount }.reduce(0, +) ?? 0
                _checkoutPriceView.isHidden = price <= 0
                _totalPriceLabel.text = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(price).formattedWithoutDecimal())"
                _savingPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discount)".withCurrencyFont(14)
                _offerDiscountSavingText.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discount)".withCurrencyFont(14)
                _savingsView.isHidden = discount == 0
                _offerDiscountedSavingView.isHidden = discount == 0
            }
            LOGMANAGER.logTicketEvent(.viewCart, id: ticketCartModel?.items.first?._id ?? "", name: "View cart")

            let sortedData = ticketCartModel?.items.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
            sortedData?.forEach { data in
                if let ticket = self.ticketCartModel?.customTickets.first(where: { $0._id == data.customTicketId }) {
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifierVenueDetail,
                        kCellTagKey: ticket,
                        kCellObjectDataKey: data,
                        kCellClassKey: MyTicketCartCell.self,
                        kCellHeightKey: MyTicketCartCell.height
                    ])
                }
            }
            
            if let model = ticketCartModel?.contactUsBlock {
                if model.isEnabled(screenName: .cart) {
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifiercontact,
                        kCellTagKey: kCellIdentifiercontact,
                        kCellObjectDataKey: model,
                        kCellClassKey: ConnectUSTableViewCell.self,
                        kCellHeightKey: ConnectUSTableViewCell.height
                    ])
                }
            }
            
            if !cellData.isEmpty {
                cellSectionData.append([kSectionTitleKey: "", kSectionDataKey: cellData])
            }
            
            _tableView.loadData(cellSectionData)
            _tableView.reload()
        }
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: MyTicketCartCell.self, kCellHeightKey: MyTicketCartCell.height],
            [kCellIdentifierKey: kCellIdentifiercontact, kCellNibNameKey: kCellIdentifiercontact, kCellClassKey: ConnectUSTableViewCell.self, kCellHeightKey: ConnectUSTableViewCell.height],
        ]
    }
    
    @objc private func handleUpdateLabel(_ notification: Notification) {
        getCartData()
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("addtoCartCount"), object: nil)
    }
    
    // --------------------------------------
    // MARK: Services
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
            self.getCartData()
            let floatAmount = promoBaseModel?.amount ?? "0"
            _ = promoBaseModel?.totalDiscount ?? 0
            let totalDiscount = promoBaseModel?.totalDiscount ?? 0
            let itemsDiscount = promoBaseModel?.itemsDiscount ?? 0
            let promoDiscount = promoBaseModel?.promoDiscount ?? 0
            self._totalPriceLabel.text = "\(Utils.getCurrentCurrencySymbol()) \(Utils.convertCurrent(Double(floatAmount) ?? 0).formattedWithoutDecimal())"
            self._savingPriceLabel.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", totalDiscount).withCurrencyFont(14)
            self._appliedPromoTitle.attributedText = Utils.makePromoTitleText(discount: promoDiscount, promoCode: promo, defaultFont: FontBrand.SFregularFont(size: 14), dirhamFont: FontBrand.dirhamText(size: 14))
            self._offerDiscountSavingText.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", itemsDiscount).withCurrencyFont(14)
            self._promoDiscountLabel.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.2f", promoDiscount).withCurrencyFont(14)
            self._promoCodeDiscountedView.isHidden = false
            self._savingsView.isHidden = (promoDiscount == 0 && itemsDiscount == 0 && itemsDiscount == 0 && promoDiscount == 0)
            _loadData()
        }

    }
    
    private func getCartData() {
        WhosinServices.viewCart { [weak self] container, error in
            guard let self = self else { return }
            if error?.localizedDescription == "Cart is empty!" {
                self.hideHUD()
                self.ticketCartModel = nil
                self._loadData()
                return
            }
            self.hideHUD(error: error)
            guard let data = container?.data else {
                self._checkoutPriceView.isHidden = true
                self._loadData()
                return
            }
            self.ticketCartModel = data
            self._loadData()
        }
    }
    
    private func _requestRemovePromo() {
        _removePromoBtn.showActivity()
        WhosinServices.removePromoCode { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            if data.code == 1 {
                _removePromoCode()
                showToast("Promo_code_removed".localized())
                self._removePromoBtn.hideActivity()
            }
        }
    }

    private func _removePromoCode() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            getCartData()
            _applyPromoBtn.isHidden = false
            _verificationIcon.isHidden = true
            _invalidView.isHidden = true
            _promoView.borderColor = UIColor(hexString: "D9D9D9").withAlphaComponent(0.2)
            _promoView.backgroundColor = .clear
            _appliedPromoView.isHidden = true
            _promoCodeTextField.text = ""
            _savingsView.isHidden = true
            _offerDiscountedSavingView.isHidden = true
            _promoCodeDiscountedView.isHidden = true
            _priceBreakDownView.isHidden = true
            _promoView.isHidden = ticketCartModel?.items.isEmpty ?? true
            _checkOutBtn.isHidden = ticketCartModel?.items.isEmpty ?? true
            promoBaseModel = nil
            _loadData()
        }
    }
    
    private func _promocodeMetaData() {
        if ticketCartModel?.items.isEmpty == true  {
            alert(message: "select_items_to_purchase".localized())
            return
        }
        guard let promoCode = _promoCodeTextField.text, !promoCode.isEmpty else {
            alert(message: "enter_promo_code".localized())
            return
        }
        
        var metaData = [[String: Any]]()
        
        ticketCartModel?.items.forEach { model in
            let dict: [String: Any] = [
                "_id": model._id,
                "type": "ticket",
                "ticketId": model.customTicketId,
                "amount": model.amount,
                "discount": model.discount,
                "qty": 1
            ]
            metaData.append(dict)
        }

        _applyPromoBtn.setTitle("", for: .normal)
        _applyPromoBtn.showActivity()
        applyPromoCode(metaData)
    }
    
    // --------------------------------------
    // MARK: Evennt
    // --------------------------------------
    
    @IBAction func _handleRemovePromoEvent(_ sender: CustomActivityButton) {
        _requestRemovePromo()
    }
    
    @IBAction func _handleApplyPromoEvent(_ sender: CustomActivityButton) {
        _promocodeMetaData()
    }
    
    @IBAction private func _handleCheckoutEvent(_ sender: UIButton) {
        let ids = ticketCartModel?.items.map({ $0._id }) ?? []
        guard !ids.isEmpty else {
            alert(message: "cart_empty".localized())
            return
        }
        
        let promo = _promoCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Utils.convertToAED(price: Double(promoBaseModel?.amount ?? "0") ?? 0)
        let params: [String: Any] = promoBaseModel == nil ? ["cartIds": ids, "target": ""] : ["cartIds": ids, "promoCode": promo ?? "", "amount": amount, "discount": promoBaseModel?.totalDiscount ?? 0, "totalAmount": Utils.convertToAED(price: promoBaseModel?.totalDiscount ?? 0), "promoCodeData": promoBaseModel?.metadata.toArrayDetached(ofType: PromoCodeApplyModel.self).toJSON() ?? [], "target": ""]
        let baseAmountString = promoBaseModel?.amount ?? ""
        let promoAmount = Double(baseAmountString)

        let cartTotal = ticketCartModel?.items.map { Double($0.amount) }.reduce(0, +) ?? 0

        let price: Double = promoAmount ?? cartTotal
        LOGMANAGER.logTicketEvent(.checkout, id: ids.first ?? "", name: "begin_checkout", price: price, currency: APPSESSION.userDetail?.currency ?? "AED")
        LOGMANAGER.logTicketEvent(.paymentInitiated, id: ids.first ?? "", name: "cart_item_checkout", price: price,currency: APPSESSION.userDetail?.currency ?? "AED")
        PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: price < 10, purchaseType: .cart) { result in
            switch result {
            case .success:
                LOGMANAGER.logTicketEvent(.purchase, id: ids.first ?? "purchase_success", name: "Purchase Success", price: price, currency: APPSESSION.userDetail?.currency ?? "AED")
                self.hideHUD()
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil, userInfo: nil)
                BOOKINGMANAGER.clearManager()
                self.ticketCartModel = nil
                APPSETTING.ticketCartModel = nil
                self._loadData()
                let destinationViewController = PurchaseSuccessVC()
                let navigationController = UINavigationController(rootViewController: destinationViewController)
                navigationController.modalPresentationStyle = .overFullScreen
                if !destinationViewController.isVisible {
                    self.present(navigationController, animated: true, completion: nil)
                }
            case .cancelled:
                LOGMANAGER.logTicketEvent(.paymentCancelled, id: ids.first ?? "purchase_cancelled", name: "Purchase Cancelled", price: price, currency: APPSESSION.userDetail?.currency ?? "AED")
                self.hideHUD()
            case .failure(let error):
                LOGMANAGER.logTicketEvent(.paymentFailed, id: ids.first ?? "purchase_failure", name: "Purchase Failure", price: price, currency: APPSESSION.userDetail?.currency ?? "AED")
                self.hideHUD(error: error as NSError)
            }
        }
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension MyTicketCartVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension MyTicketCartVC: CustomTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyTicketCartCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BookingModel, let ticket = cellDict?[kCellTagKey] as? TicketModel else { return }
            cell.setup(object, ticket)
            cell.callback = {
                LOGMANAGER.logTicketEvent(.removeCart, id: ticket._id, name: ticket.title)
                self.showHUD()
                self.ticketCartModel = nil
                APPSETTING.ticketCartModel = nil
                self.showSuccessMessage("item_removed".localized(), subtitle: "removed_from_cart".localized())
                self.getCartData()
            }
        } else if let cell = cell as? ConnectUSTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ContactUsModel else { return }
            cell.setup(object, screen: .cart)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
    }

}

extension MyTicketCartVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
            if textField == _promoCodeTextField {
                let textCount = textField.text?.count ?? 0
                
                if textField.text != _promoCode {
                    _applyPromoBtn.isHidden = false
                    _verificationIcon.isHidden = true
                    _invalidView.isHidden = true
                    _promoView.borderColor = UIColor(hexString: "D9D9D9").withAlphaComponent(0.2)
                    _promoView.backgroundColor = .clear
                    promoBaseModel = nil
                    let amount = 0
                    if amount > 0 {
                        _totalPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(Double(amount)).formattedWithoutDecimal())".withCurrencyFont(14, false)
                        let totalAmount = 0//_cartModel.map { $0.originalPrice * $0.quantity }.reduce(0, +)
                        _savingPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount - Int(amount))".withCurrencyFont(14, false)
                        _offerDiscountSavingText.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount - Int(amount))".withCurrencyFont(14, false)
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

        // Limit promo code to 8 characters
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            return newLength <= 8
        }

}
