import UIKit

class MyActivityTableCell: UITableViewCell {
    
    @IBOutlet private weak var _expiredView: UIView!
    @IBOutlet private weak var _menuBtn: UIButton!
    @IBOutlet private weak var _typeBadge: UIView!
    @IBOutlet private weak var _typeTxt: UILabel!
    @IBOutlet private weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet weak var _giftByView: UIView!
    @IBOutlet private weak var _redeemView: UIView!
    @IBOutlet private weak var _sendGiftView: UIView!
    @IBOutlet private weak var _stackView: UIStackView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _giftByUserImg: UIImageView!
    @IBOutlet weak var _giftByUserName: UILabel!
    @IBOutlet private weak var _itemLabel: UILabel!
    @IBOutlet private weak var _priceLabel: UILabel!
    @IBOutlet private weak var _discription: UILabel!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet weak var _giftByText: UILabel!
    @IBOutlet weak var _giftMessageLbl: UILabel!
    private var _voucherListModel: VouchersListModel?
    

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
        _setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: private
    // --------------------------------------
    
    private func _setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._coverImage.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
            self._typeBadge.roundCorners(corners: [.topLeft, .bottomRight], radius: 8)
        }
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: VouchersListModel, _ isFromHistory: Bool = false, isFromGift: Bool = false) {
        _giftByUserImg.sd_cancelCurrentImageLoad()
        _giftByUserImg.image = nil
        _giftMessageLbl.isHidden = true
        _voucherListModel = model
            if isFromGift {
                _menuBtn.isHidden = true
                let sumOfQty = model.items.first?.qty
                _itemLabel.text =  "\(sumOfQty ?? 0)"
                _priceLabel.isHidden = true
                _giftMessageLbl.isHidden = true
            } else if isFromHistory {
                _menuBtn.isHidden = false
                let sumOfQty = model.items.first?.usedQty
                _stackView.isHidden = true
                _itemLabel.text = "\(sumOfQty ?? 0)"
                _priceLabel.isHidden = false
                _giftMessageLbl.isHidden = true
            } else {
                _menuBtn.isHidden = true
                let sumOfQty = model.items.first?.remainingQty
                _itemLabel.text = "\(sumOfQty ?? 0)"
                _priceLabel.isHidden = false
            }
        let item = model.items.toArrayDetached(ofType: VoucherItems.self)
        var giftMessages = ""
        item.first?.giftMessage.forEach({ String in
            giftMessages.append("• " + String + "\n")
        })

        if !giftMessages.isEmpty {
            _giftMessageLbl.text = "message".localized() + ":" + "\(giftMessages)"
            _giftMessageLbl.isHidden = true
        } else {
            _giftMessageLbl.isHidden = true
        }
        _sendGiftView.isHidden = true//isFromGift
        _giftByView.isHidden = true//!isFromGift
        guard let activityModel = model.activity else { return }
        _coverImage.loadWebImage(activityModel.cover)
        _packageName.text = activityModel.name
        let provider = activityModel.provider
        _venueInfoView.setupProviderData(venue: provider ?? ProviderModel())
        _discription.text = activityModel.descriptions
        if isFromGift, let user = model.giftBy {
            setGiftView(user.fullName, image: user.image)
            _giftByText.text = "gift_by".localized()
        } else if isFromHistory, let user = model.giftTo  {
            setGiftView(user.fullName, image: user.image)
            _giftByText.text = "gift_to".localized()
        }
        let items = model.items.first(where: { $0.id == model.id })
        _priceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(items?.price ?? 0)".withCurrencyFont(13, false)
        if let startTime = items?.time.components(separatedBy: "-").first, let time = Utils.stringToDate(startTime, format: kFormatDateTimeUS) {
            guard let date = items?._activityDate else { return }
            let isActivityExpired = Utils.isDateExpired(dateString: "\(items?.date ?? kEmptyString) \(Utils.dateToString(time, format: "HH:mm"))", format: "yyyy-MM-dd HH:mm")
            _sendGiftView.isHidden = true//isFromGift ? true : isActivityExpired
            _expiredView.isHidden = true//isFromGift ? true : !isActivityExpired
            _dateLabel.text = "date".localized() + "\(date.display)"
            _timeLabel.text = "time".localized() + "\(Utils.dateToString(time, format: "HH:mm"))"
        }
    }
    
    private func setGiftView(_ name: String, image: String) {
        _giftByUserImg.loadWebImage(image, name: name)
        _giftByUserName.text = name
        _sendGiftView.isHidden = true
        _giftByView.isHidden = true
    }
    
    private func requestDeletehistory( ids: [String]) {
            self.parentBaseController?.showHUD()
            WhosinServices.deleteOrder(ids: ids) { [weak self] container, error in
                guard let self = self else { return }
                self.parentBaseController?.hideHUD(error: error)
                guard let data = container else { return}
                self.parentBaseController?.showToast(data.message)
                NotificationCenter.default.post(name: .reloadHistory, object: nil)
            }
            
        }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func handleMenuEvent( sender: UIButton) {
        guard let id = self._voucherListModel?.orderId else { return }
            let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { action in
                self.parentBaseController?.confirmAlert(message: "are_you_sure_want_to_delete_history".localized(),okHandler: { okAction in
                    self.requestDeletehistory(ids: [id])
                }, noHandler:  { action in
                })
            }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
            parentViewController?.present(alert, animated: true, completion:{
                alert.view.superview?.subviews[0].isUserInteractionEnabled = true
                alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })

        }
    
    @IBAction private func _handleSendGiftEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(SendGiftsBottomSheet.self)
        presentedViewController.vouchersList = _voucherListModel
        presentedViewController.isActivity = true
        parentViewController?.presentAsPanModal(controller: presentedViewController)

    }
    
    @IBAction private func _handleRedeemEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(RedeemVoucherVC.self)
        presentedViewController.vouchersList = _voucherListModel
        parentViewController?.presentAsPanModal(controller: presentedViewController)

    }
}

