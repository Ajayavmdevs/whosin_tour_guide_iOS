import UIKit

class BuyActivityCell: UITableViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _stepperLabel: UILabel!
    @IBOutlet private weak var _discription: UILabel!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _collectionViewHightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _timeCollectionView: CustomCollectionView!
    @IBOutlet private weak var _timeCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _activityStartDates: UILabel!
    @IBOutlet weak var _activityEndDate: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: DaysCollectionCell.self)
    private let kTimeCellIdentifier = String(describing: TimeCollectionCell.self)
    private var stepperValue: Int = 0
    private var stepperMaxValue: Int = 0
    private var slots: [String] = []
    private var dates: [AvilableDateTimeModel] = []
    private var timeSlots: [AvilableDateTimeModel] = []
    private var activityModel: ActivitiesModel?
    private var _selectedDate: String = kEmptyString
    private var _selectedTime: String = kEmptyString
    private var _callback: JsonResult?
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
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 8)
            self._coverImage.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        }
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0.0, left: 17.0, bottom: 0.0, right: 0.0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
        _timeCollectionView.setup(cellPrototypes: _prototypes,
                                  hasHeaderSection: false,
                                  enableRefresh: false,
                                  columns: 5,
                                  rows: 1,
                                  edgeInsets: UIEdgeInsets(top: 0.0, left: 17.0, bottom: 0.0, right: 0.0),
                                  scrollDirection: .horizontal,
                                  emptyDataText: nil,
                                  emptyDataIconImage: nil,
                                  delegate: self)
        _timeCollectionView.showsVerticalScrollIndicator = false
        _timeCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: DaysCollectionCell.self, kCellHeightKey: DaysCollectionCell.height],
            [kCellIdentifierKey: kTimeCellIdentifier, kCellNibNameKey: kTimeCellIdentifier, kCellClassKey: TimeCollectionCell.self, kCellHeightKey: TimeCollectionCell.height]
        ]
    }
    
    private func _loadDateData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        dates.forEach { date in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: date,
                kCellClassKey: DaysCollectionCell.self,
                kCellHeightKey: DaysCollectionCell.height
            ])
        }
        
        if !(activityModel?.time?.type == "slot") {
            guard let startTime = activityModel?.time?.startTime , let endTime = activityModel?.time?.endTime else { return }
            slots = getTimeArray(startTime: startTime, endTime: endTime)
            _loadTimeData()
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private func _loadTimeData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        slots.forEach { slot in
            let selectedDate = Utils.stringToDateLocal(self._selectedDate, format: "yyyy-MM-dd HH:mm:ss Z")
            let selectedDateStr = Utils.dateToStringUTC(selectedDate, format: kFormatDate)
            if let startTime = slot.components(separatedBy: "-").first {
                let date = "\(selectedDateStr) \(startTime)"
                if !Utils.isDateExpired(dateString: date, format: "yyyy-MM-dd HH:mm") {
                    cellData.append([
                        kCellIdentifierKey: kTimeCellIdentifier,
                        kCellTagKey: kTimeCellIdentifier,
                        kCellObjectDataKey: slot,
                        kCellClassKey: TimeCollectionCell.self,
                        kCellHeightKey: TimeCollectionCell.height
                    ])
                }
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _timeCollectionView.loadData(cellSectionData)
    }
    
    private func updateLabel() {
        _stepperLabel.text = "\(stepperValue)"
        
        guard let _activityModel = activityModel else { return }
        let cartModel = BuyPackgeVC.tmpCart.first { $0.id == _activityModel.id }
        if cartModel != nil {
            cartModel?.quantity = stepperValue
        } else {
            guard let tmpModel = CartModel(_activityModel) else { return }
            tmpModel.quantity = stepperValue
            BuyPackgeVC.tmpCart.append(tmpModel)
        }
        NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)

        _updateCallBack()
    }
    
    private func _updateCallBack() {
        var dict: [String : Any] = [:]
        dict["qty"] = stepperValue
        let date = Utils.stringToDate(_selectedDate, format: "yyyy-MM-dd HH:mm:ss Z")
        dict["date"] = Utils.dateToString(date, format: kFormatDateDOB)
        dict["time"] = _selectedTime
        _callback?(dict, nil)
    }
    
    func getTimeArray(startTime: String, endTime: String) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTime = dateFormatter.date(from: startTime),
              let endTime = dateFormatter.date(from: endTime) else {
            return []
        }
        
        var timeArray: [String] = []
        var currentTime = startTime
        
        while currentTime <= endTime {
            let currentTimeString = dateFormatter.string(from: currentTime)
            timeArray.append(currentTimeString)
            
            currentTime = Calendar.current.date(byAdding: .hour, value: 1, to: currentTime) ?? currentTime
        }
        
        return timeArray
    }



    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFatchDates() {
        WhosinServices.activityFatchDates(activityId: activityModel?.id ?? kEmptyString) { [weak self]container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.dates = data
            self._loadDateData()
        }
    }
    
    private func _requestFatchTimeSlot(_ date: String) {
        WhosinServices.activityFatchSlots(activityId: activityModel?.id ?? kEmptyString,date: date) { [weak self]container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.timeSlots = data
            self.slots = data.map { $0.time }
            self._loadTimeData()
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: ActivitiesModel , callback: JsonResult?) {
        _callback = callback
        activityModel = model
        _requestFatchDates()
        _coverImage.loadWebImage(model.cover)
        _packageName.text = model.name
        _venueInfoView.setupProviderData(venue: model.provider ?? ProviderModel())
        _discription.text = model.descriptions
        
        _activityStartDates.attributedText = Utils.setAtributedTitleText(title: "reservation_from".localized(), subtitle: "\n\(model.reservationStart?.display ?? kEmptyString)", titleFont: FontBrand.SFmediumFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
        _activityEndDate.attributedText = Utils.setAtributedTitleText(title: "reservation_to".localized(), subtitle: "\n\(model.reservationEnd?.display ?? kEmptyString)", titleFont: FontBrand.SFmediumFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
        
        _badgeView.setupData(originalPrice: model.price, discountedPrice: model._disocuntedPrice, isNoDiscount: model._isNoDiscount)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleStepMinusEvennt(_ sender: Any) {
        if _selectedTime == kEmptyString {
            parentBaseController?.alert(message: "please_select_date_and_time_first".localized())
            return
        }
        if stepperValue != 0 { stepperValue -= 1 }
        updateLabel()
    }
    
    @IBAction func _handelStepperPlushEvent(_ sender: Any) {
        if _selectedTime == kEmptyString {
            parentBaseController?.alert(message: "please_select_date_and_time_first".localized())
            return
        }
        if stepperValue < stepperMaxValue { stepperValue += 1 }
        updateLabel()
    }
    
}

extension BuyActivityCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? DaysCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? AvilableDateTimeModel,let date = object.date else { return }
            cell._bgView.backgroundColor = _selectedDate == "\(date)" ? ColorBrand.brandGreen: ColorBrand.white.withAlphaComponent(0.13)
            cell.setUpdata(Utils.dateToString(date, format: "dd MMM") + " (\(object.remainingSeat))", isActivity: true)
            cell._closeBtn.isHidden = true
        } else if let cell = cell as? TimeCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell._bgView.backgroundColor = _selectedTime == object ? ColorBrand.brandGreen: ColorBrand.white.withAlphaComponent(0.13)
            if let seat = timeSlots.first(where: { $0.time == object})?.seat {
                cell.setUpdata("\(object) (\(seat))" , isActivity: true)
            } else {
                cell.setUpdata(object, isActivity: true)
            }

        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if collectionView == _timeCollectionView {
            if !timeSlots.isEmpty {
                return CGSize(width: 120, height: DaysCollectionCell.height)
            }
        }
        return CGSize(width: 150, height: DaysCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is DaysCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? AvilableDateTimeModel, let date = object.date else { return }
            _selectedDate = "\(date)"
            _selectedTime = ""
            stepperMaxValue = object.remainingSeat
            _loadTimeData()
            _collectionView.reload()
            _requestFatchTimeSlot(Utils.dateToString(object.date, format: kFormatDate))
        } else if cell is TimeCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            _selectedTime = object
            if !timeSlots.isEmpty, let seat = timeSlots.first(where: { $0.time == object})?.seat {
                stepperMaxValue = seat
            }
            _timeCollectionView.reload()
        }
        _updateCallBack()
    }
    
}
