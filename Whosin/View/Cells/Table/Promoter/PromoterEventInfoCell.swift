import UIKit
import Lightbox
import AVFoundation
import ExpandableLabel

class PromoterEventInfoCell: UITableViewCell {
    
    @IBOutlet private weak var _venueBgView: UIView!
    @IBOutlet private weak var _customVenue: UIView!
    @IBOutlet private weak var _btnsStack: UIStackView!
    @IBOutlet private weak var _selectVenueBtn: CustomActivityButton!
    @IBOutlet private weak var _createBtn: CustomActivityButton!
    @IBOutlet private weak var _selectDateBtn: CustomActivityButton!
    @IBOutlet private weak var _selectTimeBtn: CustomActivityButton!
    @IBOutlet private weak var _dressCodeField: LeftSpaceTextField!
    @IBOutlet private weak var _informationTextView: CustomTextView!
    @IBOutlet weak var _offerImage: UIImageView!
    @IBOutlet weak var _offerTIme: UILabel!
    @IBOutlet weak var _offerDays: UILabel!
    @IBOutlet weak var _offerStartDate: UILabel!
    @IBOutlet weak var _offerEndDate: UILabel!
    @IBOutlet weak var _selectOfferButton: CustomActivityButton!
    @IBOutlet weak var _offerView: UIStackView!
    @IBOutlet weak var _selectOfferView: UIView!
    @IBOutlet weak var _offerTitleView: CustomOfferTitleView!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueTitle: UILabel!
    @IBOutlet weak var _venueSubtitle: UILabel!
    @IBOutlet weak var _editVenueImage: UIButton!
    @IBOutlet weak var _editDeleteButtonStack: UIStackView!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _gallaryView: UIView!
    private let kCellIdentifier = String(describing: VenueGalleryCollectionCell.self)
    private var _imageGallery: [String] = []
    public var _selectedOffer: OffersModel?
    public var updateCallBack: ((_ params: [String: Any]) -> Void)?
    private var venueListModel: [VenueDetailModel] = []
    private var params: [String: Any] = [:]
    private var _selectedVenue: VenueDetailModel?
    private var _offerList: [OffersModel] = []
    private var _selectedDate: Date? = nil
    private var _selectedTime: TimePeriod?
    private var _validDayList: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    private var isEditEvent: Bool = false
    private var _eventModel: PromoterEventsModel?
    private var isallDelete: Bool = false
    
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
        _setupCollectionView()
        _dressCodeField.delegate = self
        _informationTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(self._changeSelectedOffer))
        self._offerView.isUserInteractionEnabled = true
        self._offerView.addGestureRecognizer(tapGesture)
        _selectOfferView.isHidden = true
        _requestMyVenues()
    }
    
    private func _setupCollectionView() {
        let spacing = 10
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 10,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no data available",
                              emptyDataIconImage: UIImage(named: "empty_following"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: VenueGalleryCollectionCell.self, kCellHeightKey: VenueGalleryCollectionCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifier,
            kCellTagKey: true,
            kCellObjectDataKey: "icon_coverSquare",
            kCellClassKey: VenueGalleryCollectionCell.self,
            kCellHeightKey: VenueGalleryCollectionCell.height
        ])
        
        if !_imageGallery.isEmpty {
            _imageGallery.forEach { img in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: false,
                    kCellObjectDataKey: img,
                    kCellClassKey: VenueGalleryCollectionCell.self,
                    kCellHeightKey: VenueGalleryCollectionCell.height
                ])
            }
        }
        
        self.params["eventGallery"] = _imageGallery
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    public func _setupData(_ params: [String: Any], isEdit: Bool = false, model: PromoterEventsModel?) {
        self.params = params
        self.isEditEvent = isEdit
        self._eventModel = model
        if let type = params["venueType"] as? String, type == "venue" {
            _btnsStack.isHidden = true
            _venueBgView.isHidden = false
            let id = params["venueId"] as? String
            if isEdit {
                if let venue = venueListModel.first(where: {$0.id == id}) {
                    _venueImage.loadWebImage(venue.cover)
                    _venueTitle.text = venue.name
                    _venueSubtitle.text = venue.address
                    _selectedVenue = venue
                } else {
                    _venueImage.loadWebImage(model?.venue?.cover ?? kEmptyString)
                    _venueTitle.text = model?.venue?.name ?? kEmptyString
                    _venueSubtitle.text = model?.venue?.address ?? kEmptyString
                    _selectedVenue = model?.venue
                }
//                _editVenueImage.isHidden = false
                if let eventGallery = params["eventGallery"] as? [String], !eventGallery.isEmpty {
                    _imageGallery = eventGallery
                }
                _gallaryView.isHidden = false
                if _selectedOffer == nil  { _getOfferList() }
            } else {
                let venue = venueListModel.first(where: {$0.id == id})
                _venueImage.loadWebImage(venue?.cover ?? kEmptyString)
                _venueTitle.text = venue?.name ?? kEmptyString
                _venueSubtitle.text = venue?.address ?? kEmptyString
                
            }
            if let image = params["image"] as? String, !Utils.stringIsNullOrEmpty(image) {
                _venueImage.loadWebImage(image)
            }
        } else if let custom = params["customVenue"] as? [String: Any], let name = custom["name"] as? String, let address = custom["address"] as? String,let image = custom["image"] as? String {
            _btnsStack.isHidden = true
            _venueBgView.isHidden = false
            _venueImage.loadWebImage(image)
            _venueTitle.text = name
            _venueSubtitle.text = address
            if let eventGallery = params["eventGallery"] as? [String], !eventGallery.isEmpty {
                _imageGallery = eventGallery
            }
            _gallaryView.isHidden = false
        } else {
            _btnsStack.isHidden = false
            _venueBgView.isHidden = true
        }
        if let date = params["date"] as? String {
            _selectDateBtn.setTitle(Utils.dateToString(Utils.stringToDate(date, format: kFormatDate), format: kFormatEventDate))
        }
        if let from = params["startTime"] as? String, let till = params["endTime"] as? String {
            let time = "from".localized() + Utils.dateToString(Utils.stringToDate(from, format: kFormatDateTimeUS), format: kFormatDateHourMinuteAM) + " - " + "till".localized() + Utils.dateToString(Utils.stringToDate(till, format: kFormatDateTimeUS), format:kFormatDateHourMinuteAM )
            _selectTimeBtn.setTitle(time)
        }
        if let dressCode = params["dressCode"] as? String {
            _dressCodeField.text = dressCode
        }
        if let info = params["description"] as? String {
            _informationTextView.text = info
        }
        _editDeleteButtonStack.isHidden = isEdit && model?.status == "in-progress"
        checkImageGallery()
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _updateData() {
        self.updateCallBack?(params)
    }
    
    private func showTimePicker(title: String, minTime: Date? = nil, isStartDate: Bool = false, completion: @escaping (Date) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        
        datePicker.calendar.timeZone = .current
        datePicker.calendar.locale = .current
        datePicker.timeZone = .current
        datePicker.locale = Locale(identifier: "en_GB")
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        if let minDate = minTime {
            if isStartDate {
                datePicker.date = minDate
                datePicker.minimumDate = minDate
            } else {
                datePicker.date = minDate.addingTimeInterval(1 * 60 * 60)
                datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -1, to: minDate.addingTimeInterval(1 * 60 * 60))
            }
        }
        
        alertController.view.addSubview(datePicker)
        
        let okAction = UIAlertAction(title: "ok".localized(), style: .default) { _ in
            var selectedDate = datePicker.date
            
            if let minDate = minTime, !isStartDate {
                if selectedDate < minDate {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
                }
            }
            
            completion(selectedDate)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 10).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -10).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -100).isActive = true
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }


    private func _setOfferData(_ model: OffersModel) {
        
        _selectOfferView.isHidden = true
        _selectedOffer = model
        _offerView.isHidden = false
        _offerImage.loadWebImage(model.image)
        _offerTIme.text = model.timeSloat
        _offerDays.text = model.days
        _offerStartDate.text = model.startDate?.display
        _offerEndDate.text = model.endDate?.display
        _offerTitleView.setupData(model: model)
    }
    
    @objc func _changeSelectedOffer(sender: UITapGestureRecognizer) {
        _openOffersBottomSheet()
    }

    private func _openOffersBottomSheet() {
        self.endEditing(true)
        if isEditEvent && _eventModel?.status == "in-progress" {
            return
        }
        let presentedViewController = INIT_CONTROLLER_XIB(ClaimOfferListBottomSheet.self)
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.brunchList = _offerList
        presentedViewController.delegate = self
        presentedViewController.isFromInvite = true
        parentViewController?.present(presentedViewController, animated: true, completion: nil)
    }
    
    private func _selectVenue() {
        let presentedViewController = INIT_CONTROLLER_XIB(VenueListBottomSheet.self)
        presentedViewController.onShareButtonTapped = { [weak self] selectedVenue in
//            self?._editVenueImage.isHidden = false
            self?.params["venueId"] = selectedVenue.id
            self?.params["venueType"] = "venue"
            self?.params["image"] = selectedVenue.cover
            self?.params["customVenue"] =  ["name" : selectedVenue.name, "image": selectedVenue.slogo, "description": selectedVenue.descriptions, "address": selectedVenue.address]
            self?._selectOfferView.isHidden = false
            self?._getOfferList()
            self?._selectedOffer = nil
            self?._offerView.isHidden = true
            if selectedVenue != self?._selectedVenue {
                self?.params.removeValue(forKey: "startTime")
                self?.params.removeValue(forKey: "endTime")
                self?.params.removeValue(forKey: "date")
                self?._selectDateBtn.setTitle("select_date".localized())
                self?._selectTimeBtn.setTitle("select_start_and_end_time".localized())
                self?._selectedDate = nil
            }
            self?._validDayList = selectedVenue.timing.toArrayDetached(ofType: TimingModel.self).map{ $0.day }
            self?._selectedVenue = selectedVenue
            self?._gallaryView.isHidden = false
            self?._imageGallery.removeAll()
            self?._imageGallery.insert(selectedVenue.cover, at: 0)
            self?._loadData()
            self?._updateData()
        }
        presentedViewController.venueListModel = venueListModel
        presentedViewController.isPromoter = true
        presentedViewController.modalPresentationStyle = .overFullScreen
        parentViewController?.present(presentedViewController, animated: true)
    }
    
    private func _createCustom(_ isEdit: Bool) {
        let vc = INIT_CONTROLLER_XIB(CreateCustomEventBottomsheet.self)
        vc.params = self.params
        vc.isEdit = isEdit
        vc.customCallback = { params, lat, long in
            self.params["venueType"] = "custom"
            self.params["customVenue"] = params
            self.params["latitude"] = lat
            self.params["longitude"] = long
            self._editVenueImage.isHidden = true
            self._gallaryView.isHidden = false
            if let venueImage = params["image"] as? String  {
                self._imageGallery.insert(venueImage, at: 0)
            }
            self._loadData()
            self._updateData()
        }
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    private func _getOfferList() {
        self.parentBaseController?.showHUD()
        guard let id = params["venueId"] as? String else {
            _updateOfferButton()
            return
        }
        WhosinServices.getVenueOffers(venueId: id, day: "all", page: 1) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container?.data else { return }
            self._offerList = data
            self._updateOfferButton()
        }
    }
    
    private func _updateOfferButton() {
        let offerId = params["offerId"] as? String
        if let model = _offerList.first(where: { $0.id == offerId }) {
            _selectedOffer = model
            _setOfferData(model)
            _updateData()
        } else {
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
    }
    
    private func _requestMyVenues() {
        WhosinServices.getMyVenuesList { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.venueListModel = data
            if let type = params["venueType"] as? String, type == "venue" {
                let id = params["venueId"] as? String
                guard let venue = venueListModel.first(where: {$0.id == id}) else { return }
                _venueImage.loadWebImage(Utils.stringIsNullOrEmpty(self.params["image"] as? String) ? venue.cover : self.params["image"] as? String ?? kEmptyString)
                _venueTitle.text = venue.name
                _venueSubtitle.text = venue.address
            }
            self.checkImageGallery()
        }
    }
    
    private func checkImageGallery() {
        
        guard _imageGallery.isEmpty && !isallDelete else { return }
        if let venueType = params["venueType"] as? String, venueType == "venue" {
            let venueId = params["venueId"] as? String
            guard let venue = venueListModel.first(where: { $0.id == venueId }) else { return }
            if !_imageGallery.contains(venue.cover) {
                _imageGallery.insert(venue.cover, at: 0)
                _loadData()
            }
        } else if let customVenue = params["customVenue"] as? [String: Any],
                  let customImage = customVenue["image"] as? String {
            if !_imageGallery.contains(customImage) {
                _imageGallery.insert(customImage, at: 0)
                _loadData()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    @IBAction func _handleSelectOfferEvent(_ sender: Any) {
        _openOffersBottomSheet()
    }
    
    @IBAction private func _handleSelectVenueEvent(_ sender: CustomActivityButton) {
        endEditing(true)
        _selectVenue()
    }
    
    @IBAction private func _handleCreateCustomEvent(_ sender: CustomActivityButton) {
        _createCustom(false)
    }
    
    @IBAction private func _handleSelectDateEvent(_ sender: CustomActivityButton) {
        if isEditEvent && _eventModel?.status == "in-progress" {
            parentBaseController?.alert(title: kAppName, message: "cant_change_date_event_started".localized())
            return
        }
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.selectedDate = _selectedDate
        controller.venueModel = _selectedVenue
        controller.isCreateEvent = true
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            let dates = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
            self._selectedDate = date
            let apiDate = Utils.dateToStringWithTimezone(date, format: kFormatDate)
            self.params["date"] = apiDate
            self._updateData()
            self._selectDateBtn.setTitle(Utils.dateToString(Utils.stringToDate(dates, format: kFormatDateLocal), format: kFormatEventDate))
        }
        self.parentViewController?.presentAsPanModal(controller: controller)
    }
    
    @IBAction private func _handleSelectTimeEvent(_ sender: CustomActivityButton) {
        if isEditEvent && _eventModel?.status == "in-progress" {
            parentBaseController?.alert(title: kAppName, message: "cant_change_time_event_started".localized())
            return
        }
        var currentDate: Date? = nil
        if let date = params["date"] as? String {
            currentDate = Utils.stringToDate(date, format: kFormatDate)
            var currentDay = Utils.dateToStringWithTimezone(currentDate, format: kFormatDateDayShort).lowercased()
            if !_validDayList.contains(currentDay) {
                parentBaseController?.alert(message: "please_select_valid_date".localized())
                return
            }
            let now = Date()
            let calendar = Calendar.current
            if let currentDate = currentDate, calendar.isDate(currentDate, inSameDayAs: now) {
                showTimePicker(title: "select_start_time".localized(), minTime: now, isStartDate: true) { fromDate in
                    self.showTimePicker(title: "select_end_time".localized(), minTime: fromDate) { tillDate in
                        let time = "from".localized() + fromDate.time12HourWithAMPM + " - " + "till".localized() + tillDate.time12HourWithAMPM
                        self.params["startTime"] = fromDate.timeOnly
                        self.params["endTime"] = tillDate.timeOnly
                        self._updateData()
                        self._selectTimeBtn.setTitle(time)
                    }
                }
            } else {
                showTimePicker(title: "select_start_time".localized()) { fromDate in
                    self.showTimePicker(title: "select_end_time".localized(), minTime: fromDate) { tillDate in
                        let time = "from".localized() + fromDate.time12HourWithAMPM + " - " + "till".localized() + tillDate.time12HourWithAMPM
                        self.params["startTime"] = fromDate.timeOnly
                        self.params["endTime"] = tillDate.timeOnly
                        self._updateData()
                        self._selectTimeBtn.setTitle(time)
                    }
                }
            }
        } else {
            parentBaseController?.alert(message: "please_select_date_first".localized())
            return
        }
    }
    
    
    @IBAction func _handleEditEvent(_ sender: UIButton) {
        if let type = params["venueType"] as? String, type == "venue" {
            _selectVenue()
        } else {
            _createCustom(true)
        }
    }
    
    @IBAction func _handleEditVenueImageEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(ImageSelectBottomSheet.self)
        vc.galleryImages = _selectedVenue?.galleries ?? []
        vc.callback = { image in
            self.params["image"] = image
            self._venueImage.loadWebImage(image)
            self._updateData()
        }
        vc.modalPresentationStyle = .overFullScreen
        parentViewController?.present(vc, animated: true)

    }
    
    @IBAction func _handleDeleteEvent(_ sender: UIButton) {
        parentBaseController?.confirmAlert(message: "are_you_sure_want_to_remove_this_venue".localized(), okHandler: { action in
            if let type = self.params["venueType"] as? String, type == "venue" {
                self.params.removeValue(forKey: "venueId")
                self.params.removeValue(forKey: "customVenue")
                self._selectOfferView.isHidden = true
                self._offerView.isHidden = true
            } else {
                self.params.removeValue(forKey: "customVenue")
            }
            self.params.removeValue(forKey: "image")
            self.params.removeValue(forKey: "startTime")
            self.params.removeValue(forKey: "endTime")
            self.params.removeValue(forKey: "date")
            self._selectDateBtn.setTitle("select_date".localized())
            self._selectTimeBtn.setTitle("select_start_and_end_time".localized())
            self._selectedDate = nil
            self._selectedVenue = nil
            self._validDayList = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
            self.params.removeValue(forKey: "venueType")
            self._gallaryView.isHidden = true
            self._imageGallery.removeAll()
            self._loadData()
            self._updateData()

        })
    }
    
}

extension PromoterEventInfoCell: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == _dressCodeField {
            params["dressCode"] = textField.text
            _updateData()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == _informationTextView {
            params["description"] = textView.text
            _updateData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == _dressCodeField {
            params["dressCode"] = textField.text
        } else if textField == _informationTextView {
            params["description"] = textField.text
        }
        _updateData()
        return true
    }
}


extension PromoterEventInfoCell: GetSelectedOfferDelegate {
    func didSelectedOffer(_ model: OffersModel) {
        _setOfferData(model)
        params["offerId"] = model.id
        _updateData()
    }
}

extension PromoterEventInfoCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueGalleryCollectionCell {
            
            print("Cell Index: \(indexPath.row)")
            print("Cell Dict: \(String(describing: cellDict))")
            
            if indexPath.row == 0, let isFirstCell = cellDict?[kCellTagKey] as? Bool, isFirstCell {
                cell._closeBtn.isHidden = true
                cell._imageView.backgroundColor = .clear
                cell._imageView.tintColor = ColorBrand.brandGray.withAlphaComponent(0.7)
                cell._imageView.image = UIImage(named: "icon_coverSquare")
                cell._playIcon.isHidden = true
            } else if let object = cellDict?[kCellObjectDataKey] as? String {
                cell._closeBtn.isHidden = false
                if object.hasSuffix(".mp4") {
                    cell._imageView.image = Utils.generateThumbnail(for: object)
                    cell._playIcon.isHidden = false
                } else {
                    cell._imageView.loadWebImage(object)
                    cell._playIcon.isHidden = true
                }
            } else if let images = cellDict?[kCellObjectDataKey] as? UIImage {
                cell._closeBtn.isHidden = false
                cell._imageView.image = images
                cell._playIcon.isHidden = true
            }
            cell._closeBtn.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
            cell._closeBtn.tag = indexPath.row - 1
            
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let index = indexPath.row
        if index == 0 {
            endEditing(true)
            let vc = INIT_CONTROLLER_XIB(ImageSelectBottomSheet.self)
//            vc.galleryImages = _selectedVenue?.galleries ?? []
            vc.venueId = _selectedVenue?.id ?? kEmptyString
            vc.callback = { image in
                self._imageGallery.append(image)
                self._loadData()
                self._updateData()
            }
            vc.modalPresentationStyle = .overFullScreen
            parentViewController?.present(vc, animated: true)
        } else {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            var images: [LightboxImage] = []

            for urlString in _imageGallery {
                if let url = URL(string: urlString) {
                    if url.pathExtension.lowercased() == "mp4" || url.pathExtension.lowercased() == "mov" {
                        let placeholder = Utils.generateThumbnail(for: urlString) ?? UIImage()
                        if urlString == object {
                            images.insert(LightboxImage(image: placeholder, videoURL: url), at: 0)
                        } else {
                            images.append(LightboxImage(image: placeholder, videoURL: url))
                        }
                    } else {
                        if urlString == object {
                            images.insert(LightboxImage(imageURL: url), at: 0)
                        } else {
                            images.append(LightboxImage(imageURL: url))
                        }
                    }
                }
            }

            if images.isEmpty {
                print("No valid images or videos to display.")
                return
            }

            let controller = LightboxController(images: images)
            controller.dynamicBackground = true
            parentBaseController?.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        if index < _imageGallery.count {
            _imageGallery.remove(at: index)
        }
        isallDelete = _imageGallery.isEmpty
        _loadData()
        _updateData()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 70, height: 70)
    }
    
}
    
