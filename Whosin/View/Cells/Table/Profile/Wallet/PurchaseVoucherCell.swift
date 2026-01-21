import UIKit
import ExpandableLabel

class PurchaseVoucherCell: UITableViewCell {
    
    @IBOutlet private weak var _expiredView: UIView!
    @IBOutlet private weak var _menuBtn: UIButton!
    @IBOutlet private weak var _giftTxt: UILabel!
    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _typeBadge: UIView!
    @IBOutlet private weak var _typeLabel: UILabel!
    @IBOutlet private weak var _giftBtnView: UIView!
    @IBOutlet private weak var _redeemBtnView: UIView!
    @IBOutlet private weak var _discountBgView: GradientView!
    @IBOutlet private weak var _discountWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _packagePrice: UILabel!
    @IBOutlet private weak var _packageQty: UILabel!
    @IBOutlet private weak var _packageDisc: UILabel!
    @IBOutlet private weak var _packgeName: UILabel!
    @IBOutlet private weak var _packageDiscount: UILabel!
    @IBOutlet weak var _dealPackageView: UIStackView!
    @IBOutlet private weak var _validDateLabel: UILabel!
    @IBOutlet private weak var _giftbyView: UIView!
    @IBOutlet private weak var _giftByUserImg: UIImageView!
    @IBOutlet private weak var _giftByUserName: UILabel!
    @IBOutlet private weak var _btnsStack: UIStackView!
    @IBOutlet private weak var _offersTitleLabel: UILabel!
    @IBOutlet private weak var _offersCoverImage: UIImageView!
    @IBOutlet private weak var _offersTimeLAbel: UILabel!
    @IBOutlet private weak var _offersDayLabel: UILabel!
    @IBOutlet private weak var _offersDescLabel: ExpandableLabel!
    @IBOutlet private weak var _imageHight: NSLayoutConstraint!
    @IBOutlet private weak var _startDate: UILabel!
    @IBOutlet private weak var _endDate: UILabel!
    @IBOutlet private weak var _giftMessageLbl: UILabel!
    @IBOutlet private weak var _offersStack: UIStackView!
    @IBOutlet weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _timeSlotButton: UIButton!
    @IBOutlet private weak var _timeStackView: UIStackView!
    @IBOutlet private weak var _redeemButton: UIButton!
    private var _offersModel: OffersModel?
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString
    private var _voucherListModel: VouchersListModel?
    private var _venueModel: VenueDetailModel?
    private let kCellIdentifier = String(describing: PurchasedPackageCell.self)
    public var packages: [PackageModel] = []
    public var isFrom: String = kEmptyString
    private var orderId:String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension  }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._typeBadge.roundCorners(corners: [.topLeft, .bottomRight], radius: 8)
        }
        guard let _voucherListModel = _voucherListModel else { return }
        packages.removeAll()
        packages = filterPackages(_voucherListModel)
        if _voucherListModel.type == "offer" {
            _dealPackageView.isHidden = true
            _offersStack.isHidden = false
            _offersModel = _voucherListModel.offer
            setOffer(_voucherListModel)
            let item = _voucherListModel.items.toArrayDetached(ofType: VoucherItems.self)
            loadPackages(item)
        } else if _voucherListModel.type == "deal" {
            setDeals(_voucherListModel)
            _dealPackageView.isHidden = false
            _offersStack.isHidden = true
        } else if _voucherListModel.type == "event" {
            _dealPackageView.isHidden = true
            _offersStack.isHidden = false
            setEvents(_voucherListModel)
            let item = _voucherListModel.items.toArrayDetached(ofType: VoucherItems.self)
            loadPackages(item)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._typeBadge.roundCorners(corners: [.topLeft, .bottomRight], radius: 8)
        }
        _setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        setExpandableLbl()
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 5,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setExpandableLbl() {
        _offersDescLabel.isUserInteractionEnabled = false
        _offersDescLabel.delegate = self
        _offersDescLabel.shouldCollapse = true
        _offersDescLabel.numberOfLines = 2
        _offersDescLabel.ellipsis = NSAttributedString(string: ".....")
        _offersDescLabel.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
    }

    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: PurchasedPackageCell.self), kCellClassKey: PurchasedPackageCell.self, kCellHeightKey: PurchasedPackageCell.height] ]
    }

    @IBAction private func _handleTimeEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }

    private func _openTimeDialogue() {
        let customview = TimeDailogView()
        customview._timeDetail = _offersModel?.evnetTimeSlotForNoDate(venueModel: _offersModel?.venue) ?? []
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        alertController.view.addSubview(customview)
        let cancelAction = UIAlertAction(title: "close".localized(), style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        alertController.addAction(cancelAction)
        DISPATCH_ASYNC_MAIN {
            self.parentViewController?.present(alertController, animated: true, completion:{
                alertController.view.superview?.isUserInteractionEnabled = true
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
        }
        (self.superview as? CustomTableView)?.update()
    }

    private func _loadvenueAndOfferData(_ type: String) {
        _venueModel = nil
        _endDate.isHidden = false
        _timeSlotButton.isHidden = true
        if type == "offer" {
            guard let venue = _offersModel?.venue else { return }
            _offersTitleLabel.superview?.isHidden = false
            _offersDescLabel.superview?.isHidden = false
            _venueModel = venue
            _venueId = venue.id
            _venueInfoView.setupData(venue: venue, isAllowClick: true)
            _offersCoverImage.loadWebImage(_offersModel?.image ?? "")
            _offersDescLabel.text = _offersModel?.descriptions
            _offersTimeLAbel.text = _offersModel?.timeSloat ?? kEmptyString
            _offersDayLabel.text = _offersModel?.days
            _offersTitleLabel.text = _offersModel?.title
            if let startDate = _offersModel?.startDate, let endDate = _offersModel?.endDate {
                _startDate.text = "and_from".localized() + startDate.display
                _endDate.text = "and_till".localized() + endDate.display
                _offersTimeLAbel.text = _offersModel?.timeSloat ?? kEmptyString
                _endDate.isHidden = false
                _timeSlotButton.isHidden = true
            } else {
                _endDate.isHidden = true
                _startDate.text = "and_from".localized() + "ongoing".localized()
                _offersTimeLAbel.text = _offersModel?.getEventTime(venueModel: venue)
                _timeSlotButton.isHidden = false
                let timeTap = UITapGestureRecognizer(target: self, action: #selector(timeEvent))
                _timeStackView.addGestureRecognizer(timeTap)
            }
            _expiredView.isHidden = _offersModel?._isExpired == true ? false : true
            _redeemBtnView.isHidden = _offersModel?._isExpired == true ? true : false
            _giftBtnView.isHidden = true//_offersModel?._isExpired == true ? true : false
        }
        else if type == "deal" {
            let deal = _voucherListModel?.deal
            let discountValue = "\(deal?.discountValue ?? 0)"
            if discountValue == "0" || discountValue == "0%" {
                _discountBgView.isHidden = true
                _discountWidthConstraint.constant = 0
            } else {
                _discountBgView.isHidden = false
                _discountWidthConstraint.constant = 44
            }
            if discountValue.hasSuffix("%") && !discountValue.isEmpty  {
                _packageDiscount.text = "\(discountValue )"
            } else {
                _packageDiscount.text = "\(discountValue )%"
            }
            _packgeName.text = deal?.title
            _packageDisc.text = deal?.descriptions
            if let venue = _voucherListModel?.deal?.venueModel {
                _venueModel = venue
                _venueInfoView.setupData(venue: venue, isAllowClick: true)
            }
            _offersCoverImage.loadWebImage(deal?.image ?? "")
            _offersDescLabel.text = deal?.descriptions
            _offersTimeLAbel.text = deal?._timeSlot
            _offersDayLabel.text = deal?.days
            _offersTitleLabel.text = deal?.title
            _startDate.text = "and_from".localized() + (deal?._startDate ?? "")
            _endDate.text = "and_till".localized() + (deal?._endtDate ?? "")
            _offersTitleLabel.superview?.isHidden = true
            _offersDescLabel.superview?.isHidden = true
            _expiredView.isHidden = deal?._isExpired == true ? false : true
            _redeemBtnView.isHidden = deal?._isExpired == true ? true : false
            _giftBtnView.isHidden = true//deal?._isExpired == true ? true : false
        }
        else if type == "event" {
            _offersTitleLabel.superview?.isHidden = false
            _offersDescLabel.superview?.isHidden = false
            let event = _voucherListModel?.event
            if let venue = _voucherListModel?.event?.venueDetail {
                _venueModel = venue
                _venueInfoView.setupData(venue: venue)
            }
            _offersCoverImage.loadWebImage(event?.image ?? "")
            _offersDescLabel.text = event?.descriptions
            _offersTimeLAbel.text = event?.eventTimeSlot
            _offersDayLabel.text = event?._eventDay ?? ""
            _offersTitleLabel.text = event?.title
            _startDate.text = "reservation_date".localized() + (event?._reservationTime ?? "")
            _endDate.text = "event_date".localized() + (event?._eventDate ?? "")
            _redeemButton.setTitle("use_ticket".localized(), for: .normal)
        }
    }
    
    private func setDeals(_ model: VouchersListModel, isFrom: String = kEmptyString) {
        _menuBtn.isHidden = isFrom != "history"
        _loadvenueAndOfferData(model.type)
        _giftMessageLbl.isHidden = true
        var sumOfQty: Int = 0
        if isFrom == "gift" {
            sumOfQty = model.items.reduce(0) { $0 + $1.remainingQty }
            _packagePrice.isHidden = true
            _giftMessageLbl.isHidden = true
        } else if isFrom == "history" {
            sumOfQty = model.items.reduce(0) { $0 + $1.usedQty }
            _packagePrice.isHidden = false
            _giftMessageLbl.isHidden = true
        } else {
            sumOfQty = model.items.reduce(0) { $0 + $1.remainingQty }
            _packagePrice.isHidden = false
        }
        let item = model.items.toArrayDetached(ofType: VoucherItems.self)
        var giftMessages = ""
        item.first?.giftMessage.forEach({ String in
            giftMessages.append("• " + String + "\n")
        })
        if !giftMessages.isEmpty {
            _giftMessageLbl.text = "message".localized() + "\(giftMessages)"
            _giftMessageLbl.isHidden = true
        } else {
            _giftMessageLbl.isHidden = true
        }
        _setbtnsHideShow(model)
        _packageQty.text = "\(sumOfQty)"
        _voucherListModel = model
        let date = Utils.stringToDate(model.deal?.endDate, format: kFormatDate)
        _validDateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
        if let discointprice = model.deal?.discountedPrice {
            let price = sumOfQty * discointprice
            _packagePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(price)".withCurrencyFont(13, false)
        }
    }
    
    private func setEvents(_ model: VouchersListModel, isFrom: String = kEmptyString) {
        _menuBtn.isHidden = isFrom != "history"
        _loadvenueAndOfferData(model.type)
        _voucherListModel = model
        _setbtnsHideShow(model)
        _giftMessageLbl.isHidden = true
        if isFrom == "gift" {
            _giftbyView.isHidden = true
            _giftMessageLbl.isHidden = true
        } else if isFrom == "history" {
            _giftbyView.isHidden = true
            _giftMessageLbl.isHidden = true
        } else {
            _giftbyView.isHidden = true
        }
        let item = model.items.toArrayDetached(ofType: VoucherItems.self)
        _setGiftMessage(voucherList: item)
        let date = Utils.stringToDate(model.event?.eventTime, format: kStanderdDate)
        _validDateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
    }
    
    private func setOffer(_ model: VouchersListModel, isFrom: String = kEmptyString) {
        _menuBtn.isHidden = isFrom != "history"
        _loadvenueAndOfferData(model.type)
        _setbtnsHideShow(model)
        _voucherListModel = model
        let date = Utils.stringToDate(model.offer?.endTime, format: kFormatDateStandard)
        _validDateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
        _giftMessageLbl.isHidden = true
        if isFrom == "gift" {
            _giftMessageLbl.isHidden = true
        } else if isFrom == "history" {
            _giftMessageLbl.isHidden = true
        } else {
            _giftMessageLbl.isHidden = true
        }
        let item = model.items.toArrayDetached(ofType: VoucherItems.self)
        _setGiftMessage(voucherList: item)
    }

    private func _setGiftMessage(voucherList: [VoucherItems]) {
        var giftMessage = ""

        voucherList.forEach { voucher in
            let gift = voucher.giftMessage.joined(separator: "\n ")
            if !gift.isEmpty {
                giftMessage = giftMessage.appending("• " + gift)
                giftMessage = giftMessage.appending("\n")
            }
        }
        if !giftMessage.isEmpty {
            _giftMessageLbl.text = "message".localized() + "\(giftMessage)"
            _giftMessageLbl.isHidden = true
        } else {
            _giftMessageLbl.isHidden = true
        }
    }

    private func loadPackages(_ voucherItem: [VoucherItems]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        voucherItem.forEach { item in
            if packages.contains(where: { $0.id == item.packageId }) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: item.id,
                    kCellObjectDataKey: item.detached(),
                    kCellClassKey: PurchasedPackageCell.self,
                    kCellHeightKey: PurchasedPackageCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        _collectionViewHieghtConstraint.constant = PurchasedPackageCell.height * CGFloat(cellData.count)
        _offersStack.isHidden = voucherItem.isEmpty
        _collectionView.reload()
    }
    
    private func _setbtnsHideShow(_ model: VouchersListModel) {
        if isFrom == "gift" {
            if let user = model.giftBy {
                setGiftView(user.fullName, image: user.image)
            }
            _btnsStack.isHidden = false
        } else if isFrom == "history" {
            if let user = model.giftTo {
                _giftTxt.text = "gift_to".localized()
                setGiftView(user.fullName, image: user.image)
            } else if let user = model.giftBy {
                _giftTxt.text = "gift_by".localized()
                setGiftView(user.fullName, image: user.image)
            } else {
                _giftbyView.isHidden = true
            }
            _btnsStack.isHidden = true
        } else {
            _giftbyView.isHidden = true
            _btnsStack.isHidden = false
        }
    }
    
    private func setGiftView(_ name: String, image: String) {
        _giftByUserImg.loadWebImage(image, name: name)
        _giftByUserName.text = name
        _giftbyView.isHidden = true
        _giftBtnView.isHidden = true
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: VouchersListModel,isFrom: String = kEmptyString) {
        orderId = model.orderId
        _menuBtn.isHidden = isFrom != "history"
        _typeLabel.text = model.type
        _voucherListModel = model
        self.isFrom = isFrom
        packages.removeAll()
        _giftByUserImg.sd_cancelCurrentImageLoad()
        _giftByUserImg.image = nil
        packages = filterPackages(model)
        if model.type == "offer" {
            _dealPackageView.isHidden = true
            _offersStack.isHidden = false
            _offersModel = model.offer
            setOffer(model, isFrom: isFrom)
            let item = model.items.toArrayDetached(ofType: VoucherItems.self)
            loadPackages(item)
        } else if model.type == "deal" {
            setDeals(model, isFrom: isFrom)
            _dealPackageView.isHidden = false
            _offersStack.isHidden = true
        } else if model.type == "event" {
            _dealPackageView.isHidden = true
            _offersStack.isHidden = false
            setEvents(model, isFrom: isFrom)
            let item = model.items.toArrayDetached(ofType: VoucherItems.self)
            loadPackages(item)
        }
    }
    
    func filterPackages(_ voucherListModel: VouchersListModel) -> [PackageModel] {
        var model: [PackageModel] = []
        model.removeAll()
        if voucherListModel.type == "offer" {
            if let offerPackages = voucherListModel.offer?.packages {
                let packageIDs = Set(offerPackages.map { $0.id } )
                let itemIDs = Set(voucherListModel.items.map { $0.id } )
                let commonIDs = packageIDs.intersection(itemIDs)
                let filteredPackages = offerPackages.filter { package in
                    return commonIDs.contains(package.id)
                }
                model.append(contentsOf: filteredPackages)
                return model.sorted { $0._createdAt < $1._createdAt }
            } else { return model }
        } else if voucherListModel.type == "event" {
            if let eventPackages = voucherListModel.event?.packages {
                let packageIDs = Set(eventPackages.map { $0.id } )
                let itemIDs = Set(voucherListModel.items.map { $0.packageId } )
                let commonIDs = packageIDs.intersection(itemIDs)
                let filteredPackages = eventPackages.filter { package in
                    return commonIDs.contains(package.id)
                }
                model.append(contentsOf: filteredPackages)
                return model.sorted { $0._createdAt < $1._createdAt }
            } else { return model }
        } else {
            return model
        }
    }
    
    private func _requestDeletehistory(_ ids: [String]) {
        self.parentBaseController?.showHUD()
        WhosinServices.deleteOrder(ids: ids) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return}
            self.parentBaseController?.showToast(data.message)
            NotificationCenter.default.post(name: .reloadHistory, object: nil)
        }
        
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
        
    @objc func timeEvent() {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openTimeDialogue()
    }
    
    @IBAction private func _handleMenuEvent(_ sender: UIButton) {
        
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: "are_you_sure_want_to_delete_history".localized(),okHandler: { okAction in
                self._requestDeletehistory([self.orderId])
            }, noHandler:  { action in
            })
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })

    }
    
    @IBAction private func _handleSendEvent(_ sender: UIButton) {
        if _voucherListModel?.type == "offer" {
            if packages.count > 1 {
                let controller = INIT_CONTROLLER_XIB(BottomSheetVC.self)
                controller.isFromSendGift = true
                controller.packages = packages
                controller.itemModel = _voucherListModel?.items.toArrayDetached(ofType: VoucherItems.self) ?? []
                controller.delegate = self
                parentViewController?.presentAsPanModal(controller: controller)
            } else {
                let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
                presentedViewController.vouchersList = _voucherListModel
                presentedViewController.package = packages.first
                parentViewController?.presentAsPanModal(controller: presentedViewController)

            }
        } else if _voucherListModel?.type == "event" {
            if packages.count > 1 {
                let controller = INIT_CONTROLLER_XIB(BottomSheetVC.self)
                controller.isFromSendGift = true
                controller.packages = packages
                controller.itemModel = _voucherListModel?.items.toArrayDetached(ofType: VoucherItems.self) ?? []
                controller.delegate = self
                parentViewController?.presentAsPanModal(controller: controller)
            } else {
                let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
                presentedViewController.vouchersList = _voucherListModel
                presentedViewController.package = packages.first
                parentViewController?.presentAsPanModal(controller: presentedViewController)
            }
        } else if _voucherListModel?.type == "deal" {
            let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
            presentedViewController.vouchersList = _voucherListModel
            presentedViewController.package = packages.first
            parentViewController?.presentAsPanModal(controller: presentedViewController)
        }
    }
    
    @IBAction private func _handleRedeemEvent(_ sender: UIButton) {
        if _voucherListModel?.type == "deal" {
            let presentedViewController = INIT_CONTROLLER_XIB(RedeemVoucherVC.self)
            presentedViewController.vouchersList = _voucherListModel
            parentViewController?.presentAsPanModal(controller: presentedViewController)
        } else if _voucherListModel?.type == "offer" {
            if packages.count > 1 {
                let controller = INIT_CONTROLLER_XIB(BottomSheetVC.self)
                controller.packages = packages
                controller.itemModel = _voucherListModel?.items.toArrayDetached(ofType: VoucherItems.self) ?? []
                controller.delegate = self
                parentViewController?.presentAsPanModal(controller: controller)
            } else {
                let presentedViewController = INIT_CONTROLLER_XIB(RedeemOffersVC.self)
                presentedViewController.modalPresentationStyle = .overFullScreen
                presentedViewController.transitioningDelegate = self
                presentedViewController.voucherModel = _voucherListModel
                presentedViewController.package = packages.first
                presentedViewController.callback = { [weak self] message in
                    guard let self = self else { return }
                    let dialogViewController = INIT_CONTROLLER_XIB(RedeemSuccessAlertVC.self)
                    dialogViewController.modalPresentationStyle = .overFullScreen
                    dialogViewController.modalTransitionStyle = .crossDissolve
                    dialogViewController.descStr = message
                    self.parentBaseController?.present(dialogViewController, animated: true, completion: nil)
                }
                parentViewController?.present(presentedViewController, animated: true)
            }
        } else if _voucherListModel?.type == "event" {
            let presentedViewController = INIT_CONTROLLER_XIB(EventTicketVC.self)
            presentedViewController.modalPresentationStyle = .overFullScreen
            presentedViewController.voucherListModel = _voucherListModel
            parentViewController?.present(presentedViewController, animated: true)

//            if packages.count > 1 {
//                let controller = INIT_CONTROLLER_XIB(BottomSheetVC.self)
//                controller.packages = packages
//                controller.itemModel = _voucherListModel?.items.toArrayDetached(ofType: VoucherItems.self) ?? []
//                controller.delegate = self
//                parentViewController?.presentAsPanModal(controller: controller)
//            } else {
//                let presentedViewController = INIT_CONTROLLER_XIB(RedeemOffersVC.self)
//                presentedViewController.modalPresentationStyle = .overFullScreen
//                presentedViewController.transitioningDelegate = self
//                presentedViewController.voucherModel = _voucherListModel                
//                presentedViewController.package = packages.first
//                presentedViewController.callback = { [weak self] message in
//                    guard let self = self else { return }
//                    let dialogViewController = INIT_CONTROLLER_XIB(RedeemSuccessAlertVC.self)
//                    dialogViewController.modalPresentationStyle = .overFullScreen
//                    dialogViewController.modalTransitionStyle = .crossDissolve
//                    dialogViewController.descStr = message
//                    self.parentBaseController?.present(dialogViewController, animated: true, completion: nil)
//                }
//                parentViewController?.present(presentedViewController, animated: true)
//            }
        }
    }

}

extension PurchaseVoucherCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension PurchaseVoucherCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}

extension PurchaseVoucherCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PurchasedPackageCell ,let object = cellDict?[kCellObjectDataKey] as? VoucherItems, let _voucherListModel = _voucherListModel else { return }
        guard let packages = filterPackages(_voucherListModel).first(where: { $0.id == object.packageId }) else { return }
        cell.setupData(packages, item: object, isFrom: isFrom)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: PurchasedPackageCell.height)
    }
}

extension PurchaseVoucherCell: DidSelectPackageDelegate {
    
    func didSelectPackage(_ package: PackageModel) {
        if _voucherListModel?.type == "offer" {
            let presentedViewController = INIT_CONTROLLER_XIB(RedeemOffersVC.self)
            presentedViewController.modalPresentationStyle = .overFullScreen
            presentedViewController.transitioningDelegate = self
            presentedViewController.voucherModel = _voucherListModel
            presentedViewController.package = package
            presentedViewController.callback = { [weak self] message in
                guard let self = self else { return }
                let dialogViewController = INIT_CONTROLLER_XIB(RedeemSuccessAlertVC.self)
                dialogViewController.modalPresentationStyle = .overFullScreen
                dialogViewController.modalTransitionStyle = .crossDissolve
                dialogViewController.descStr = message
                self.parentBaseController?.present(dialogViewController, animated: true, completion: nil)
            }
            parentBaseController?.present(presentedViewController, animated: true)
        } else if _voucherListModel?.type == "event" {
            let presentedViewController = INIT_CONTROLLER_XIB(RedeemOffersVC.self)
            presentedViewController.modalPresentationStyle = .overFullScreen
            presentedViewController.transitioningDelegate = self
            presentedViewController.voucherModel = _voucherListModel
            presentedViewController.package = package
            presentedViewController.callback = { [weak self] message in
                guard let self = self else { return }
                let dialogViewController = INIT_CONTROLLER_XIB(RedeemSuccessAlertVC.self)
                dialogViewController.modalPresentationStyle = .overFullScreen
                dialogViewController.modalTransitionStyle = .crossDissolve
                dialogViewController.descStr = message
                self.parentBaseController?.present(dialogViewController, animated: true, completion: nil)
            }
            parentBaseController?.present(presentedViewController, animated: true)
        }
    }
    
    func didSelectSenfGift(_ package: PackageModel) {
        if _voucherListModel?.type == "offer" {
            let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
            presentedViewController.vouchersList = _voucherListModel
            presentedViewController.package = package
            parentBaseController?.presentAsPanModal(controller: presentedViewController)
        } else if _voucherListModel?.type == "event" {
            let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
            presentedViewController.vouchersList = _voucherListModel
            presentedViewController.package = package
            parentBaseController?.presentAsPanModal(controller: presentedViewController)
        }
    }
}

extension PurchaseVoucherCell:  ExpandableLabelDelegate {

    func willExpandLabel(_ label: ExpandableLabel) {
    }

    func didExpandLabel(_ label: ExpandableLabel) {
        _offersDescLabel.superview?.setNeedsLayout()
        _offersDescLabel.superview?.layoutIfNeeded()
    }

    func willCollapseLabel(_ label: ExpandableLabel) {
    }

    func didCollapseLabel(_ label: ExpandableLabel) {
        _offersDescLabel.superview?.setNeedsLayout()
        _offersDescLabel.superview?.layoutIfNeeded()
    }
}
