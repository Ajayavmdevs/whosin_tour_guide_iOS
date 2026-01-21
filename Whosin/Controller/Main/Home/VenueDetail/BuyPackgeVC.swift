import UIKit
import Hero
import ObjectMapper
import StripePaymentSheet

class BuyPackgeVC: ChildViewController {
    
    @IBOutlet private weak var _promoCodeTextField: UITextField!
    @IBOutlet private weak var _applyPromoBtn: CustomActivityButton!
    @IBOutlet private weak var _savingsView: UIView!
    @IBOutlet private weak var _savingPriceLabel: UILabel!
    @IBOutlet private weak var _venueInfoview: CustomVenueInfoView!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _stackView: UIStackView!
    @IBOutlet private weak var _titileLabel: UILabel!
    @IBOutlet private weak var _conditionText: UILabel!
    @IBOutlet private weak var _valueView: UIView!
    @IBOutlet private weak var _cartButton: BadgeButton!
    @IBOutlet private weak var _addedToCartValue: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _viewCartLabel: UILabel!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _checkOutView: GradientView!
    @IBOutlet private weak var _addToCartView: UIView!
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
    public var dealsId: String = kEmptyString
    public var dealsModel: DealsModel?
    let repo = CartRepository()
    private let kCellIdentifierVenueDetail = String(describing: PackageInfoTableCell.self)
    private let kCellIdentifierActivityDetail = String(describing: BuyActivityCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kBuyOfferTableCellIdentifire = String(describing: BuyOffersTableCell.self)
    private let kPackageOfferCellIdentifire = String(describing: PackageOfferTableCell.self)
    public var callback: (() -> Void)?
    public static var tmpCart: [CartModel] = []
    public var paymentSheet: PaymentSheet?
    public var isFromActivity: Bool = false
    public var type: String = kEmptyString
    public var activityModel: [ActivitiesModel] = []
    public var offerModel: OffersModel?
    public var venue: VenueDetailModel?
    public var eventModel: EventModel?
    private var _checkoutActivityModel: ActivitiesModel?
    private var _activityItem: Int?
    private var _activityDate: String?
    private var _activityTime: String?
    public var timingModel: [TimingModel]?
    private var _promoCode: String = kEmptyString
    private var promoBaseModel: PromoBaseModel? = nil
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    public func setCallback(callback: (() -> Void)?) {
        self.callback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        BuyPackgeVC.tmpCart = []
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLabel(_:)), name: Notification.Name("addtoCartCount"), object: nil)
        if type == "offers" {
            if venue == nil {
                _venueInfoview.setupData(venue: offerModel?.venue ?? VenueDetailModel(), isAllowClick: true)
            } else {
                _venueInfoview.setupData(venue: venue ?? VenueDetailModel(), isAllowClick: true)
            }
            _loadOffersData()
        } else if type == "activity" {
            _stackView.isHidden = true
            _titileLabel.isHidden = false
            _titileLabel.text = "your_order"
            _loadActivityData()
        } else if type == "event" {
            if let venueDetail = eventModel?.venueDetail {
                _venueInfoview.setupData(venue: venueDetail, isAllowClick: true)
            } else if let venueDetail = Utils.getModelFromId(model: APPSETTING.venueModel, id: eventModel?.venue ?? kEmptyString) {
                _venueInfoview.setupData(venue: venueDetail, isAllowClick: true)
            } else {
                _venueInfoview.setupData(venue: venue ?? VenueDetailModel(), isAllowClick: true)
            }

            _loadOffersData()
        } else {
            BuyPackgeVC.tmpCart = []
            _loadData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateLabel), name: Notification.Name("addtoCartCount"), object: nil)
        let cartList = repo.getList()
        _cartButton.badgeNumber = cartList.count
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openDeclaimer))
        _conditionText.isUserInteractionEnabled = true
        _conditionText.addGestureRecognizer(tapGesture)
        let tapPriceGesture = UITapGestureRecognizer(target: self, action: #selector(hideShowPriceBreakdown))
        _savingsView.isUserInteractionEnabled = true
        _savingsView.addGestureRecognizer(tapPriceGesture)

        _promoCodeTextField.delegate = self
        //TABEL VIEW
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no data available",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        let fullText = "Check terms and conditions regarding each offer"
        let attributedText = NSMutableAttributedString(string: fullText)
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: FontBrand.SFsemiboldFont(size: 12)
        ]
        if let range = fullText.range(of: "terms and conditions") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.setAttributes(boldAttributes, range: nsRange)
        }
        _conditionText.attributedText = attributedText
        
        
        if type == "offers" {
            if offerModel?.disclaimerTitle.isEmpty == true {
                _conditionText.isHidden = true
            } else {
                _conditionText.isHidden = false
            }
        } else if type == "event" {
            if eventModel?.disclaimerTitle.isEmpty == true {
                _conditionText.isHidden = true
            } else {
                _conditionText.isHidden = false
            }
        } else if isFromActivity {
            if activityModel.first?.disclaimerTitle.isEmpty == true {
                _conditionText.isHidden = true
            } else {
                _conditionText.isHidden = false
            }
        }
    }
    
    private func _loadOffersData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if type == "offers" {
            cellData.append([
                kCellIdentifierKey: kBuyOfferTableCellIdentifire,
                kCellTagKey: kBuyOfferTableCellIdentifire,
                kCellObjectDataKey: offerModel,
                kCellClassKey: BuyOffersTableCell.self,
                kCellHeightKey: BuyOffersTableCell.height
            ])
            offerModel?.packages.forEach({ model in
                if model.isAllowSale == true, model.actualPrice != 0, model._flootdiscountedPrice != 0 {
                    cellData.append([
                        kCellIdentifierKey: kPackageOfferCellIdentifire,
                        kCellTagKey: kPackageOfferCellIdentifire,
                        kCellObjectDataKey: model,
                        kCellClassKey: PackageOfferTableCell.self,
                        kCellHeightKey: PackageOfferTableCell.height
                    ])
                }
            })
        }
        else if type == "event" {
            cellData.append([
                kCellIdentifierKey: kBuyOfferTableCellIdentifire,
                kCellTagKey: kBuyOfferTableCellIdentifire,
                kCellObjectDataKey: eventModel,
                kCellClassKey: BuyOffersTableCell.self,
                kCellHeightKey: BuyOffersTableCell.height
            ])
            eventModel?.packages.forEach({ model in
                if model.actualPrice != 0, model._flootdiscountedPrice != 0 {
                    cellData.append([
                        kCellIdentifierKey: kPackageOfferCellIdentifire,
                        kCellTagKey: kPackageOfferCellIdentifire,
                        kCellObjectDataKey: model,
                        kCellClassKey: PackageOfferTableCell.self,
                        kCellHeightKey: PackageOfferTableCell.height
                    ])
                }
            })
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadActivityData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        activityModel.forEach { activityModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivityDetail,
                kCellTagKey: kCellIdentifierActivityDetail,
                kCellObjectDataKey: activityModel,
                kCellClassKey: BuyActivityCell.self,
                kCellHeightKey: BuyActivityCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let dealsModel = dealsModel else {
            return
        }
        
        if dealsModel.venueModel == nil {
            guard let venue = Utils.getModelFromId(model: APPSETTING.venueModel, id: dealsModel.venueId) else { return }
            dealsModel.venueModel = venue
        }
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierVenueDetail,
            kCellTagKey: kCellIdentifierVenueDetail,
            kCellObjectDataKey: dealsModel,
            kCellClassKey: PackageInfoTableCell.self,
            kCellHeightKey: PackageInfoTableCell.height
        ])
        
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _venueInfoview.setupData(venue: dealsModel.venueModel ?? VenueDetailModel(), isAllowClick: true
        )
        _tableView.loadData(cellSectionData)
    }
    
    private func _getCartData() {
        _valueView.isHidden = BuyPackgeVC.tmpCart.isEmpty
        _savingsView.isHidden = BuyPackgeVC.tmpCart.isEmpty
        let amount = BuyPackgeVC.tmpCart.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        let totalqty = BuyPackgeVC.tmpCart.map { $0.quantity }.reduce(0, +)
        if amount > 0 {
            _addedToCartValue.attributedText = "D\(Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
            let totalAmount = BuyPackgeVC.tmpCart.map { $0.originalPrice * $0.quantity }.reduce(0, +)
            _savingPriceLabel.attributedText = "D\(totalAmount - Int(amount))".applyingDirhamFont(defaultFont: _savingPriceLabel.font)
            _offerDiscountSavingText.attributedText = "D\(totalAmount - Int(amount))".applyingDirhamFont(defaultFont: _offerDiscountSavingText.font)
            _savingsView.isHidden = (totalAmount - Int(amount)) == 0
            _offerDiscountedSavingView.isHidden = (totalAmount - Int(amount)) == 0
        } else {
            _valueView.isHidden = true
            _savingsView.isHidden = true
        }
        let cartList = repo.getList()
        _cartButton.badgeNumber = cartList.count
        if totalqty == 0 {
            _removePromoCode()
        } else if promoBaseModel != nil {
            if type == "offers" || type == "event" {
               _promocodeMetaData()
            } else {
                _promocodeMetaData()
            }
        }
    }
    
    @objc func handleUpdateLabel(_ notification: Notification) {
        _getCartData()
    }
    
    @objc private func openDeclaimer() {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        if type == "offers", let title = offerModel?.disclaimerTitle, let discription = offerModel?.disclaimerDescription {
            vc.disclaimerTitle = title
            vc.disclaimerdescriptions = discription
            presentAsPanModal(controller: vc)
        } else if type == "event",  let title = eventModel?.disclaimerTitle, let discription = eventModel?.disclaimerDescription {
            vc.disclaimerTitle = title
            vc.disclaimerdescriptions = discription
            presentAsPanModal(controller: vc)
        } else if isFromActivity, let title = activityModel.first?.disclaimerTitle, let discription = activityModel.first?.disclaimerDescription {
            vc.disclaimerTitle = title
            vc.disclaimerdescriptions = discription
            presentAsPanModal(controller: vc)
        } else { return }
    }
    
    @objc private func hideShowPriceBreakdown() {
        _priceBreakDownView.isHidden.toggle()
        _promoCodeDiscountedView.isHidden = promoBaseModel == nil
    }
    
    @objc func handleOpenWallet(_ notification: Notification) {
        let destinationViewController = MyWalletVC()
        destinationViewController.isFromProfile = true
        let navigationController = UINavigationController(rootViewController: destinationViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: PackageInfoTableCell.self, kCellHeightKey: PackageInfoTableCell.height],
            [kCellIdentifierKey: kCellIdentifierActivityDetail, kCellNibNameKey: kCellIdentifierActivityDetail, kCellClassKey: BuyActivityCell.self, kCellHeightKey: BuyActivityCell.height],
            [kCellIdentifierKey: kBuyOfferTableCellIdentifire, kCellNibNameKey: kBuyOfferTableCellIdentifire, kCellClassKey: BuyOffersTableCell.self, kCellHeightKey: BuyOffersTableCell.height],
            [kCellIdentifierKey: kPackageOfferCellIdentifire, kCellNibNameKey: kPackageOfferCellIdentifire, kCellClassKey: PackageOfferTableCell.self, kCellHeightKey: PackageOfferTableCell.height]]
    }
    
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func getDetals(_ dealsId: String) {
        WhosinServices.getDealsDetail(dealsId: dealsId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.dealsModel = data
            self._loadData()
        }
    }
    
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
            _ = promoBaseModel?.metadata.first?.promoType
            _ = BuyPackgeVC.tmpCart.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
            let originalAmount = BuyPackgeVC.tmpCart.map { $0.originalPrice * $0.quantity }.reduce(0, +)
            let totalDiscount = promoBaseModel?.totalDiscount ?? 0
            let discountedTotal = Double(originalAmount) - totalDiscount

            let itemsDiscount = promoBaseModel?.itemsDiscount ?? 0
            let promoDiscount = promoBaseModel?.promoDiscount ?? 0
 
            // Update UI labels
            self._addedToCartValue.attributedText = String(format: "D%.2f", discountedTotal).applyingDirhamFont(defaultFont: _addedToCartValue.font)
            self._savingPriceLabel.attributedText = String(format: "D%.2f", totalDiscount).applyingDirhamFont(defaultFont: _addedToCartValue.font)
            self._appliedPromoTitle.attributedText = Utils.makePromoTitleText(discount: promoDiscount, promoCode: promo, defaultFont: _addedToCartValue.font, dirhamFont: FontBrand.dirhamText(size: 14))
            self._offerDiscountSavingText.attributedText = String(format: "D%.2f", itemsDiscount).applyingDirhamFont(defaultFont: _addedToCartValue.font)
            self._promoDiscountLabel.attributedText = String(format: "D%.2f", promoDiscount).applyingDirhamFont(defaultFont: _addedToCartValue.font)
            self._promoCodeDiscountedView.isHidden = false

            // Hide savings view if there is no discount
            self._savingsView.isHidden = (promoDiscount == 0 && itemsDiscount == 0 && itemsDiscount == 0 && promoDiscount == 0)
            if type == "offers" || type == "event"  {
                _loadOffersData()
            } else {
                _loadData()
            }
        }

    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleApplyPromoEvent(_ sender: CustomActivityButton) {
        _promocodeMetaData()
    }
    
    private func _promocodeMetaData() {
        let totalqty = BuyPackgeVC.tmpCart.map { $0.quantity }.reduce(0, +)
        
        guard totalqty > 0 else {
            alert(message: "select_items_to_purchase".localized())
            return
        }
        guard let promoCode = _promoCodeTextField.text, !promoCode.isEmpty else {
            alert(message: "enter_promo_code".localized())
            return
        }
        
        var metaData = [[String: Any]]()
        let _tmpCartData = BuyPackgeVC.tmpCart.filter { $0.quantity != 0 }
        
        _tmpCartData.forEach({
            if $0.type == "offer" {
                let item: [String: Any] = ["packageId" : $0.id, "amount": $0.originalPrice, "type": "package", "discount": $0.discount == 0 ? $0.discountValue : $0.discount, "qty": $0.quantity ]
                metaData.append(item)
            } else if $0.type == "deal" {
                let item: [String: Any] = ["amount": $0.originalPrice,"dealId": dealsId, "type": "deal", "discount": $0.discount == 0 ? $0.discountValue : $0.discount, "qty": $0.quantity ]
                metaData.append(item)
            } else if $0.type == "event" {
                let item: [String: Any] = ["amount": $0.originalPrice, "packageId": $0.packageId, "type": "package", "discount": $0.discount == 0 ? $0.discountValue : $0.discount, "qty": $0.quantity ]
                metaData.append(item)
            }
        })

        _applyPromoBtn.setTitle("", for: .normal)
        _applyPromoBtn.showActivity()
        applyPromoCode(metaData)
    }
    
    @IBAction func _handleRemovePromoEvent(_ sender: CustomActivityButton) {
        _removePromoCode()
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
        let amount = BuyPackgeVC.tmpCart.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        if amount > 0 {
            _addedToCartValue.attributedText = "D\(Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
            let totalAmount = BuyPackgeVC.tmpCart.map { $0.originalPrice * $0.quantity }.reduce(0, +)
            _savingPriceLabel.attributedText = "D\(totalAmount - Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
            _offerDiscountSavingText.attributedText = "D\(totalAmount - Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
            _savingsView.isHidden = (totalAmount - Int(amount)) == 0
            _offerDiscountedSavingView.isHidden = (totalAmount - Int(amount)) == 0
        }
        _promoCodeDiscountedView.isHidden = true
        promoBaseModel = nil
        if type == "offers" || type == "event" {
            _loadOffersData()
        } else {
            _loadData()
        }
    }
    
    @IBAction private func _handleCheckOutEvent(_ sender: UIButton) {
        
        if type == "activity" {
            if Utils.stringIsNullOrEmpty(_activityDate) {
                alert(message: "select_date".localized())
                return
            }
            
            if Utils.stringIsNullOrEmpty(_activityTime) {
                alert(message: "please_select_time".localized())
                return
            }
            
            if _activityItem == 0 {
                alert(message: "please_select_time".localized())
                return
            }
            
            guard let item = _activityItem, let date = _activityDate, let time = _activityTime, let model = _checkoutActivityModel else { return }
            if item > 0 {
                let dialogViewController = INIT_CONTROLLER_XIB(ActivityConfirmationAlertVC.self)
                dialogViewController.modalPresentationStyle = .overFullScreen
                dialogViewController.modalTransitionStyle = .crossDissolve
                dialogViewController.activityModel = model
                dialogViewController.itemCount = item
                dialogViewController.time = time
                dialogViewController.date = date
                dialogViewController.dataCallback = { [weak self] data in
                    guard let self = self else { return }
                    guard let activityModel = self._checkoutActivityModel else { return }
                    let date = Utils.stringToDate(date, format: kFormatDateDOB)
                    
                    var metaData = [[String: Any]]()
                    let price = (Int(activityModel._disocuntedPrice) ?? 0) * item
                    let tmpItem: [String: Any] = ["activityId": activityModel.id, "activityType": activityModel.time?.type ?? "", "date": Utils.dateToString(date, format: kFormatDate), "time": time, "reservedSeat": item, "price": price , "type": "activity" ]
                    metaData.append(tmpItem)
                    let amount = item * (Int(activityModel._disocuntedPrice) ?? 0)
                    let params: [String: Any] = ["amount" : amount, "currency": "aed", "metadata": metaData]
                    PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: amount < 10, purchaseType: .package) { result in
                        switch result {
                        case .success:
                            self.hideHUD()
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: .openPurchaseSuccessCard, object: nil)
                        case .cancelled:
                            self.hideHUD()
                        case .failure(let error):
                            self.hideHUD(error: error as NSError?)
                        }
                    }
                }
                present(dialogViewController, animated: true, completion: nil)
            }
            return
        }
            
        let floatAmount = BuyPackgeVC.tmpCart.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        let orignalPrice = BuyPackgeVC.tmpCart.map { $0.originalPrice * $0.quantity }.reduce(0, +)
        let amount: Float = round(floatAmount * 100) / 100
        let discotedTotal = Double(orignalPrice) - (promoBaseModel?.totalDiscount ?? 0)
        if amount == 0 {
            showToast("Please select items quantity to checkout")
            return
        }
        
        var metaData = [[String: Any]]()
        let _tmpCartData = BuyPackgeVC.tmpCart.filter { $0.quantity != 0 }
        _tmpCartData.forEach({
            if $0.type == "offer" {
                let item: [String: Any] = ["packageId" : $0.id, "price": ($0.floatDiscountedPrice * Float($0.quantity)), "qty": $0.quantity, "venueId": $0.venueId, "offerId": $0.offerId, "type": $0.type ]
                metaData.append(item)
            } else if $0.type == "deal" {
                let item: [String: Any] = ["price": ($0.floatDiscountedPrice * Float($0.quantity)), "qty": $0.quantity, "venueId": $0.venueId, "dealId": dealsId, "type": $0.type ]
                metaData.append(item)
            } else if $0.type == "event" {
                let item: [String: Any] = ["price": ($0.floatDiscountedPrice * Float($0.quantity)), "qty": $0.quantity,"venueId": $0.venueId, "packageId": $0.packageId, "eventId": $0.eventId, "type": $0.type ]
                metaData.append(item)
            }
        })

        let totalAmmount = amount - Float(discotedTotal)
        let params: [String: Any] = promoBaseModel == nil ?  ["totalAmount" : "\(Int(amount))" ,"amount" : "\(Int(amount))", "currency": "aed", "metadata": metaData] : ["amount" : "\(Int(discotedTotal))", "totalAmount" : "\(orignalPrice)", "currency": "aed", "metadata": metaData, "promoCode": _promoCodeTextField.text ?? "", "discount": totalAmmount]
        PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: (promoBaseModel == nil ? Double(amount) : discotedTotal) < 10, purchaseType: .package) { result in
            switch result {
            case .success:
                self.hideHUD()
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: .openPurchaseSuccessCard, object: nil)
            case .cancelled:
                self.hideHUD()
            case .failure(let error):
                self.hideHUD(error: error as NSError?)
            }
        }
        
    }
    
    @IBAction private func _handleAddToCartEvent(_ sender: UIButton) {
        let repo = CartRepository()

        if type == "activity" {
            if Utils.stringIsNullOrEmpty(_activityDate) {
                alert(message: "select_date".localized())
                return
            }
            
            if Utils.stringIsNullOrEmpty(_activityTime) {
                alert(message: "please_select_time".localized())
                return
            }
            
            if _activityItem == 0 {
                alert(message: "please_enter_quantity".localized())
                return
            }
            if let cartQty = repo.getCountById(id: _checkoutActivityModel?.id ?? kEmptyString).first?.quantity {
                _activityItem! += cartQty
            }
            guard let item = _activityItem, let date = _activityDate, let time = _activityTime, let model = _checkoutActivityModel else { return }
            if item > 0 {
                if let cartModel  = CartModel(model) {
                    cartModel.quantity = item
                    cartModel.activityDate = date
                    cartModel.activityTime = time
                    self.repo.addToCartItems(model: [cartModel]) { updated in
                        if updated {
                            self.showToast("Items added to cart")
                            NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
                            self.navigationController?.popViewController(animated: true)
                            self.callback?()
                        }
                    }
                }
            }
            return
        }
        
        let amount = BuyPackgeVC.tmpCart.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
        if amount == 0 {
            showToast("please_select_quantity_add_to_cart".localized())
            return
        }
        var showAlert = false
        let copiedItems: [CartModel] = BuyPackgeVC.tmpCart.map {
            if type == "deal" { $0.dealId = self.dealsId }
            if let cartQty = repo.getCountById(id: $0.id).first?.quantity {
                if ($0.quantity + cartQty) > $0.maxQty {
                    showAddQtyAlert(cartQty: cartQty, qty: $0.maxQty - cartQty)
                    showAlert = true
                } else {
                    $0.quantity += cartQty
                }
            }
            if showAlert {
                return $0
            } else {
                return CartModel(cartModel: $0, qty: $0.quantity, dealId: self.dealsId)!
            }

        }
        
        if !showAlert {
            self.repo.addToCartItems(model: copiedItems) { updated in
                if updated {
                    if let firstItem = copiedItems.first {
                         LOGMANAGER.logTicketEvent(.addToCart, id: firstItem.id, name: firstItem.title, price: Double(firstItem.originalPrice), currency: APPSESSION.userDetail?.currency ?? "AED")
                    }
                    self.showToast("Items added to cart")
                    NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                    self.callback?()
                }
            }
        }
    }
    
    private func showAddQtyAlert(cartQty: Int, qty: Int, showAlert: Bool = false) {
        if qty == 0 {
            alert(title: kAppName, message: LANGMANAGER.localizedString(forKey: "already_in_cart_you_can_add_more", arguments: ["value": "\(cartQty)"]))
            return
        }
        alert(title: kAppName, message: LANGMANAGER.localizedString(forKey: "already_in_cart_you_can_add_more", arguments: ["value": "\(cartQty)"]))
        return
    }
    
    @IBAction private func _handleCartIconEvent(_ sender: UIButton) {
        sender.heroID = String(describing: MyCartVC.self)
        let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
        controller.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BuyPackgeVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PackageInfoTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? VoucharsModel, let venueModel = dealsModel?.venueModel {
                cell.setupData(object, venueModel: venueModel, promoModel: promoBaseModel)
            } else if let object = cellDict?[kCellObjectDataKey] as? DealsModel {
                cell.setupDealsData(object, promoModel: promoBaseModel)
            }
        }
        else if let cell = cell as? BuyActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(object) { (data, error) in
                self._checkoutActivityModel = object
                self._activityDate = data?["date"]  as? String
                self._activityTime = data?["time"] as? String
                self._activityItem = data?["qty"] as? Int
                self._valueView.isHidden = false
                guard let item = self._activityItem else { return }
                self._addedToCartValue.attributedText = "D\(item * (Int(object._disocuntedPrice) ?? 0))".applyingDirhamFont(defaultFont: self._addedToCartValue.font)
                let savings = (object.price * item) - (item * (Int(object._disocuntedPrice) ?? 0))
                self._savingsView.isHidden = savings == 0
                self._savingPriceLabel.attributedText = "D\(savings)".applyingDirhamFont(defaultFont: self._addedToCartValue.font)
                self._offerDiscountSavingText.attributedText = "D\(savings)".applyingDirhamFont(defaultFont: self._addedToCartValue.font)
            }
        }
        else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
        else if let cell = cell as? BuyOffersTableCell {
            if type == "event" {
                guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
                cell.setupEventData(object)
            } else {
                guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
                cell.timingModel = timingModel
                cell.setupData(object)
            }
        }
        else if let cell = cell as? PackageOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PackageModel else { return }
            if type == "event" {
                var venue: VenueDetailModel = VenueDetailModel()
                if let venueDetail = eventModel?.venueDetail {
                    venue = venueDetail
                } else if let venueDetail = Utils.getModelFromId(model: APPSETTING.venueModel, id: eventModel?.venue ?? kEmptyString) {
                    venue = venueDetail
                } else if let venuDetail = self.venue {
                    venue = venuDetail
                }
                cell.setupEventData(object, event: eventModel, venueModel: venue, promoModel: promoBaseModel)
                cell.isEvent = true
            } else {
                if venue != nil {
                    cell.setupData(object, venueModel: venue, promoModel: promoBaseModel)
                } else {
                    cell.setupData(object, venueModel: offerModel?.venue, promoModel: promoBaseModel)
                }
            }
        }
    }
    
}

extension BuyPackgeVC: UITextFieldDelegate {
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
                    let amount = BuyPackgeVC.tmpCart.map { $0.floatDiscountedPrice * Float($0.quantity) }.reduce(0, +)
                    if amount > 0 {
                        _addedToCartValue.attributedText = "D\(Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
                        let totalAmount = BuyPackgeVC.tmpCart.map { $0.originalPrice * $0.quantity }.reduce(0, +)
                        _savingPriceLabel.attributedText = "D\(totalAmount - Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
                        _offerDiscountSavingText.attributedText = "D\(totalAmount - Int(amount))".applyingDirhamFont(defaultFont: _addedToCartValue.font)
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
