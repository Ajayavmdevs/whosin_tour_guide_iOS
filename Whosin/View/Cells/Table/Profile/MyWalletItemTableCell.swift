import UIKit
import StripeCore

class MyWalletItemTableCell: UITableViewCell {
    
    @IBOutlet private weak var _giftbyView: UIView!
    @IBOutlet private weak var _discountBgView: GradientView!
    @IBOutlet private weak var _discountWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _totalPrice: UILabel!
    @IBOutlet private weak var _price: UILabel!
    @IBOutlet private weak var _validDateLabel: UILabel!
    @IBOutlet private weak var _count: UILabel!
    @IBOutlet private weak var _packageDetail: UILabel!
    @IBOutlet private weak var _packgeName: UILabel!
    @IBOutlet private weak var _packageDiscount: UILabel!
    @IBOutlet private weak var _addressLabel: UILabel!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _logoImage: UIImageView!
    @IBOutlet weak var _sendGiftView: GradientView!
    private var _voucherListModel: VouchersListModel?
    @IBOutlet weak var _btnsStack: UIStackView!
    
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupData(_ model: VouchersListModel, _ isFromHistory: Bool = false, isFromGift: Bool = false) {
        _btnsStack.isHidden = isFromHistory
        _voucherListModel = model
        _giftbyView.isHidden = true
        let date = Utils.stringToDate(model.deal?.endDate, format: kFormatDate)
        _validDateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
        let venue = APPSETTING.venueModel?.filter({ $0.id == model.deal?.venueId  }).first
        _logoImage.loadWebImage(venue?.logo ?? "",placeholder: UIImage(named: "icon_user_avatar_default"))
        _nameLabel.text = venue?.name
        _addressLabel.text = venue?.address
        let discountValue = "\(model.deal?.discountValue ?? 0)"
        if discountValue == "0" || discountValue == "0%" {
            _discountBgView.isHidden = true
            _discountWidthConstraint.constant = 0
        } else {
            _discountBgView.isHidden = false
            _discountWidthConstraint.constant = 44
        }
        if discountValue.hasSuffix("%") && discountValue != nil  {
            _packageDiscount.text = "\(discountValue )"
        } else {
            _packageDiscount.text = "\(discountValue )%"
        }

        _packgeName.text = model.deal?.title
        _packageDetail.text = model.deal?.descriptions
        _count.text =  isFromGift ? "\(model.qty)" : isFromHistory ? "\(model.usedQty)" : "\(model.remainingQty)"
        if let discointprice = model.deal?.discountedPrice {
            let price = model.qty * discointprice
            _totalPrice.text = "D\(price)"
        }
    }
    
    public func setupEventData(_ model: VouchersListModel, _ isFromHistory: Bool = false, isFromGift: Bool = false) {
        _btnsStack.isHidden = isFromHistory
        _voucherListModel = model
        _giftbyView.isHidden = true
        let date = Utils.stringToDate(model.event?.eventTime, format: kStanderdDate)
        _validDateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
        let venue = model.event?.eventsOrganizer
        _logoImage.loadWebImage(venue?.logo ?? "",placeholder: UIImage(named: "icon_user_avatar_default"))
        _nameLabel.text = venue?.name
        _addressLabel.text = venue?.address
        let discountValue = "\(model.event?.package?.discounts ?? 0)"
        if discountValue == "0" || discountValue == "0%" {
            _discountBgView.isHidden = true
            _discountWidthConstraint.constant = 0
        } else {
            _discountBgView.isHidden = false
            _discountWidthConstraint.constant = 44
        }
        if discountValue.hasSuffix("%") {
            _packageDiscount.text = "\(discountValue )"
        } else {
            _packageDiscount.text = "\(discountValue )%"
        }
        _packgeName.text = model.event?.package?.title ?? ""
        _packageDetail.text = model.event?.package?.descriptions ?? ""
        _count.text =  isFromGift ? "\(model.qty)" : isFromHistory ? "\(model.usedQty)" : "\(model.remainingQty)"
        if let discointprice = Utils.discountPercent(originalPrice:  Double(model.event?.package?.amount ?? 0), discountedPrice:  Double(model.event?.package?.discounts ?? 0)) {
            let price = model.qty * discointprice
            _totalPrice.text = "D\(price)"
        }
    }
    
    public func setupOfferData(_ model: VouchersListModel, _ isFromHistory: Bool = false, isFromGift: Bool = false) {
        _btnsStack.isHidden = isFromHistory
        _voucherListModel = model
        _giftbyView.isHidden = true
        let date = Utils.stringToDate(model.offer?.endTime, format: kFormatDateStandard)
        _validDateLabel.text = Utils.dateToString(date, format: kFormatDateLocal)
        _logoImage.loadWebImage(model.offer?.image  ?? "",placeholder: UIImage(named: "icon_user_avatar_default"))
        _nameLabel.text = model.offer?.title
        _addressLabel.text = model.offer?.descriptions
        let pacakgeInfo = model.offer?.packageModel
        _packageDiscount.text = pacakgeInfo?.discount
        if pacakgeInfo?.discount == "0" ||  pacakgeInfo?.discount == "0%" {
            _discountBgView.isHidden = true
            _discountWidthConstraint.constant = 0
        } else {
            _discountBgView.isHidden = false
            _discountWidthConstraint.constant = 44
        }
        if pacakgeInfo?.discount.hasSuffix("%") ?? true && pacakgeInfo?.discount != nil {
            _packageDiscount.text = "\(pacakgeInfo?.discount ?? "")"
        } else {
            _packageDiscount.text = "\(pacakgeInfo?.discount ?? "")%"
        }
        _packgeName.text = pacakgeInfo?.title
        _packageDetail.text = pacakgeInfo?.descriptions
        _count.text =  isFromGift ? "\(model.qty)" : isFromHistory ? "\(model.usedQty)" : "\(model.remainingQty)"
        let price = model.qty * (pacakgeInfo?.amount ?? 0)
        _totalPrice.text = "D\(price)"
    }
    
    @IBAction private func _handleRedeemEvent(_ sender: UIButton) {
        if _voucherListModel?.type == "deal" {
            let presentedViewController = INIT_CONTROLLER_XIB(RedeemVoucherVC.self)
//            presentedViewController.modalPresentationStyle = .custom
//            presentedViewController.transitioningDelegate = self
            presentedViewController.vouchersList = _voucherListModel
            parentViewController?.presentAsPanModal(controller: presentedViewController)
        } else if _voucherListModel?.type == "offer" {
            let presentedViewController = INIT_CONTROLLER_XIB(RedeemOffersVC.self)
            presentedViewController.modalPresentationStyle = .overFullScreen
            presentedViewController.transitioningDelegate = self
            presentedViewController.voucherModel = _voucherListModel
            parentViewController?.present(presentedViewController, animated: true)
        } else if _voucherListModel?.type == "event" {
            let presentedViewController = INIT_CONTROLLER_XIB(RedeemOffersVC.self)
            presentedViewController.modalPresentationStyle = .overFullScreen
            presentedViewController.transitioningDelegate = self
            presentedViewController.voucherModel = _voucherListModel
            parentViewController?.present(presentedViewController, animated: true)
        }
    }
    
    @IBAction private func _handleSendEvent(_ sender: UIButton) {
//        let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
//        presentedViewController.modalPresentationStyle = .custom
//        presentedViewController.transitioningDelegate = self
//        presentedViewController.vouchersList = _voucherListModel
//        parentViewController?.presentAsPanModal(controller: presentedViewController)
        
    }
}

extension MyWalletItemTableCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

