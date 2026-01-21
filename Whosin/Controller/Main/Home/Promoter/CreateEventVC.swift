import UIKit
import IQKeyboardManagerSwift
import ObjectMapper

class CreateEventVC: ChildViewController {
    
    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet private weak var _saveDraftBtn: CustomActivityButton!
    @IBOutlet private weak var _nextStepBtn: CustomActivityButton!
    @IBOutlet private weak var _backProgressBtn: CustomActivityButton!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _stepProgress: StepIndicatorView!
    private let kCellIdentifiereComman = String(describing: PromoterEventInfoCell.self)
    private let kCellIdentifiereRequirement = String(describing: RequirementTableCell.self)
    private let kCellIdentifiereSocial = String(describing: SocialTableCell.self)
    private let kCellIdentifiereSpots = String(describing: AvailableSpotTableCell.self)
    private let kCellIdentifiereSelectRings = String(describing: SelectMyRingsTableCell.self)
    private let kCellIdentifiereSelectCircle = String(describing: SelectMyCircleTableCell.self)
    private let kCellIdentifiereAllowExtraGuest = String(describing: PlushOneFeatureCell.self)
    private let kCellIdentifiereSpecification = String(describing: PlusOneSpecificationTableCell.self)
    private let kCellIdentifiereUserRings = String(describing: UserTableCell.self)
    private let kCellIdentifiereClosingtype = String(describing: PromoterClosingEventCell.self)
    private let kCellEventRepeatIdentifire = String(describing: PromoterEventRepeatCell.self)
    private let kCellEventSpecifiDate = String(describing: SpecificDateTableCell.self)
    private let kCellEventSelectPass = String(describing: SelectPaidPassTypeTableCell.self)
    private let kCellFAQTable = String(describing: FAQEditTableCell.self)
    public var promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile ?? nil
    private var ringMembersList: [UserDetailModel] = []
    public var socialAccounts: [SocialAccountsModel] = []
    public var params: [String: Any] = [:]
    public var eventModel: PromoterEventsModel?
    public var isEditEvent: Bool = false
    public var isDraft: Bool = false
    public var isRepost: Bool = false
    private var extraguest: [ExtraGuestModel] = []
    private var paidPassList: [PaidPassModel] = []
    static var categories: [String] = []
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
//        IQKeyboardManager.shared.enable = false
        _requestGetCustomCaetegory()
        _backProgressBtn.isHidden = true
        _saveDraftBtn.isHidden = true
        _nextStepBtn.isEnabled = false
        if !isEditEvent {
            let insta = SocialAccountsModel()
            insta.platform = SocialPlatforms.instagram.rawValue
            socialAccounts.append(insta)
            if !Preferences.saveEventDraft.isEmpty {
                if let socialAccountsArray = params["socialAccountsToMention"] as? [[String: Any]] {
                    if let socialAccountsJSONString = try? JSONSerialization.data(withJSONObject: socialAccountsArray, options: .prettyPrinted) {
                        let jsonString = String(data: socialAccountsJSONString, encoding: .utf8)
                        if let model = Mapper<SocialAccountsModel>().mapArray(JSONString: jsonString!) {
                            print("Mapped SocialAccountsModel: \(model)")
                            socialAccounts = model
                        } else {
                            print("Failed to map the JSON string to SocialAccountsModel.")
                        }
                    }
                }
                if isDraft {
                    if params["repeat"] as? String != "none" {
                        self.getDatesBetween(startDate:params["repeatStartDate"] as? String  ?? kEmptyString, endDate: params["repeatEndDate"] as? String  ?? kEmptyString, repeatDays: params["repeatDays"] as? [String] ?? [], startTime: self.params["startTime"] as? String ?? kEmptyString, endTime: self.params["endTime"] as? String ?? kEmptyString)
                    }

                    if self.eventInfoKeysAvailable(params: self.params) {
                        self._nextStepBtn.backgroundColor = ColorBrand.brandPink
                        self._nextStepBtn.isEnabled = true
                    }
                }
            } else {
                params.removeAll()
            }
            _titleLabel.text = "create_your_event".localized()
        } else {
            _titleLabel.text = isRepost ? "repost_your_event".localized() : "update_your_event".localized()
            _nextStepBtn.isEnabled = true
            _nextStepBtn.backgroundColor = ColorBrand.brandPink
            if params["repeat"] as? String != "specific-dates" {
                self.getDatesBetween(startDate:params["repeatStartDate"] as? String  ?? kEmptyString, endDate: params["repeatEndDate"] as? String  ?? kEmptyString, repeatDays: params["repeatDays"] as? [String] ?? [], startTime: self.params["startTime"] as? String ?? kEmptyString, endTime: self.params["endTime"] as? String ?? kEmptyString)
            }
            _requestInvitedUserIds()
        }
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
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
        _tableView.proxyDelegate = self
        _loadData()
        _requestRingMember()
        _paymentPassRequest()
        _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
    }
    
    
    private func _paymentPassRequest() {
        WhosinServices.purchasePaidPass() { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            self.paidPassList = data
        }
    }
    
    private func _requestGetCustomCaetegory() {
        WhosinServices.getCustomCategory { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            CreateEventVC.categories = data.data
            CreateEventVC.categories.append("Custom")
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiereComman, kCellNibNameKey: kCellIdentifiereComman, kCellClassKey: PromoterEventInfoCell.self, kCellHeightKey: PromoterEventInfoCell.height],
            [kCellIdentifierKey: kCellIdentifiereRequirement, kCellNibNameKey: kCellIdentifiereRequirement, kCellClassKey: RequirementTableCell.self, kCellHeightKey: RequirementTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereSpots, kCellNibNameKey: kCellIdentifiereSpots, kCellClassKey: AvailableSpotTableCell.self, kCellHeightKey: AvailableSpotTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereSelectRings, kCellNibNameKey: kCellIdentifiereSelectRings, kCellClassKey: SelectMyRingsTableCell.self, kCellHeightKey: SelectMyRingsTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereSelectCircle, kCellNibNameKey: kCellIdentifiereSelectCircle, kCellClassKey: SelectMyCircleTableCell.self, kCellHeightKey: SelectMyCircleTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereAllowExtraGuest, kCellNibNameKey: kCellIdentifiereAllowExtraGuest, kCellClassKey: PlushOneFeatureCell.self, kCellHeightKey: PlushOneFeatureCell.height],
            [kCellIdentifierKey: kCellIdentifiereSpecification, kCellNibNameKey: kCellIdentifiereSpecification, kCellClassKey: PlusOneSpecificationTableCell.self, kCellHeightKey: PlusOneSpecificationTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereSocial, kCellNibNameKey: kCellIdentifiereSocial, kCellClassKey: SocialTableCell.self, kCellHeightKey: SocialTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereUserRings, kCellNibNameKey: kCellIdentifiereUserRings, kCellClassKey: UserTableCell.self, kCellHeightKey: UserTableCell.height],
            [kCellIdentifierKey: kCellIdentifiereClosingtype, kCellNibNameKey: kCellIdentifiereClosingtype, kCellClassKey: PromoterClosingEventCell.self, kCellHeightKey: PromoterClosingEventCell.height],
            [kCellIdentifierKey: kCellEventRepeatIdentifire, kCellNibNameKey: kCellEventRepeatIdentifire, kCellClassKey: PromoterEventRepeatCell.self, kCellHeightKey: PromoterEventRepeatCell.height],
            [kCellIdentifierKey: kCellEventSpecifiDate, kCellNibNameKey: kCellEventSpecifiDate, kCellClassKey: SpecificDateTableCell.self, kCellHeightKey: SpecificDateTableCell.height],
            [kCellIdentifierKey: kCellFAQTable, kCellNibNameKey: kCellFAQTable, kCellClassKey: FAQEditTableCell.self, kCellHeightKey: FAQEditTableCell.height],
            [kCellIdentifierKey: kCellEventSelectPass, kCellNibNameKey: kCellEventSelectPass, kCellClassKey: SelectPaidPassTypeTableCell.self, kCellHeightKey: SelectPaidPassTypeTableCell.height],
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _backProgressBtn.isHidden = false
        _saveDraftBtn.isHidden = isEditEvent
        IQKeyboardManager.shared.enableAutoToolbar = true
        if Utils.stringIsNullOrEmpty(params["type"] as? String) {
            params["type"] = "private"
        }
        switch _stepProgress.currentStep {
        case 1:
            _backProgressBtn.isHidden = true
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereComman,
                kCellTagKey: kCellIdentifiereComman,
                kCellObjectDataKey: params,
                kCellClassKey: PromoterEventInfoCell.self,
                kCellHeightKey: PromoterEventInfoCell.height
            ])
        case 2:
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereRequirement,
                kCellTagKey: true,
                kCellObjectDataKey: params["requirementsAllowed"] as? [String] ?? [],
                kCellTitleKey: RequirementType.requirementsAllowed.rawValue,
                kCellClassKey: RequirementTableCell.self,
                kCellHeightKey: RequirementTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereRequirement,
                kCellTagKey: false,
                kCellObjectDataKey: params["requirementsNotAllowed"] as? [String] ?? [],
                kCellTitleKey: RequirementType.requirementsNotAllowed.rawValue,
                kCellClassKey: RequirementTableCell.self,
                kCellHeightKey: RequirementTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereRequirement,
                kCellTagKey: true,
                kCellObjectDataKey: params["benefitsIncluded"] as? [String] ?? [],
                kCellTitleKey: RequirementType.benefitsIncluded.rawValue,
                kCellClassKey: RequirementTableCell.self,
                kCellHeightKey: RequirementTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereRequirement,
                kCellTagKey: false,
                kCellTitleKey: RequirementType.benefitsNotIncluded.rawValue,
                kCellObjectDataKey: params["benefitsNotIncluded"] as? [String] ?? [],
                kCellClassKey: RequirementTableCell.self,
                kCellHeightKey: RequirementTableCell.height
            ])
            
        case 3:
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereSocial,
                kCellObjectDataKey: socialAccounts,
                kCellClassKey: SocialTableCell.self,
                kCellHeightKey: SocialTableCell.height
            ])
            
        case 4:
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereSpots,
                kCellObjectDataKey: params,
                kCellClassKey: AvailableSpotTableCell.self,
                kCellHeightKey: AvailableSpotTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereClosingtype,
                kCellObjectDataKey: params,
                kCellClassKey: PromoterClosingEventCell.self,
                kCellHeightKey: PromoterClosingEventCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellEventRepeatIdentifire,
                kCellObjectDataKey: params,
                kCellClassKey: PromoterEventRepeatCell.self,
                kCellHeightKey: PromoterEventRepeatCell.height
            ])
            
            if let repeatDatesAndTime = params["repeatDatesAndTime"] as? [RepeatDateAndTimeModel],
               !repeatDatesAndTime.isEmpty && params["repeat"] as? String != "none" || params["repeat"] as? String == "specific-dates" || params["repeat"] as? String == "specific dates" {
                cellData.append([
                    kCellIdentifierKey: kCellEventSpecifiDate,
                    kCellObjectDataKey: params,
                    kCellClassKey: SpecificDateTableCell.self,
                    kCellHeightKey: SpecificDateTableCell.height
                ])
            }

            
            if params["type"] as? String == "private" {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifiereSelectCircle,
                    kCellObjectDataKey: isEditEvent ? APPSESSION.promoterProfile?.circles.toArrayDetached(ofType: UserDetailModel.self) ?? [] : promoterModel?.circles.toArrayDetached(ofType: UserDetailModel.self) ?? [],
                    kCellClassKey: SelectMyCircleTableCell.self,
                    kCellHeightKey: SelectMyCircleTableCell.height
                ])
            }
            
            if params["type"] as? String == "private" {
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
                        kCellTagKey: params,
                        kCellClassKey: UserTableCell.self,
                        kCellHeightKey: UserTableCell.height
                    ])
                }
                
            }
        case 5:
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereAllowExtraGuest,
                kCellObjectDataKey: params,
                kCellClassKey: PlushOneFeatureCell.self,
                kCellHeightKey: PlushOneFeatureCell.height
            ])
            
            if params["extraGuestType"] as? String == "specific", params["plusOneAccepted"] as? Bool == true {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifiereSpecification,
                    kCellObjectDataKey: params,
                    kCellClassKey: PlusOneSpecificationTableCell.self,
                    kCellHeightKey: PlusOneSpecificationTableCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kCellFAQTable,
                kCellObjectDataKey: params,
                kCellClassKey: FAQEditTableCell.self,
                kCellHeightKey: FAQEditTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellEventSelectPass,
                kCellTagKey: paidPassList,
                kCellObjectDataKey: params,
                kCellClassKey: SelectPaidPassTypeTableCell.self,
                kCellHeightKey: SelectPaidPassTypeTableCell.height
            ])
            
        default:
            print("Value is not 1, 2, 3, or 4")
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
        
    }
    
    private func validation() {
        if _stepProgress.currentStep == 1 {
            if Utils.stringIsNullOrEmpty(params["venueId"] as? String) {
                if let customVenue = params["customVenue"] as? [String: Any], customVenue.isEmpty {
                    alert(message: "select_venue_or_create_custom".localized())
                    return
                }
            }
            
//            guard let eventGallery = params["eventGallery"] as? [String], !eventGallery.isEmpty else {
//                alert(message: "Please select a images from the gallery..")
//                return
//            }
            
            guard let dateString = params["date"] as? String, !Utils.stringIsNullOrEmpty(dateString) else {
                alert(message: "please_select_a_date".localized())
                return
            }

            guard let timeString = params["startTime"] as? String, !Utils.stringIsNullOrEmpty(timeString) else {
                alert(message: "please_select_a_time-slot".localized())
                return
            }
            
            if !isEditEvent {
                if let selectedDateTime = Utils.stringToDate(dateString + " " + timeString, format: kFormatDateTimeLocal){
                    if selectedDateTime.isExpired() {
                        alert(message: "please_select_valid_date_and_time".localized())
                        return
                    }
                }
            }

                        
            if Utils.stringIsNullOrEmpty(params["endTime"] as? String) {
                alert(message: "please_select_a_time-slot".localized())
                return
            }
            
            if Utils.stringIsNullOrEmpty(params["dressCode"] as? String) {
                alert(message: "please_enter_the_dresscode".localized())
                return
            }
            
            if Utils.stringIsNullOrEmpty(params["description"] as? String) {
                alert(message: "please_enter_the_description".localized())
                return
            }
            
            if _stepProgress.currentStep < 4 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
            _loadData()
        }
    }
    
    private func _validateData(_ step: Int) {
        switch step {
        case 1:
            validation()
        case 2:
            if params["requirementsAllowed"] as? [String] == nil {
                alert(message: "please_enter_requirements_allowed".localized())
                return
            }
            
            if params["benefitsIncluded"] as? [String] == nil {
                alert(message: "please_enter_benifits_included".localized())
                return
            }
            
            if let reqirements = params["requirementsAllowed"] as? [String], reqirements.isEmpty {
                alert(message: "please_enter_requirements_allowed".localized())
                return
            }
            
            if let benifits = params["benefitsIncluded"] as? [String], benifits.isEmpty {
                alert(message: "please_enter_benifits_included".localized())
                return
            }
            if _stepProgress.currentStep < 5 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
            _loadData()
        case 3:
            if socialAccounts.isEmpty {
                alert(message: "please_add_social_account".localized())
                return
            }
            
            for model in socialAccounts {
                if model.platform == SocialPlatforms.whosin.rawValue {
                    if !Utils.validateUrl(URL(string: model.account)) {
                        alert(message: LANGMANAGER.localizedString(forKey: "vaild_url_social_tagging", arguments: ["value": "WHOS'IN"]))
                        return
                    }
                }
                
//                if model.platform == SocialPlatforms.instagram.rawValue {
//                    if !Utils.validateInstagramProfileUrl(URL(string: model.account)) {
//                        alert(message: "Please enter valid instagram profile link.")
//                        return
//                    }
//                }
                
                if Utils.stringIsNullOrEmpty(model.account) {
                    alert(message: LANGMANAGER.localizedString(forKey: "valid_platform_account", arguments: ["value": model.platform]))
                    return
                }
            }
            
            if _stepProgress.currentStep < 5 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
//            _nextStepBtn.setTitle(isEditEvent ? isRepost ? "Repost Event" : "Update Event" : "Create Event")
            _loadData()
        case 4:
            
            if (params["maxInvitee"] as? Int ?? 0) < 1 {
                alert(message: "valid_spot_available_alert".localized())
                return
            }
            
            if let type = params["type"] as? String, type == "public" {
                if let gender = params["invitedGender"] as? String, gender == "both" {
                    if (params["maleSeats"] as? Int == 0), params["maleSeats"] == nil {
                        alert(message: "please_enter_the_valid_number_of_available_male_seats".localized())
                        return
                    }
                }
            }
            
            if let type = params["type"] as? String, type == "public" {
                if let gender = params["invitedGender"] as? String, gender == "both" {
                    if (params["femaleSeats"] as? Int == 0), params["femaleSeats"] == nil {
                        alert(message: "enter_number_available_female_seats".localized())
                        return
                    }
                }
            }
            
            if let type = params["type"] as? String, type == "public" {
                if let gender = params["invitedGender"] as? String, gender == "both" {
                    if let male = params["maleSeats"] as? Int, let female = params["femaleSeats"] as? Int, let totalInvited = params["maxInvitee"] as? Int {
                        if (male + female) > totalInvited {
                            alert(message: "total_male_female_seats".localized())
                            return
                        }
                        if (male + female) != totalInvited {
                            alert(message: "total_male_female_seats".localized())
                            return
                        }
                    }
                } else {
                    params.removeValue(forKey: "maleSeats")
                    params.removeValue(forKey: "femaleSeats")
                }
            }
            
            if let type = params["type"] as? String, type == "private" {
                params.removeValue(forKey: "maleSeats")
                params.removeValue(forKey: "femaleSeats")
                params.removeValue(forKey: "invitedGender")
                let invited = params["invitedUser"] as? [String]
                let circle = params["invitedCircles"] as? [String]
                if (invited == nil || invited!.isEmpty) {
                    if  (circle == nil || circle!.isEmpty) {
                        alert(message: "invite_user_or_circle_required".localized())
                        return
                    }
                }
                if invited?.count != ringMembersList.count {
                    params["selectAllUsers"] = false
                }
            }
            
            if (params["isConfirmationRequired"] as? Bool) == false {
                if let gender = params["invitedGender"] as? String, Utils.stringIsNullOrEmpty(gender) {
                    alert(message: "select_invited_gender".localized())
                    return
                }
            }
            
            if let type = params["repeat"] as? String, Utils.stringIsNullOrEmpty(type) {
                params["repeat"] = "none"
            }
            
            if let type = params["repeat"] as? String, type == "specific dates" {
                if let selectDate = params["repeatDate"] as? String, Utils.stringIsNullOrEmpty(selectDate) {
                    alert(message: "select_date".localized())
                    return
                }
            }
            
            if let type = params["repeat"] as? String, type != "none" {
                let startdate = params["repeatStartDate"] as? String
                let endDate = params["repeatEndDate"] as? String
                let days = params["repeatDays"] as? [String]
                if Utils.stringIsNullOrEmpty(startdate) && Utils.stringIsNullOrEmpty(endDate) {
                    alert(message: "select_repetition_date_range".localized())
                    return
                }
                if type == "weekly" && (days == nil || days!.isEmpty) {
                    alert(message: "select_weekly_repetition_days".localized())
                    return
                }
                if type == "specific dates" || type == "specific-dates" {
                    guard let dateArray = params["repeatDatesAndTime"] as? [RepeatDateAndTimeModel],
                          !dateArray.isEmpty else {
                        alert(message: "error_invalid_dates_times".localized())
                        return
                    }
                    
                    for dateAndTime in dateArray {
                        if Utils.stringIsNullOrEmpty(dateAndTime.date) || Utils.stringIsNullOrEmpty(dateAndTime.startTime) || Utils.stringIsNullOrEmpty(dateAndTime.endTime) {
                            alert(message: "error_invalid_dates_times".localized())
                            return
                        }
                    }
                }
            }
            

            if _stepProgress.currentStep < 5 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(isEditEvent ? isRepost ? "repost_event".localized() : "update_event".localized() : "create_event".localized())
            _loadData()
        case 5:
            
            if params["plusOneAccepted"] as? Bool == false {
                params.removeValue(forKey: "extraGuestType")
                params.removeValue(forKey: "plusOneQty")
                params.removeValue(forKey: "extraGuestAge")
                params.removeValue(forKey: "extraGuestDressCode")
                params.removeValue(forKey: "extraGuestGender")
                params.removeValue(forKey: "extraGuestNationality")
                params.removeValue(forKey: "extraGuestMaleSeats")
                params.removeValue(forKey: "extraGuestFemaleSeats")
                params.removeValue(forKey: "extraSeatPreference")
            }
            
            if params["extraSeatPreference"] as? String == "random" {
                params.removeValue(forKey: "extraGuestMaleSeats")
                params.removeValue(forKey: "extraGuestFemaleSeats")
            }
            
            if let plusOneQty = params["plusOneQty"] as? Int, plusOneQty < 1 {
                alert(message: "Please enter valid plus one spots.")
                return
            }
            
            if (params["extraGuestGender"] as? String) == "male" {
                params.removeValue(forKey: "extraGuestMaleSeats")
                params.removeValue(forKey: "extraGuestFemaleSeats")
                params.removeValue(forKey: "extraSeatPreference")

            }
            
            if (params["extraGuestGender"] as? String) == "female" {
                params.removeValue(forKey: "extraGuestMaleSeats")
                params.removeValue(forKey: "extraGuestFemaleSeats")
                params.removeValue(forKey: "extraSeatPreference")

            }
            
            if let gender = params["extraGuestGender"] as? String, gender == "both", let genderType = params["extraSeatPreference"] as? String, genderType == "specific" {
                if params["extraGuestMaleSeats"] as? Int == 0 || params["extraGuestMaleSeats"] == nil  {
                    alert(message: "please_enter_valid_male_guest_seat".localized())
                    return
                }
                
                if params["extraGuestFemaleSeats"] as? Int == 0 || params["extraGuestMaleSeats"] == nil {
                    alert(message: "please_enter_valid_female_guest_seats".localized())
                    return
                }
            }
            
            if let guestType = params["extraGuestType"] as? String, guestType == "specific" {

                if let guestAge = params["extraGuestAge"] as? String, Utils.stringIsNullOrEmpty(guestAge) {
                    alert(message: "please_select_guest_age_range".localized())
                    return
                }
                
                if let dressCode = params["extraGuestDressCode"] as? String, Utils.stringIsNullOrEmpty(dressCode) {
                    alert(message: "please_enter_guest_dress_code".localized())
                    return
                }
                
                if let nationality = params["extraGuestNationality"] as? String, Utils.stringIsNullOrEmpty(nationality) {
                    alert(message: "please_select_guest_nationality".localized())
                    return
                }

            } else {
                params.removeValue(forKey: "extraGuestAge")
                params.removeValue(forKey: "extraGuestDressCode")
                params.removeValue(forKey: "extraGuestNationality")
            }
            
            if let type = params["paidPassType"] as? String {
                if type == "override" {
                    if Utils.stringIsNullOrEmpty(params["paidPassId"] as? String) {
                        alert(message: "please_select_paid_pass_for_this_event".localized())
                        return
                    }
                }
                if type == "default" {
                    params["paidPassId"] = kEmptyString
                }
            } else {
                params["paidPassType"] = "default"
                params["paidPassId"] = kEmptyString
            }
            
            if isRepost {
                _requestCreateEvent()
            } else {
                if isEditEvent {
                    if Utils.stringIsNullOrEmpty(params["cloneId"] as? String) {
                        _requestUpdateEvent()
                    } else if !Utils.stringIsNullOrEmpty(params["cloneId"] as? String) {
                        showDeleteOptions()
                    } else {
                        _requestUpdateEvent()
                    }
                } else {
                    _requestCreateEvent()
                }
            }
        default:
            print(params)
        }
    }
    
    private func _requestCreateEvent() {
        if let type = params["venueType"] as? String, type == "venue" {
            params.removeValue(forKey: "customVenue")
        }
        if let guestType = params["extraGuestType"] as? String, guestType == "random" {
            params["extraGuestType"] = "anyone"
        }
        if let type = params["repeat"] as? String, type == "specific dates" || type == "specific-dates"  {
            params["repeat"] = "specific-dates"
            if let dateTimeArray = params["repeatDatesAndTime"] as? [RepeatDateAndTimeModel] {
                params["repeatDatesAndTime"] = dateTimeArray.toJSON()
            }
        } else {
            params.removeValue(forKey: "repeatDatesAndTime")
        }
        showHUD()
        WhosinServices.createInvite(params: params) { [weak self] contaienr, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = contaienr else { return }
            if data.code == 1 {
                DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                    if let id = self.params["draftId"] as? String {
                        for (index, item) in Preferences.saveEventDraft.enumerated() {
                            if let existingId = item["draftId"] as? String, existingId == id {
                                Preferences.saveEventDraft.remove(at: index)
                                NotificationCenter.default.post(name: .reloadEventDraftNotification, object: nil)
                            }
                        }
                    }
                    self.params.removeValue(forKey: "draftId")
                    self.showSuccessMessage("event_created_successfully".localized(), subtitle: kEmptyString)
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                }
            }
        }
    }
    
    private func _requestUpdateEvent() {
        if let type = params["venueType"] as? String, type == "venue" {
            params.removeValue(forKey: "customVenue")
        }
        if let type = params["repeat"] as? String, type == "specific-dates" || type == "specific dates"{
            params["repeat"] = "specific-dates"
            if let dateTimeArray = params["repeatDatesAndTime"] as? [RepeatDateAndTimeModel] {
                params["repeatDatesAndTime"] = dateTimeArray.toJSON()
            }
        } else { params.removeValue(forKey: "repeatDatesAndTime") }
        if let guestType = params["extraGuestType"] as? String, guestType == "random" {
            params["extraGuestType"] = "anyone"
        }
        params.removeValue(forKey: "draftId")
        showHUD()
        WhosinServices._updateMyevent(params: params) { [weak self] contaienr, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = contaienr else { return }
            if data.code == 1 {
                DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                    self.showSuccessMessage("event_updated_successfully".localized(), subtitle: kEmptyString)
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                }
            }
        }
    }
     
    private func _requestRingMember() {
        WhosinServices.getMyRingMemberList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.ringMembersList = data
            self._loadData()
        }
    }

    private func _requestInvitedUserIds() {
        guard let id = eventModel?.id else { return }
        WhosinServices.promoterEventInviteUsers(eventId: id) {[weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.params["invitedUser"] = Array(Set(data.invitedUsers.toArray(ofType: String.self)))
            self.params["selectAllUsers"] = data.selectAllUsers
            self.params["selectAllCircles"] = data.selectAllCircles
        }
    }
    
    func showDeleteOptions() {
        let alertController = UIAlertController(title: "update_event".localized(), message: "want_to_update_this_event_only".localized(), preferredStyle: .alert)
        
        let deleteCurrentAction = UIAlertAction(title: "update_current_event".localized(), style: .default) { _ in
            self.params["updateType"] = "current"
            self._requestUpdateEvent()
        }
        
        let deleteAllAction = UIAlertAction(title: "update_all_event".localized(), style: .default) { _ in
            self.params["updateType"] = "all"
            self._requestUpdateEvent()
        }
        
        let cancelAction = UIAlertAction(title: "close".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(deleteCurrentAction)
        alertController.addAction(deleteAllAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
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
        self.params["repeatDatesAndTime"] = resultModels
        _loadData()
    }

    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    
    @IBAction func _handleBackEvent(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleBackStepEvent(_ sender: CustomActivityButton) {
        if _stepProgress.currentStep > 1 {
            _stepProgress.currentStep -= 1
        }
        _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
        _loadData()
    }
    
    @IBAction func _handleNextStepEvent(_ sender: CustomActivityButton) {
        _validateData(_stepProgress.currentStep)
    }
    
    
    @IBAction func _handleDraftEvent(_ sender: CustomActivityButton) {
        self.showSuccessMessage("event_saved_in_draft_successfully".localized(), subtitle: kEmptyString)
        saveOrUpdateEventDraft(with: params)
    }
    
    func saveOrUpdateEventDraft(with params: [String: Any]) {
        var updated = false
        var newParams = params
        if let type = newParams["repeat"] as? String, type != "none" {
            if let dateTimeArray = newParams["repeatDatesAndTime"] as? [RepeatDateAndTimeModel] {
                newParams["repeatDatesAndTime"] = dateTimeArray.toJSON()
            }
        } else {
            newParams.removeValue(forKey: "repeatDatesAndTime")
        }
        if let idToMatch = newParams["draftId"] as? String {
            for (index, item) in Preferences.saveEventDraft.enumerated() {
                if let existingId = item["draftId"] as? String, existingId == idToMatch {
                    Preferences.saveEventDraft[index] = newParams
                    updated = true
                    break
                }
            }
        } else {
            newParams["draftId"] = Utils.randomString(length: 20)
        }

        if !updated {
            Preferences.saveEventDraft.insert(newParams, at: 0)
        }
        if !Preferences.saveEventDraft.isEmpty {
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .reloadEventDraftNotification, object: nil)
        }
    }
}

// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension CreateEventVC:  CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 70
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PromoterEventInfoCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell._setupData(object, isEdit: isEditEvent, model: eventModel)
            cell.updateCallBack = { params in
                if Utils.stringIsNullOrEmpty(params["venueId"] as? String) {
                    self.params["customVenue"] = params["customVenue"]
                    self.params["latitude"] = params["latitude"]
                    self.params["longitude"] = params["longitude"]
                } else {
                    self.params["venueId"] = params["venueId"]
                    self.params["offerId"] = params["offerId"]
                    self.params["customVenue"] = params["customVenue"]
                    self.params["image"] = params["image"]
                }
                self.params["venueType"] = params["venueType"]
                self.params["eventGallery"] = params["eventGallery"]
                self.params["date"] = params["date"]
                self.params["startTime"] = params["startTime"]
                self.params["endTime"] = params["endTime"]
                self.params["dressCode"] = params["dressCode"]
                self.params["description"] = params["description"]
                if self.eventInfoKeysAvailable(params: self.params) {
                    self._nextStepBtn.backgroundColor = ColorBrand.brandPink
                    self._nextStepBtn.isEnabled = true
                }
                self._loadData()
            }
        } else if let cell = cell as? RequirementTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String else { return }
            guard let isAllow = cellDict?[kCellTagKey] as? Bool else { return }
            guard let object = cellDict?[kCellObjectDataKey] as? [String] else { return }
            cell.setupData(title, isAllow: isAllow, list: object)
            cell.callback = { list, type in
                self.appendDataByType(type, data: list)
            }
        } else  if let cell = cell as? SocialTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [SocialAccountsModel] else { return }
            cell.setupData(object)
            cell.callback = { model in
                self.socialAccounts = model
                let socialAccountsToMention = model.map { socialAccount in
                    return [
                        "platform": socialAccount.platform,
                        "account": socialAccount.account,
                        "title": socialAccount.title
                    ]
                }
                self.params["socialAccountsToMention"] = socialAccountsToMention
                self._loadData()
            }
        } else if let cell = cell as? AvailableSpotTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.callBack = { spots, isPrivate, isConfirmation, gender, category in
                if isPrivate {
                    self.params["invitedGender"] = gender
                } else {
                    self.params.removeValue(forKey: "invitedGender")
                }
                self.params["maxInvitee"] = spots
                self.params["type"] = isPrivate ? "public" : "private"
                self.params["isConfirmationRequired"] = isConfirmation
                self.params["category"] = category
                self._loadData()
            }
            cell.seatSplitCallBack = { male, female in
                if let gender = self.params["invitedGender"] as? String, gender == "both" {
                    self.params["maleSeats"] = male
                    self.params["femaleSeats"] = female
                    self._loadData()
                } else {
                    self.params.removeValue(forKey: "maleSeats")
                    self.params.removeValue(forKey: "femaleSeats")
                    self._loadData()
                    
                }
            }
        } else if let cell = cell as? PromoterEventRepeatCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.repeatCallBack = { params in
                self.params["repeat"] = (params["repeat"] as? String)?.lowercased()
                self.params["repeatStartDate"] = params["repeatStartDate"] as? String
                self.params["repeatEndDate"] = params["repeatEndDate"] as? String
                
                if let repeatValue = self.params["repeat"] as? String,
                   let newRepeatValue = params["repeat"] as? String,
                   repeatValue != newRepeatValue {
                    self.params.removeValue(forKey: "repeatStartDate")
                    self.params.removeValue(forKey: "repeatEndDate")
                    self.params.removeValue(forKey: "repeatDays")
                    self.params.removeValue(forKey: "repeatDatesAndTime")
                }
                
                switch params["repeat"] as? String {
                case "none":
                    self.params.removeValue(forKey: "repeatStartDate")
                    self.params.removeValue(forKey: "repeatEndDate")
                    self.params.removeValue(forKey: "repeatDays")
                    self.params.removeValue(forKey: "repeatDatesAndTime")
                case "daily":
                    self.params.removeValue(forKey: "repeatDays")
                    self.params.removeValue(forKey: "repeatDatesAndTime")
                case "weekly":
                    self.params["repeatDays"] = params["repeatDays"] as? [String]
                    self.params.removeValue(forKey: "repeatDatesAndTime")
                case "specific dates", "specific-dates":
                    self.params["repeatDatesAndTime"] = [RepeatDateAndTimeModel()]
                    self.params.removeValue(forKey: "repeatDays")
                default:
                    break
                }
                
                if params["repeat"] as? String == "weekly" || params["repeat"] as? String == "daily" {
                    self.getDatesBetween(
                        startDate: self.params["repeatStartDate"] as? String ?? kEmptyString,
                        endDate: self.params["repeatEndDate"] as? String ?? kEmptyString,
                        repeatDays: self.params["repeatDays"] as? [String] ?? [],
                        startTime: self.params["startTime"] as? String ?? kEmptyString,
                        endTime: self.params["endTime"] as? String ?? kEmptyString
                    )
                }
                self._loadData()
            }

        } else if let cell = cell as? SpecificDateTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            let models = params["repeatDatesAndTime"] as? [RepeatDateAndTimeModel]
            cell.setupData(models ?? [RepeatDateAndTimeModel()],params: params )
            cell.callback = { model in
                self.params["repeatDatesAndTime"] = model
                self.params["repeat"] = "specific dates"
                self._loadData()
            }
            cell.clearAll = { [weak self] in
                guard let self = self else { return }
                self.params.removeValue(forKey: "repeatDatesAndTime")
                self.params["repeatDatesAndTime"] = [RepeatDateAndTimeModel()]
                self.params["repeat"] = "specific dates"
                self._loadData()
            }

        } else if let cell = cell as? SelectMyCircleTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object, selectedId: params["invitedCircles"] as? [String] ?? [], isSelectAll: params["selectAllCircles"] as? Bool ?? false)
            cell.selectedIdsCallback = { selected in
                self.params["invitedCircles"] = selected
            }
            cell.selectAllCallback = { isSelectAll in
                self.params["selectAllCircles"] = isSelectAll
            }

        } else if let cell = cell as? SelectMyRingsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object, selectedId: params["invitedUser"] as? [String] ?? [], isSelectAll: params["selectAllUsers"] as? Bool ?? false)
            cell.selectedIdsCallback = { selected in
                self.params["invitedUser"] = selected
            }
            cell.selectAllCallback = { isSelectAll in
                self.params["selectAllUsers"] = isSelectAll
                if isSelectAll {
                    self.params["invitedUser"] = object.map({ $0.userId })
                } else {
                    self.params["invitedUser"] = []
                }
                self._loadData()
            }
        } else if let cell = cell as? PlushOneFeatureCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            if let isAllow = params["plusOneAccepted"] as? Bool {
                self.params["plusOneAccepted"] = isAllow
            } else {
                self.params["plusOneAccepted"] = false
            }
            cell.updateCallback = { data in
                self.params["plusOneAccepted"] = data.isAllowed
                if data.isAllowed {
                    self.params["extraGuestType"] = data.guestType
                    self.params["extraGuestGender"] = data.gender
                    self.params["plusOneQty"] = data.totalGuests
                    self.params["extraGuestMaleSeats"] = data.maleGuests
                    self.params["extraGuestFemaleSeats"] = data.femaleGuests
                    self.params["extraSeatPreference"] = data.seatAllocationType
                    self.params["plusOneMandatory"] = data.isRequired
                } else {
                    self.params.removeValue(forKey: "extraGuestType")
                    self.params.removeValue(forKey: "extraGuestGender")
                    self.params.removeValue(forKey: "plusOneQty")
                    self.params.removeValue(forKey: "extraGuestMaleSeats")
                    self.params.removeValue(forKey: "extraGuestFemaleSeats")
                    self.params.removeValue(forKey: "extraSeatPreference")
                    self.params.removeValue(forKey: "plusOneMandatory")
                }
                self._loadData()
            }
        } else if let cell = cell as? PlusOneSpecificationTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.dataUpdated = { data in
                self.params["extraGuestAge"] = "\(data.minAge)-\(data.maxAge)"
                self.params["extraGuestDressCode"] = data.dressCode
                self.params["extraGuestNationality"] = data.nationality
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
                self.params["spotCloseType"] = type
                self.params["spotCloseAt"] = time
                self._loadData()
            }
        } else if let cell = cell as? FAQEditTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setup(params)
            cell.updateCallBack = { params in
                if let faq = params["faq"] as? String {
                    self.params["faq"] = faq
                }
                self._loadData()
            }
        } else if let cell = cell as? SelectPaidPassTypeTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any], let passList = cellDict?[kCellTagKey] as? [PaidPassModel] else { return }
            cell.setupData(params, pass: passList)
            cell.updateCallBack = { [weak self] params in
                guard let self = self else { return }
                if let type = params["paidPassType"] as? String {
                    self.params["paidPassType"] = type
                    if type == "override", let id = params["paidPassId"] as? String {
                        self.params["paidPassId"] = id
                    } else {
                        self.params["paidPassId"] = kEmptyString
                    }
                }
                _loadData()
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserTableCell {
            guard let parameters = cellDict?[kCellTagKey] as? [String: Any], let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            var invitedUserList = parameters["invitedUser"] as? [String]
            if let index = invitedUserList?.firstIndex(of: object.userId) {
                invitedUserList?.remove(at: index)
            } else {
                invitedUserList?.append(object.userId)
            }
            params["invitedUser"] = invitedUserList
            _loadData()
        }
    }
    
    private func appendDataByType(_ type: RequirementType, data: [String]) {
        switch type {
        case .requirementsAllowed:
            params["requirementsAllowed"] = data
        case .requirementsNotAllowed:
            params["requirementsNotAllowed"] = data
        case .benefitsIncluded:
            params["benefitsIncluded"] = data
        case .benefitsNotIncluded:
            params["benefitsNotIncluded"] = data
        }
        _loadData()
    }
    
    func eventInfoKeysAvailable(params: [String: Any]) -> Bool {
        let requiredKeys = ["venueType", "date", "startTime", "endTime", "dressCode", "description"]
        for key in requiredKeys {
            if params[key] == nil {
                _nextStepBtn.backgroundColor = UIColor(hexString: "#ADADAD")
                self._nextStepBtn.isEnabled = false
                _backProgressBtn.isHidden = true
                _saveDraftBtn.isHidden = isEditEvent
                return false
            }
        }
        return true
    }
    
    
}
