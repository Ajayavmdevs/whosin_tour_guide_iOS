import UIKit
import StripePayments
import StripePaymentSheet
import PassKit
import Hero

class MyCartVC: ChildViewController {

    @IBOutlet private weak var _checkOutBtn: GradientView!
    @IBOutlet private weak var _navigationHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _checkoutPriceView: UIView!
    @IBOutlet private weak var _totalPriceLabel: CustomLabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet weak var _promoView: UIView!
    @IBOutlet weak var _invalidText: UILabel!
    @IBOutlet weak var _invalidView: UIView!
    @IBOutlet weak var _verificationIcon: CustomActivityButton!
    @IBOutlet weak var promoCodeStack: UIStackView!
    @IBOutlet weak var _promoCodeTextField: UITextField!
    @IBOutlet weak var _applyPromoBtn: CustomActivityButton!
    @IBOutlet weak var _savingsView: UIView!
    @IBOutlet weak var _savingPriceLabel: CustomLabel!
    @IBOutlet private weak var _appliedPromoView: UIView!
    @IBOutlet private weak var _appliedPromoTitle: CustomLabel!
    @IBOutlet private weak var _priceBreakDownView: UIView!
    @IBOutlet private weak var _promoCodeDiscountedView: UIStackView!
    @IBOutlet private weak var _offerDiscountedSavingView: UIStackView!
    @IBOutlet private weak var _offerDiscountSavingText: CustomLabel!
    @IBOutlet private weak var _promoDiscountLabel: CustomLabel!
    
    private var _promoCode: String = kEmptyString
    private let kCellIdentifierVenueDetail = String(describing: MyCartTableCell.self)
    private var _cartModel: [CartModel] = []
    private var promoBaseModel: PromoBaseModel? = nil

    var paymentSheet: PaymentSheet?
    let repo = CartRepository()

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        getCartData()
        _setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLabel(_:)), name: Notification.Name("addtoCartCount"), object: nil)
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
            emptyDataDescription: "Your cart's got room for fun stuff! Explore our offers and start adding to your cart",
            delegate: self)
        _loadData()
        _tableView.proxyDelegate = self

    }
    
    @objc private func hideShowPriceBreakdown() {
        _priceBreakDownView.isHidden.toggle()
        _promoCodeDiscountedView.isHidden = promoBaseModel == nil
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _cartModel.forEach { data in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierVenueDetail,
                kCellTagKey: kCellIdentifierVenueDetail,
                kCellObjectDataKey: data,
                kCellClassKey: MyCartTableCell.self,
                kCellHeightKey: MyCartTableCell.height
            ])
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
        if let firstItem = _cartModel.first {
             LOGMANAGER.logTicketEvent(.viewCart, id: firstItem.id, name: "View Cart")
        }
//        let amount = _cartModel.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
//        _totalPriceLabel.text = String(format: "D %.2f", amount)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: MyCartTableCell.self, kCellHeightKey: MyCartTableCell.height],
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
        showHUD()
        guard let promo = _promoCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
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
            self._applyPromoBtn.hideActivity()
            self._promoView.isHidden = true
            self._appliedPromoView.isHidden = false
            self._invalidView.isHidden = true
            let promoType = promoBaseModel?.metadata.first?.promoType
            let floatAmount = _cartModel.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
            let originalAmount = _cartModel.map { $0.originalPrice * $0.quantity }.reduce(0, +)
            let totalDiscount = promoBaseModel?.totalDiscount ?? 0
            let discountedTotal = Double(originalAmount) - totalDiscount

            let itemsDiscount = promoBaseModel?.itemsDiscount ?? 0
            let promoDiscount = promoBaseModel?.promoDiscount ?? 0
 
            // Update UI labels
            self._totalPriceLabel.text = String(format: "D %.2f", discountedTotal)
            self._savingPriceLabel.text = String(format: "D %.2f", totalDiscount)
            self._appliedPromoTitle.text = String(format: "D %.2f \("saved_with".localized()) %@", promoDiscount, promo)
            self._offerDiscountSavingText.text = String(format: "D %.2f", itemsDiscount)
            self._promoDiscountLabel.text = String(format: "D %.2f", promoDiscount)
            self._promoCodeDiscountedView.isHidden = false

            // Hide savings view if there is no discount
            self._savingsView.isHidden = (promoDiscount == 0 && itemsDiscount == 0 && itemsDiscount == 0 && promoDiscount == 0)
            _loadData()
        }

    }
    
    private func getCartData() {
        _cartModel = repo.getList()
        _loadData()
        let amount = _cartModel.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        let totalqty = _cartModel.map { $0.quantity }.reduce(0, +)
        
        _totalPriceLabel.text = String(format: "D %.2f", amount)
        if amount > 0 {
            _totalPriceLabel.text = "D\(Int(amount))"
            let totalAmount = _cartModel.map { $0.originalPrice * $0.quantity }.reduce(0, +)
            _savingPriceLabel.text = "D\(totalAmount - Int(amount))"
            _offerDiscountSavingText.text = "D\(totalAmount - Int(amount))"
            _savingsView.isHidden = (totalAmount - Int(amount)) == 0
            _offerDiscountedSavingView.isHidden = (totalAmount - Int(amount)) == 0
        } else {
            _checkoutPriceView.isHidden = true
            _savingsView.isHidden = true
            _applyPromoBtn.isHidden = true
        }
        if totalqty == 0 {
            _removePromoCode()
        } else if promoBaseModel != nil {
            _promocodeMetaData()
        }
    }

    private func _removePromoCode() {
        _applyPromoBtn.isHidden = false
        _verificationIcon.isHidden = true
        _invalidView.isHidden = true
        _promoView.borderColor = UIColor(hexString: "D9D9D9").withAlphaComponent(0.2)
        _promoView.backgroundColor = .clear
        _appliedPromoView.isHidden = true
        _promoCodeTextField.text = kEmptyString
        _promoView.isHidden = false
        _savingsView.isHidden = true
        _offerDiscountedSavingView.isHidden = true
        _promoCodeDiscountedView.isHidden = true
        _priceBreakDownView.isHidden = true
        let amount = _cartModel.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        if amount > 0 {
            _totalPriceLabel.text = "D\(Int(amount))"
            let totalAmount = _cartModel.map { $0.originalPrice * $0.quantity }.reduce(0, +)
            _savingPriceLabel.text = "D\(totalAmount - Int(amount))"
            _offerDiscountSavingText.text = "D\(totalAmount - Int(amount))"
            _savingsView.isHidden = (totalAmount - Int(amount)) == 0
            _offerDiscountedSavingView.isHidden = (totalAmount - Int(amount)) == 0
        }
        _promoCodeDiscountedView.isHidden = true
        _promoView.isHidden = _cartModel.isEmpty
        _checkOutBtn.isHidden = _cartModel.isEmpty
        promoBaseModel = nil
        _loadData()
    }
    
    private func _promocodeMetaData() {
        let totalqty = _cartModel.map { $0.quantity }.reduce(0, +)
        
        guard totalqty > 0 else {
            alert(message: "select_items_to_purchase".localized())
            return
        }
        guard let promoCode = _promoCodeTextField.text, !promoCode.isEmpty else {
            alert(message: "enter_promo_code".localized())
            return
        }
        
        var metaData = [[String: Any]]()
        let _tmpCartData = _cartModel.filter { $0.quantity != 0 }
        
        _tmpCartData.forEach({
            if $0.type == "offer" {
                let item: [String: Any] = ["packageId" : $0.id, "amount": $0.originalPrice, "type": "package", "discount": $0.discount == 0 ? $0.discountValue : $0.discount, "qty": $0.quantity ]
                metaData.append(item)
            } else if $0.type == "deal" {
                let item: [String: Any] = ["amount": $0.originalPrice,"dealId": $0.dealId, "type": "deal", "discount": $0.discount == 0 ? $0.discountValue : $0.discount, "qty": $0.quantity ]
                metaData.append(item)
            } else if $0.type == "event" {
                let item: [String: Any] = ["amount": $0.originalPrice, "packageId": $0.id, "type": "package", "discount": $0.discount == 0 ? $0.discountValue : $0.discount, "qty": $0.quantity ]
                metaData.append(item)
            }
        })

        _applyPromoBtn.setTitle("", for: .normal)
        _applyPromoBtn.showActivity()
        applyPromoCode(metaData)
    }
    
    // --------------------------------------
    // MARK: Evennt
    // --------------------------------------
    
    @IBAction func _handleRemovePromoEvent(_ sender: CustomActivityButton) {
        _removePromoCode()
    }
    
    @IBAction func _handleApplyPromoEvent(_ sender: CustomActivityButton) {
        _promocodeMetaData()
    }
    
    @IBAction private func _handleCheckoutEvent(_ sender: UIButton) {
        let floatAmount = _cartModel.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        let orignalPrice = _cartModel.map { $0.originalPrice * $0.quantity }.reduce(0, +)
        let amount: Float = round(floatAmount * 100) / 100
        let discotedTotal = Double(orignalPrice) - (promoBaseModel?.totalDiscount ?? 0)

        var metaData = [[String: Any]]()
        _cartModel.forEach({
            if $0.type == "offer" {
                let item: [String: Any] = ["packageId" : $0.id, "price": ($0.floatDiscountedPrice * Float($0.quantity)), "qty": $0.quantity, "venueId": $0.venueId, "offerId": $0.offerId, "type": $0.type ]
                metaData.append(item)
            } else if $0.type == "deal" {
                let item: [String: Any] = ["voucherId" : $0.id, "price": ($0.floatDiscountedPrice * Float($0.quantity)), "qty": $0.quantity, "venueId": $0.venueId, "dealId": $0.dealId, "type": $0.type ]
                metaData.append(item)
            } else if $0.type == "activity" {
                let date = Utils.stringToDate($0.activityDate, format: kFormatDateDOB)
                let item: [String: Any] = ["activityId": $0.id, "activityType": $0.activityType, "date": Utils.dateToString(date, format: kFormatDate), "time": $0.activityTime, "reservedSeat": $0.quantity, "price": ($0.floatDiscountedPrice * Float($0.quantity)), "type": "activity" ]
                metaData.append(item)
            } else if $0.type == "event" {
                let item: [String: Any] = ["price": ($0.floatDiscountedPrice * Float($0.quantity)), "qty": $0.quantity,"venueId": $0.venueId, "packageId": $0.packageId, "eventId": $0.eventId, "type": $0.type ]
                metaData.append(item)
            }
        })
        
        if amount == 0 || metaData.count == 0 {
            alert(title: kAppName, message: "Your cart is currently empty.")
            return
        }
        
        let totalAmmount = amount - Float(discotedTotal)
        let params: [String: Any] = promoBaseModel == nil ?  ["totalAmount" : "\(Int(amount))" ,"amount" : "\(Int(amount))", "currency": "aed", "metadata": metaData] : ["amount" : "\(Int(discotedTotal))", "totalAmount" : "\(orignalPrice)", "currency": "aed", "metadata": metaData, "promoCode": _promoCodeTextField.text ?? "", "discount": totalAmmount]
        PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: amount < 10, purchaseType: .package) { result in
            switch result {
            case .success:
                self.hideHUD()
                self.repo.clearCart { updated in
                    if updated {
                        self._loadData()
                        let destinationViewController = PurchaseSuccessVC()
                        let navigationController = UINavigationController(rootViewController: destinationViewController)
                        navigationController.modalPresentationStyle = .overFullScreen
                        if !destinationViewController.isVisible {
                            self.present(navigationController, animated: true, completion: nil)
                        }
                    }
                }
            case .cancelled:
                self.hideHUD()
            case .failure(let error):
                self.hideHUD(error: error as NSError)
            }
        }
        
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension MyCartVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension MyCartVC: CustomTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyCartTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CartModel else { return }
            cell.setupData(object, promoModel: promoBaseModel)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? CartModel else { return }
        if object.type == "offer" {
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.offerId = object.offerId
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            vc.buyNowOpenCallBack = { offer, venue, timing in
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
            presentAsPanModal(controller: vc)
        } else if object.type == "activity" {
            let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            vc.activityId = object.activityId
            self.navigationController?.pushViewController(vc, animated: true)
        } else if object.type == "deal" {
            let vc = INIT_CONTROLLER_XIB(DealsDetailVC.self)
            let venueModel = VenueDetailModel()
            venueModel.id = object.venueId
            venueModel.name = object.venueName
            venueModel.address = object.venueAddress
            venueModel.slogo = object.venueLogo
            let dealModel = DealsModel()
            dealModel.title = object.title
            dealModel.descriptions = object.descriptions
            dealModel.image = object.dealImage
            dealModel.startDate = object.startDate
            dealModel.endDate = Utils.dateToString(object.endDate, format: kFormatDate)
            dealModel._days = object.days
            dealModel.startTime = object.startTime
            dealModel.endTime = object.endTime
            dealModel.actualPrice = object.originalPrice
            dealModel.discountedPrice = Int(object.floatDiscountedPrice)
            dealModel.features = object.features
            dealModel.vouchars = object.vouchars
            dealModel.venueModel = venueModel
            vc.dealsModel = dealModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func delete(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, _) in
            guard indexPath.row < self._cartModel.count else { return } // Add bounds check
            let item = self._cartModel[indexPath.row]
            LOGMANAGER.logTicketEvent(.removeCart, id: item.id, name: item.title)
            let repo = CartRepository()
            repo.removeFromCart(model: self._cartModel[indexPath.row])
            self._cartModel.remove(at: indexPath.row)
            self._loadData()
        }
        return action
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = self.delete(forRowAtIndexPath: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        swipe.performsFirstActionWithFullSwipe = true
        return swipe
    }
}


extension MyCartVC: UITextFieldDelegate {
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
                    let amount = _cartModel.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
                    if amount > 0 {
                        _totalPriceLabel.text = "D\(Int(amount))"
                        let totalAmount = _cartModel.map { $0.originalPrice * $0.quantity }.reduce(0, +)
                        _savingPriceLabel.text = "D\(totalAmount - Int(amount))"
                        _offerDiscountSavingText.text = "D\(totalAmount - Int(amount))"
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
