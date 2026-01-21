import UIKit
import IQKeyboardManagerSwift
import PanModal
import Hero
import ExpandableLabel

protocol UpdateUsersDelegate {
    func updateUsers(_ data: OutingListModel)
}

class InviteBottomSheet: BaseViewController {
    
    @IBOutlet weak var _offerTitleView: CustomOfferTitleView!
    @IBOutlet weak var _offerView: UIStackView!
    @IBOutlet weak var _selectOfferView: UIView!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    var delegate: UpdateUsersDelegate?
    @IBOutlet weak var _doneButton: UIButton!
    @IBOutlet weak var _inviteButton: UIButton!
    @IBOutlet weak var _inviteBtn: GradientView!
    @IBOutlet weak var _doneBtn: GradientView!
    @IBOutlet weak var _dateAndTimeTxt: UILabel!
    @IBOutlet weak var _dateBtn: UIButton!
    @IBOutlet private weak var _countLabel: UILabel!
    @IBOutlet private weak var _extraGuest: UILabel!
//    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _slideActionButton: SlideToActionButton!
    @IBOutlet private weak var _invitationText: UITextField!
    @IBOutlet weak var _offerImage: UIImageView!
    @IBOutlet weak var _offerTIme: UILabel!
    @IBOutlet weak var _offerDays: UILabel!
    @IBOutlet weak var _offerStartDate: UILabel!
    @IBOutlet weak var _offerEndDate: UILabel!
    @IBOutlet weak var _offerTitle: UILabel!
    @IBOutlet weak var _offerDesc: ExpandableLabel!
    @IBOutlet weak var _selectOfferButton: CustomActivityButton!
    public var venueModel: VenueDetailModel?
    public var outingModel: OutingListModel?
    public var _selectedOffer: OffersModel?
    private var stepperValue: Int = 0
    private var _logoHeroId: String = kEmptyString
    private var _startTime: String = kEmptyString
    private var _endTime: String = kEmptyString
    private var _date: String = kEmptyString
    private let kCellIdentifierShareWith = String(describing: SharedUserNoMarginCell.self)
    public var userIds: [String] = []
    public var selectedContacts: [UserDetailModel] = []
    private var _offerList: [OffersModel] = []

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(self._changeSelectedOffer))
        self._offerView.addGestureRecognizer(tapGesture)
        if outingModel != nil {
            setupEditUi()
        } else {
            setupUi()
        }
        _selectOfferButton.isUserInteractionEnabled = false
        _getOfferList()
    }

    private func _getOfferList() {
        self._selectOfferButton.showActivity()
        WhosinServices.getVenueOffers(venueId: Utils.stringIsNullOrEmpty(venueModel?.id) ? outingModel?.venueId ?? kEmptyString : venueModel?.id ?? kEmptyString, day: "all", page: 1) { [weak self] container, error in
            guard let self = self else { return }
            self._selectOfferButton.hideActivity()
            guard let data = container?.data else { return }
            self._offerList = data
            self._updateOfferButton()

        }
    }
    
    private func _updateOfferButton() {
        if _offerList.isEmpty {
            _selectOfferButton.backgroundColor = ColorBrand.white.withAlphaComponent(0.15)
            _selectOfferButton.setTitleColor(ColorBrand.white.withAlphaComponent(0.30), for: .normal)
            _selectOfferButton.isUserInteractionEnabled = false
        } else {
            _selectOfferButton.backgroundColor = ColorBrand.brandPink
            _selectOfferButton.setTitleColor(ColorBrand.white, for: .normal)
            _selectOfferButton.isUserInteractionEnabled = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _createOuting(title: String, venueId: String, date: String, startTime: String, endTime: String,  extraGuest: String, invitedUser: [String]) {
        showHUD()
        var params: [String: Any] = ["title": title,"venueId": venueId,"date": date,"extraGuest": extraGuest,"startTime": startTime,"endTime": endTime,"invitedUser": invitedUser ]
        if _selectedOffer != nil { params["offerId"] = _selectedOffer?.id ?? kEmptyString }
        WhosinServices.requestCreateOuting(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            self.showSuccessMessage("Outing Created Successfully.", subtitle: kEmptyString)
            DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                self.dismiss(animated: true) {
                    let vc = INIT_CONTROLLER_XIB(ProfileVC.self)
                    let controller = NavigationController(rootViewController: vc)
                    controller.modalPresentationStyle = .fullScreen
                    vc._selectedtype = "My Plan"
                    vc.selectedIndexType = 1
                    Utils.presentViewController(controller)
                }
                 NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            }
        }
    }
    
    private func _updateOuting(outingId: String, title: String, venueId: String, date: String, startTime: String, endTime: String,  extraGuest: String, invitedUser: [String]) {
        let params: [String: Any] = ["outingId": outingId, "title": title,"venueId": venueId,"date": date,"extraGuest": extraGuest,"startTime": startTime,"endTime": endTime,"invitedUser": invitedUser ]
        showHUD()
        WhosinServices.requestUpdateOuting(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            self.showError(error)
            guard let data = container else { return }
            self.showSuccessMessage("Outing Updated Successfully.", subtitle: kEmptyString)
            DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                self.dismiss(animated: true)
                if let model = data.data {
                    self.delegate?.updateUsers(model)
                }
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            }
        }
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
     override func setupUi() {
         _doneBtn.isHidden = true
         _inviteBtn.isHidden = false
         _invitationText.delegate = self
         if let venueModel = venueModel {
             _venueInfoView.setupData(venue: venueModel)
         }
         _setupCollectionView()
         if let model = _selectedOffer, _selectedOffer != nil {
             _offerView.isUserInteractionEnabled = false
             _setOfferData(model)
         }
    }
    
    func setupEditUi() {
        _doneBtn.isHidden = false
        _inviteBtn.isHidden = true
        guard let venue = outingModel?.venue else { return }
        if let model = _selectedOffer, _selectedOffer != nil {
            _offerView.isUserInteractionEnabled = false
            _setOfferData(model)
        }
        venueModel = venue
        _venueInfoView.setupData(venue: venue)
        _invitationText.text = outingModel?.title
        _countLabel.text = "\(outingModel?.extraGuest ?? 0)"
        stepperValue = outingModel?.extraGuest ?? 0
        outingModel?.invitedUser.forEach({ model in
            userIds.append(model.id)
            if model.id != APPSESSION.userDetail?.id {
                selectedContacts.append(model)
            }
        })
        _dateAndTimeTxt.text = "\(outingModel?.date ?? "" ) (\(outingModel?.startTime ?? "") - \(outingModel?.endTime ?? ""))"
        _date = outingModel?.date ?? kEmptyString
        _startTime = outingModel?.startTime ?? kEmptyString
        _endTime = outingModel?.endTime ?? kEmptyString
        _invitationText.delegate = self
       _setupCollectionView()
   }
    
    private func _setupCollectionView() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 10,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_following"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _loadData()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.append([
            kCellIdentifierKey: kCellIdentifierShareWith,
            kCellTagKey: kCellIdentifierShareWith,
            kCellObjectDataKey: true,
            kCellClassKey: SharedUserNoMarginCell.self,
            kCellHeightKey: SharedUserNoMarginCell.height
        ])

        if !selectedContacts.isEmpty {
            selectedContacts.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierShareWith,
                    kCellTagKey: kCellIdentifierShareWith,
                    kCellObjectDataKey: contact,
                    kCellClassKey: SharedUserNoMarginCell.self,
                    kCellHeightKey: SharedUserNoMarginCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)

    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SharedUserNoMarginCell.self), kCellNibNameKey: String(describing: SharedUserNoMarginCell.self), kCellClassKey: SharedUserNoMarginCell.self, kCellHeightKey: SharedUserNoMarginCell.height]]
    }
    
    @objc func _changeSelectedOffer(sender: UITapGestureRecognizer) {
        _openOffersBottomSheet()
    }
 
    private func updateLabel() {
        _countLabel.text = "\(stepperValue)"
    }

    private func _updateDate(date: Date?, time: TimePeriod) {
        let dates = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
        let apiDate = Utils.dateToStringWithTimezone(date, format: kFormatDate)
        _date = "\(apiDate)"
        _startTime = time.startTime
        _endTime = time.endTime
        _dateAndTimeTxt.text = "\(dates) (\(time.startTime) - \(time.endTime))"
    }
    
    private func _openOffersBottomSheet() {
        self.view.endEditing(true)
        let presentedViewController = INIT_CONTROLLER_XIB(ClaimOfferListBottomSheet.self)
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.brunchList = _offerList
        presentedViewController.delegate = self
        presentedViewController.isFromInvite = true
        present(presentedViewController, animated: true, completion: nil)
    }
    
    private func _setOfferData(_ model: OffersModel) {
        _selectOfferView.isHidden = true
        _date = kEmptyString
        _dateAndTimeTxt.text = "select date and time"
        _selectedOffer = model
        _offerView.isHidden = false
        _offerImage.loadWebImage(model.image)
        _offerTIme.text = model.timeSloat
        _offerDays.text = model.days
        _offerStartDate.text = model.startDate?.display
        _offerEndDate.text = model.endDate?.display
        _offerTitleView.setupData(model: model)
        _offerTitle.text = model.title
        _offerDesc.text = model.descriptions
    }
    
    private func setExpandableLbl() {
        _offerDesc.isUserInteractionEnabled = false
        _offerDesc.delegate = self
        _offerDesc.shouldCollapse = true
        _offerDesc.numberOfLines = 2
        _offerDesc.ellipsis = NSAttributedString(string: "....")
        _offerDesc.collapsedAttributedLink = NSAttributedString(string: " more ", attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
    }


    @IBAction private func _handleminusEvent(_ sender: UIButton) {
        if stepperValue != 0 { stepperValue -= 1 }
        updateLabel()
    }
    
    @IBAction private func _handlePlusEvent(_ sender: UIButton) {
        stepperValue += 1
        updateLabel()
    }
    
    @IBAction private func _handleDateAndTimePickerEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.date = nil
        controller.offerModel = _selectedOffer
        controller.venueModel = venueModel
        controller.selectedDate = Utils.stringToDate(outingModel?.date, format: kFormatDate)
        controller.selectedTimeSlot = "\(outingModel?.startTime ?? "") - \(outingModel?.endTime ?? "")"
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            self._updateDate(date: date, time: time)
        }
        presentAsPanModal(controller: controller)

    }
    

    @IBAction private func _handleInviteEvent(_ sender: UIButton) {
        
        if Utils.stringIsNullOrEmpty(_invitationText.text) {
            alert(title: kAppName, message: "please write invitation text.")
            return
        }
        
        if Utils.stringIsNullOrEmpty(_dateAndTimeTxt.text) {
            alert(title: kAppName, message: "please select date and time.")
            return
        }
        
        if Utils.stringIsNullOrEmpty(_date) {
            alert(title: kAppName, message: "select_date".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_startTime) {
            alert(title: kAppName, message: "please_select_time".localized())
            return
        }

        if Utils.stringIsNullOrEmpty(_endTime) {
            alert(title: kAppName, message: "please_select_time".localized())
            return
        }

        if userIds.isEmpty {
            alert(title: kAppName, message: "please select friends.")
            return
        }
        
        _createOuting(title: _invitationText.text ?? "", venueId: venueModel?.id ?? "", date: _date, startTime: _startTime, endTime: _endTime, extraGuest: _extraGuest.text ?? "", invitedUser: userIds)
    }
    
    @IBAction private func _handleDoneEvent(_ sender: UIButton) {
        guard let userDetail = APPSESSION.userDetail else { return }
        userIds.append(userDetail.id)
        
        
        if Utils.stringIsNullOrEmpty(_invitationText.text) {
            alert(title: kAppName, message: "please write invitation text.")
            return
        }
        
        if Utils.stringIsNullOrEmpty(_dateAndTimeTxt.text) {
            alert(title: kAppName, message: "please select date and time.")
            return
        }
        
        if Utils.stringIsNullOrEmpty(_date) {
            alert(title: kAppName, message: "select_date".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_startTime) {
            alert(title: kAppName, message: "please_select_time".localized())
            return
        }

        if Utils.stringIsNullOrEmpty(_endTime) {
            alert(title: kAppName, message: "please_select_time".localized())
            return
        }
        
        if userIds.isEmpty {
            alert(title: kAppName, message: "please select friends.")
            return
        }

        _updateOuting(outingId: outingModel?.id ?? "", title: _invitationText.text ?? "", venueId: outingModel?.venue?.id ?? "", date: _date, startTime: _startTime, endTime: _endTime, extraGuest: _extraGuest.text ?? "", invitedUser: userIds)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func _handleSelectOffers(_ sender: UIButton) {
        _openOffersBottomSheet()
    }
    
}

extension InviteBottomSheet: GetSelectedOfferDelegate {
    func didSelectedOffer(_ model: OffersModel) {
        _setOfferData(model)
    }
}

extension InviteBottomSheet: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SharedUserNoMarginCell {
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                cell.setupContactData(data: object)
            } else {
                cell.setupContactData(islastIndex: true)
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let index = indexPath.row
        let cell = cell as? SharedUserNoMarginCell
        if index == 0 {
            let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            presentedViewController.onShareButtonTapped = { [weak self] selectedContacts in
                self?.selectedContacts.removeAll()
                self?.userIds.removeAll()
                let sharedContactIds = selectedContacts.map { $0.id }
                self?.selectedContacts = selectedContacts
                self?.userIds = sharedContactIds
                self?._loadData()
            }
            presentedViewController.sharedContactId = selectedContacts.map { $0.id }
            presentedViewController.isFromCreateBucket = true
            presentedViewController.modalPresentationStyle = .overFullScreen
            present(presentedViewController, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 60, height: SharedUserNoMarginCell.height)
    }
    
}

extension InviteBottomSheet: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension InviteBottomSheet: PanModalPresentable {
        
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.3)
    }
    
    var isHapticFeedbackEnabled: Bool {
        return true
    }
    
    var allowsTapToDismiss: Bool {
        return true
    }
    
    var allowsDragToDismiss: Bool {
        return true
    }
    
    public var showDragIndicator: Bool {
        return false
    }
    
    func panModalWillDismiss() {
        
    }
}

extension InviteBottomSheet:  ExpandableLabelDelegate {

    func willExpandLabel(_ label: ExpandableLabel) {
    }

    func didExpandLabel(_ label: ExpandableLabel) {
        _offerDesc.superview?.setNeedsLayout()
        _offerDesc.superview?.layoutIfNeeded()
    }

    func willCollapseLabel(_ label: ExpandableLabel) {
    }

    func didCollapseLabel(_ label: ExpandableLabel) {
        _offerDesc.superview?.setNeedsLayout()
        _offerDesc.superview?.layoutIfNeeded()
    }
}
