import UIKit

class EventPageFourVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifiereSpots = String(describing: AvailableSpotTableCell.self)
    private let kCellIdentifiereSelectRings = String(describing: SelectMyRingsTableCell.self)
    private let kCellIdentifiereSelectCircle = String(describing: SelectMyCircleTableCell.self)
    private let kCellIdentifiereUserRings = String(describing: UserTableCell.self)
    private let kCellIdentifiereClosingtype = String(describing: PromoterClosingEventCell.self)
    private let kCellIdentifierePromoterEventRepeat = String(describing: PromoterEventRepeatCell.self)
    private let kCellIdentifiereAllowExtraGuest = String(describing: PlushOneFeatureCell.self)
    private let kCellIdentifiereSpecification = String(describing: PlusOneSpecificationTableCell.self)
    private let kCellEventSpecifiDate = String(describing: SpecificDateTableCell.self)
    var ringMembersList: [UserDetailModel] = []
    public var isEditEvent: Bool = false
    public var promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile ?? nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiereSpots, kCellNibNameKey: kCellIdentifiereSpots, kCellClassKey: AvailableSpotTableCell.self, kCellHeightKey: AvailableSpotTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereSelectRings, kCellNibNameKey: kCellIdentifiereSelectRings, kCellClassKey: SelectMyRingsTableCell.self, kCellHeightKey: SelectMyRingsTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereSelectCircle, kCellNibNameKey: kCellIdentifiereSelectCircle, kCellClassKey: SelectMyCircleTableCell.self, kCellHeightKey: SelectMyCircleTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereUserRings, kCellNibNameKey: kCellIdentifiereUserRings, kCellClassKey: UserTableCell.self, kCellHeightKey: UserTableCell.height],
            [kCellIdentifierKey: kCellIdentifierePromoterEventRepeat, kCellNibNameKey: kCellIdentifierePromoterEventRepeat, kCellClassKey: PromoterEventRepeatCell.self, kCellHeightKey: PromoterEventRepeatCell.height],
            [kCellIdentifierKey: kCellIdentifiereClosingtype, kCellNibNameKey: kCellIdentifiereClosingtype, kCellClassKey: PromoterClosingEventCell.self, kCellHeightKey: PromoterClosingEventCell.height],
            [kCellIdentifierKey: kCellIdentifiereAllowExtraGuest, kCellNibNameKey: kCellIdentifiereAllowExtraGuest, kCellClassKey: PlushOneFeatureCell.self, kCellHeightKey: PlushOneFeatureCell.height],
            [kCellIdentifierKey: kCellIdentifiereSpecification, kCellNibNameKey: kCellIdentifiereSpecification, kCellClassKey: PlusOneSpecificationTableCell.self, kCellHeightKey: PlusOneSpecificationTableCell.height],
            [kCellIdentifierKey: kCellEventSpecifiDate, kCellNibNameKey: kCellEventSpecifiDate, kCellClassKey: SpecificDateTableCell.self, kCellHeightKey: SpecificDateTableCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereSpots,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams,
            kCellClassKey: AvailableSpotTableCell.self,
            kCellHeightKey: AvailableSpotTableCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereClosingtype,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams,
            kCellClassKey: PromoterClosingEventCell.self,
            kCellHeightKey: PromoterClosingEventCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierePromoterEventRepeat,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams,
            kCellClassKey: PromoterEventRepeatCell.self,
            kCellHeightKey: PromoterEventRepeatCell.height
        ])
        
        if let repeatDatesAndTime = PromoterCreateEventVC.eventParams["repeatDatesAndTime"] as? [RepeatDateAndTimeModel],
           !repeatDatesAndTime.isEmpty || PromoterCreateEventVC.eventParams["repeat"] as? String == "specific-dates" || PromoterCreateEventVC.eventParams["repeat"] as? String == "specific dates" {
            cellData.append([
                kCellIdentifierKey: kCellEventSpecifiDate,
                kCellObjectDataKey: PromoterCreateEventVC.eventParams,
                kCellClassKey: SpecificDateTableCell.self,
                kCellHeightKey: SpecificDateTableCell.height
            ])
        }

        if PromoterCreateEventVC.eventParams["type"] as? String == "private" {
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereSelectCircle,
                kCellObjectDataKey: isEditEvent ? APPSESSION.promoterProfile?.circles.toArrayDetached(ofType: UserDetailModel.self) ?? [] : promoterModel?.circles.toArrayDetached(ofType: UserDetailModel.self) ?? [],
                kCellClassKey: SelectMyCircleTableCell.self,
                kCellHeightKey: SelectMyCircleTableCell.height
            ])
        }
        
        if PromoterCreateEventVC.eventParams["type"] as? String == "private" {
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereSelectRings,
                kCellObjectDataKey: ringMembersList,
                kCellClassKey: SelectMyRingsTableCell.self,
                kCellHeightKey: SelectMyRingsTableCell.height
            ])
            ringMembersList.forEach { user in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifiereUserRings,
                    kCellObjectDataKey: user,
                    kCellTagKey: PromoterCreateEventVC.eventParams,
                    kCellClassKey: UserTableCell.self,
                    kCellHeightKey: UserTableCell.height
                ])
            }
            
        }
        
//        cellData.append([
//            kCellIdentifierKey: kCellIdentifiereAllowExtraGuest,
//            kCellObjectDataKey: PromoterCreateEventVC.eventParams,
//            kCellClassKey: PlushOneFeatureCell.self,
//            kCellHeightKey: PlushOneFeatureCell.height
//        ])
        
        if PromoterCreateEventVC.eventParams["extraGuestType"] as? String == "specific", PromoterCreateEventVC.eventParams["plusOneAccepted"] as? Bool == true {
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereSpecification,
                kCellObjectDataKey: PromoterCreateEventVC.eventParams,
                kCellClassKey: PlusOneSpecificationTableCell.self,
                kCellHeightKey: PlusOneSpecificationTableCell.height
            ])
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
        
    }
    
    func getDatesBetween(startDate: String, endDate: String, repeatDays: [String], startTime: String, endTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        guard let start = dateFormatter.date(from: startDate),
              let end = dateFormatter.date(from: endDate) else {
            return
        }
        
        var resultModels: [RepeatDateAndTimeModel] = []
        var currentDate = start
        
        let repeatDayIndices: Set<Int>
        if repeatDays.isEmpty {
            repeatDayIndices = Set(1...7)
        } else {
            let dayMapping: [String: Int] = [
                "sunday": 1, "monday": 2, "tuesday": 3,
                "wednesday": 4, "thursday": 5, "friday": 6, "saturday": 7
            ]
            repeatDayIndices = Set(repeatDays.compactMap { dayMapping[$0.lowercased()] })
        }

        let calendar = Calendar.current

        while currentDate <= end {
            let weekday = calendar.component(.weekday, from: currentDate)
            
            if repeatDayIndices.contains(weekday) {
                let dateString = dateFormatter.string(from: currentDate)
                let model = RepeatDateAndTimeModel()
                model.startTime = startTime
                model.endTime = endTime
                model.date = dateString
                resultModels.append(model)
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        PromoterCreateEventVC.eventParams["repeatDatesAndTime"] = resultModels
    }
}

extension EventPageFourVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? AvailableSpotTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.callBack = { spots, isPrivate, isConfirmation, gender, category in
                if isPrivate {
                    PromoterCreateEventVC.eventParams["invitedGender"] = gender
                } else {
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "invitedGender")
                }
                PromoterCreateEventVC.eventParams["maxInvitee"] = spots
                PromoterCreateEventVC.eventParams["type"] = isPrivate ? "public" : "private"
                PromoterCreateEventVC.eventParams["isConfirmationRequired"] = isConfirmation
                PromoterCreateEventVC.eventParams["category"] = category
                self._loadData()
            }
//            cell.repeatCallBack = { type, date, repeatCount in
//                PromoterCreateEventVC.eventParams["repeat"] = type.lowercased()
//                if type == "specific date" {
//                    PromoterCreateEventVC.eventParams["repeatDate"] = date
//                }
//                if type != "none" {
//                    PromoterCreateEventVC.eventParams["repeatCount"] = repeatCount
//                } else if type == "none" {
//                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatCount")
//                }
//                self._loadData()
//            }
            cell.seatSplitCallBack = { male, female in
                if let gender = PromoterCreateEventVC.eventParams["invitedGender"] as? String, gender == "both" {
                    PromoterCreateEventVC.eventParams["maleSeats"] = male
                    PromoterCreateEventVC.eventParams["femaleSeats"] = female
                    self._loadData()
                } else {
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "maleSeats")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "femaleSeats")
                    self._loadData()

                }
            }
        } else if let cell = cell as? PromoterEventRepeatCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.repeatCallBack = { params in
                PromoterCreateEventVC.eventParams["repeat"] = (params["repeat"] as? String)?.lowercased()
                PromoterCreateEventVC.eventParams["repeatStartDate"] = params["repeatStartDate"] as? String
                PromoterCreateEventVC.eventParams["repeatEndDate"] = params["repeatEndDate"] as? String
                
                if let repeatValue = PromoterCreateEventVC.eventParams["repeat"] as? String,
                   let newRepeatValue = params["repeat"] as? String,
                   repeatValue != newRepeatValue {
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatStartDate")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatEndDate")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDays")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime")
                }
                
                switch params["repeat"] as? String {
                case "none":
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatStartDate")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatEndDate")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDays")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime")
                case "daily":
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDays")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime")
                case "weekly":
                    PromoterCreateEventVC.eventParams["repeatDays"] = params["repeatDays"] as? [String]
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime")
                case "specific dates", "specific-dates":
                    PromoterCreateEventVC.eventParams["repeatDatesAndTime"] = [RepeatDateAndTimeModel()]
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDays")
                default:
                    break
                }
                
                if params["repeat"] as? String == "weekly" || params["repeat"] as? String == "daily" {
                    self.getDatesBetween(
                        startDate: PromoterCreateEventVC.eventParams["repeatStartDate"] as? String ?? kEmptyString,
                        endDate: PromoterCreateEventVC.eventParams["repeatEndDate"] as? String ?? kEmptyString,
                        repeatDays: PromoterCreateEventVC.eventParams["repeatDays"] as? [String] ?? [],
                        startTime: PromoterCreateEventVC.eventParams["startTime"] as? String ?? kEmptyString,
                        endTime: PromoterCreateEventVC.eventParams["endTime"] as? String ?? kEmptyString
                    )
                    }
                    self._loadData()
                }
            } else if let cell = cell as? PlushOneFeatureCell {
                guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
                cell.setupData(params)
                if let isAllow = params["plusOneAccepted"] as? Bool {
                    PromoterCreateEventVC.eventParams["plusOneAccepted"] = isAllow
                } else {
                    PromoterCreateEventVC.eventParams["plusOneAccepted"] = false
                }
                cell.updateCallback = { data in
                    PromoterCreateEventVC.eventParams["plusOneAccepted"] = data.isAllowed
                    if data.isAllowed {
                        PromoterCreateEventVC.eventParams["extraGuestType"] = data.guestType
                        PromoterCreateEventVC.eventParams["extraGuestGender"] = data.gender
                        PromoterCreateEventVC.eventParams["plusOneQty"] = data.totalGuests
                        PromoterCreateEventVC.eventParams["extraGuestMaleSeats"] = data.maleGuests
                        PromoterCreateEventVC.eventParams["extraGuestFemaleSeats"] = data.femaleGuests
                        PromoterCreateEventVC.eventParams["extraSeatPreference"] = data.seatAllocationType
                    }
                    self._loadData()
                }
            } else if let cell = cell as? PlusOneSpecificationTableCell {
                guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
                cell.setupData(params)
                cell.dataUpdated = { data in
                    PromoterCreateEventVC.eventParams["extraGuestAge"] = "\(data.minAge)-\(data.maxAge)"
                    PromoterCreateEventVC.eventParams["extraGuestDressCode"] = data.dressCode
                    PromoterCreateEventVC.eventParams["extraGuestNationality"] = data.nationality
                    self._loadData()
                }
        } else if let cell = cell as? SpecificDateTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            let models = params["repeatDatesAndTime"] as? [RepeatDateAndTimeModel]
            cell.setupData(models ?? [RepeatDateAndTimeModel()],params: params )
            cell.callback = { model in
                PromoterCreateEventVC.eventParams["repeatDatesAndTime"] = model
                PromoterCreateEventVC.eventParams["repeat"] = "specific dates"
                self._loadData()
            }
            cell.clearAll = { [weak self] in
                guard let self = self else { return }
                PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime")
                PromoterCreateEventVC.eventParams["repeatDatesAndTime"] = [RepeatDateAndTimeModel()]
                PromoterCreateEventVC.eventParams["repeat"] = "specific dates"
                self._loadData()
            }

        } else if let cell = cell as? SelectMyCircleTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object, selectedId: PromoterCreateEventVC.eventParams["invitedCircles"] as? [String] ?? [], isSelectAll: PromoterCreateEventVC.eventParams["selectAllCircles"] as? Bool ?? false)
            cell.selectedIdsCallback = { selected in
                PromoterCreateEventVC.eventParams["invitedCircles"] = selected
            }
            cell.selectAllCallback = { isSelectAll in
                PromoterCreateEventVC.eventParams["selectAllCircles"] = isSelectAll
            }

        } else if let cell = cell as? SelectMyRingsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object, selectedId: PromoterCreateEventVC.eventParams["invitedUser"] as? [String] ?? [], isSelectAll: PromoterCreateEventVC.eventParams["selectAllUsers"] as? Bool ?? false)
            cell.selectedIdsCallback = { selected in
                PromoterCreateEventVC.eventParams["invitedUser"] = selected
            }
            cell.selectAllCallback = { isSelectAll in
                PromoterCreateEventVC.eventParams["selectAllUsers"] = isSelectAll
                if isSelectAll {
                    PromoterCreateEventVC.eventParams["invitedUser"] = object.map({ $0.userId })
                } else {
                    PromoterCreateEventVC.eventParams["invitedUser"] = []
                }
                self._loadData()
            }
        } else if let cell = cell as? UserTableCell {
            guard let params = cellDict?[kCellTagKey] as? [String: Any], let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            let invitedUserList = params["invitedUser"] as? [String]
            let isSelected = invitedUserList?.contains(object.userId) ?? false
            cell.setupRings(object, isSelected: isSelected)
        } else if let cell = cell as? PromoterClosingEventCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.updateClosingtype = { type, time in
                PromoterCreateEventVC.eventParams["spotCloseType"] = type
                PromoterCreateEventVC.eventParams["spotCloseAt"] = time
                self._loadData()
            }
        }
    }
}


