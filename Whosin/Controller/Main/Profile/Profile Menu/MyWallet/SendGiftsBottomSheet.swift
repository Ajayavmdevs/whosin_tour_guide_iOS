import UIKit
import MHLoadingButton

class SendGiftsBottomSheet: PanBaseViewController {
            
    @IBOutlet private weak var _labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _maxQty: UILabel!
    @IBOutlet private weak var _selectedUserDetail: UILabel!
    @IBOutlet private weak var _selectedUserName: UILabel!
    @IBOutlet private weak var _selectedUserImage: UIImageView!
    @IBOutlet private weak var _addUserBtnView: UIView!
    @IBOutlet private weak var _selectedUserDetailView: UIView!
    @IBOutlet private weak var _venueLogo: UIImageView!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _validateDate: UILabel!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _packageDec: UILabel!
    @IBOutlet private weak var _packageCount: UILabel!
    @IBOutlet private weak var _packagePrice: UILabel!
    @IBOutlet private weak var _giftMessageTextView: UITextView!
    private let kCellIdentifier = String(describing: ShareWithCollectionCell.self)
    public var vouchersList: VouchersListModel?
    public var package: PackageModel?
    private var stepperValue: Int = 0
    private var stepperMaxValue: Int = 0
    var _menu: [String] = ["1"]
    private var selectedContacts: UserDetailModel?
    private var userIds: String = kEmptyString
    public var isActivity: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    public func _setupUi() {
        _giftMessageTextView.delegate = self
        setupData()
        _loadData()
    }
        
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    private func setupData() {
        if isActivity {
            let provider = vouchersList?.activity?.provider
            _ = vouchersList?.items.first(where: { $0.id == vouchersList?.id ?? kEmptyString })
            _venueLogo.loadWebImage(provider?.logo ?? "")
            stepperMaxValue = vouchersList?.items.reduce(0) { $0 + $1.remainingQty } ?? 0
            _maxQty.text = "Remaining quantity: \(stepperMaxValue)"
            _venueName.text = provider?.name
            _venueAddress.text = provider?.address
            _packageName.text = vouchersList?.activity?.name
            _packageDec.text = vouchersList?.activity?.descriptions
            _widthConstraint.constant = 0
            _labelLeadingConstraint.constant = 0
            _validateDate.text = Utils.dateToString(vouchersList?.activity?.endDate, format: kFormatDateLocal)
        } else if vouchersList?.type == "deal" {
            let venue = vouchersList?.deal?.venueModel
            let item = vouchersList?.items.first(where: { $0.id == vouchersList?.deal?.id } )
            stepperMaxValue = item?.remainingQty ?? 0
            _maxQty.text = "Remaining quantity: \(stepperMaxValue)"
            _venueLogo.loadWebImage(venue?.logo ?? "")
            _venueName.text = venue?.name
            _venueAddress.text = venue?.address
            _packageName.text = vouchersList?.deal?.title
            _packageDec.text = vouchersList?.deal?.descriptions
            let discount = "\(vouchersList?.deal?.discountValue ?? 0)"
            if discount.hasSuffix("%") {
                _packagePrice.text = "\(discount)"
            } else {
                _packagePrice.text = "\(discount)%"
            }
            _widthConstraint.constant = _packagePrice.text == "0%" ? 0 : 44
            let date = Utils.stringToDate(vouchersList?.deal?.endDate, format: kFormatDate)
            _validateDate.text = Utils.dateToString(date, format: kFormatDateLocal)
        } else {
            let item = vouchersList?.items.first(where: {$0.packageId == package?.id })
            stepperMaxValue = item?.remainingQty ?? 0
            _maxQty.text = "Remaining quantity: \(stepperMaxValue)"
            if vouchersList?.type == "offer" {
                if let venue = vouchersList?.offer {
                    _venueLogo.loadWebImage(venue.image, name: venue.title)
                    _venueName.text = venue.title
                    _venueAddress.text = venue.descriptions
                }
                if let pacakgeInfo = package {
                    _packageName.text = pacakgeInfo.title
                    _packageDec.text = pacakgeInfo.descriptions
                    if pacakgeInfo.discount.hasSuffix("%") {
                        _packagePrice.text = "\(pacakgeInfo.discount)"
                    } else {
                        _packagePrice.text = "\(pacakgeInfo.discount)%"
                    }
                }

                _widthConstraint.constant = _packagePrice.text == "0%" ? 0 : 44
                let date = Utils.stringToDate(vouchersList?.offer?.endTime, format: kFormatDateStandard)
                _validateDate.text = Utils.dateToString(date, format: kFormatDateLocal)
            } else if vouchersList?.type == "event" {
                let venue = vouchersList?.event?.eventsOrganizer
                let item = vouchersList?.items.first(where: {$0.packageId == package?.id })
                stepperMaxValue = item?.remainingQty ?? 0
                _maxQty.text = "Remaining quantity: \(stepperMaxValue)"
                _venueLogo.loadWebImage(venue?.logo ?? "")
                _venueName.text = venue?.name
                _venueAddress.text = venue?.descriptions
                if let pacakgeInfo = package {
                    _packageName.text = pacakgeInfo.title
                    _packageDec.text = pacakgeInfo.descriptions
                    let discount = "\(pacakgeInfo.discounts)"
                    if discount.hasSuffix("%") {
                        _packagePrice.text = "\(discount)"
                    } else {
                        _packagePrice.text = "\(discount)%"
                    }
                }
                _widthConstraint.constant = _packagePrice.text == "0%" ? 0 : 44
                let date = Utils.stringToDate(vouchersList?.event?.eventTime, format: kStanderdDate)
                _validateDate.text = Utils.dateToString(date, format: kFormatDateLocal)
            }
        }
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: ShareWithCollectionCell.self), kCellClassKey: ShareWithCollectionCell.self, kCellHeightKey: ShareWithCollectionCell.height] ]
    }

    private func _loadData() {
        if selectedContacts == nil {
            _selectedUserDetailView.isHidden = true
            _addUserBtnView.isHidden = false
        } else {
            _selectedUserDetailView.isHidden = false
            _addUserBtnView.isHidden = true
            _selectedUserImage.loadWebImage(selectedContacts?.image ?? kEmptyString, name: selectedContacts?.fullName ?? kEmptyString)
            _selectedUserName.text = selectedContacts?.fullName
            _selectedUserDetail.text = selectedContacts?.email.isEmpty ?? true
            ? selectedContacts?.phone : selectedContacts?.email
        }
    }
    
    private func updateLabel() {
        _packageCount.text = "\(stepperValue)"
    }
    
    private func _openContactBottomSheet() {
        let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
        presentedViewController.onSelectUserButtonTapped = { [weak self] selectedContacts in
            self?.selectedContacts = nil
            let sharedContactIds = selectedContacts.id
            self?.selectedContacts = selectedContacts
            self?.userIds = sharedContactIds
            self?._loadData()
        }
        presentedViewController.sharedContactId = [userIds]
        presentedViewController.isFromSendGift = true
        presentedViewController.modalPresentationStyle = .overFullScreen
        self.present(presentedViewController, animated: true)
    }
    
    // --------------------------------------
    // MARK: Service method
    // --------------------------------------
    
    private func requestSendGift() {
        showHUD()
        guard let voucherList = vouchersList else { return }
        let activityDate = voucherList.items.first(where: { $0.id == voucherList.activity?.id })?.date ?? kEmptyString
        let activityTime = voucherList.items.first(where: { $0.id == voucherList.activity?.id })?.time ?? kEmptyString
        let giftMessage = _giftMessageTextView.text == "Write gift message" ? kEmptyString : _giftMessageTextView.text.trim
        WhosinServices.sendPackageGifts(type: voucherList.type, friendId: userIds, packageId: package?.id ?? "", dealId: voucherList.dealId, activityId: voucherList.activityId, eventId: "", date: activityDate, time: activityTime, qty: stepperValue, giftMessage: giftMessage) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            if container?.code == 1 {
                self.view.makeToast(container?.message)
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil, userInfo: nil)
                DISPATCH_ASYNC_MAIN_AFTER(0.6) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction private func _handleIncreaseEvent(_ sender: UIButton) {
        if stepperValue < stepperMaxValue {
            stepperValue += 1
            updateLabel()
        }
    }
    
    @IBAction private func _handleDecreaseEvent(_ sender: UIButton) {
        if stepperValue != 0 {
            stepperValue -= 1
        }
        updateLabel()
    }
    
    @IBAction private func _handleSendEvnet(_ sender: UIButton) {
        if stepperValue == 0 && stepperValue <= stepperMaxValue {
            alert(title: kAppName, message: "Please select valid quantity")
            return
        }
        
        if Utils.stringIsNullOrEmpty(userIds) {
            alert(title: kAppName, message: "please select friend to send gift")
            return
        }
        requestSendGift()
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction private func _handleSelectUserEvent(_ sender: Any) {
        self.view.endEditing(true)
        _openContactBottomSheet()
    }
    
    @IBAction private func _handleEditSelectedUser(_ sender: UIButton) {
        self.view.endEditing(true)
        _openContactBottomSheet()
    }
    
}

extension SendGiftsBottomSheet: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension SendGiftsBottomSheet: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write gift message" {
            textView.textColor = ColorBrand.white
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write gift message"
            textView.textColor = ColorBrand.brandLightGray
        }
    }
}
