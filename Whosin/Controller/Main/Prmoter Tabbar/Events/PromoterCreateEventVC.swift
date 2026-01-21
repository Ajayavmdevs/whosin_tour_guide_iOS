import UIKit
import IQKeyboardManagerSwift
import ObjectMapper

class PromoterCreateEventVC: ChildViewController {
    
    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet private weak var _saveDraftBtn: CustomActivityButton!
    @IBOutlet private weak var _nextStepBtn: CustomActivityButton!
    @IBOutlet private weak var _backProgressBtn: CustomActivityButton!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _stepProgress: StepIndicatorView!
    @IBOutlet weak var _containerView: UIView!
    private var _currentVC: UIViewController?
    private enum ViewType: Int {
        case FormOne = 1
        case FormTwo = 2
        case FormThree = 3
        case FormFour = 4
        case FormFive = 5
    }
    
    private var _currentViewType: ViewType = .FormOne
    private var _formOne: EventPageOneVC?
    private var _formTwo: EventPageTwoVC?
    private var _formThree: EventPageThreeVC?
    private var _formFour: EventPageFourVC?
    private var _formFive: EventPageFiveVC?
    public static var eventParams: [String: Any] = [:]
    public var socialAccounts: [SocialAccountsModel] = []
    public var isEditEvent: Bool = false
    public var isDraft: Bool = false
    public var isRepost: Bool = false
    public var eventModel: PromoterEventsModel?
    private var ringMembersList: [UserDetailModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._setupController(type: self._currentViewType)
        //            _backProgressBtn.isHidden = true
        _saveDraftBtn.isHidden = true
        _nextStepBtn.isEnabled = false
        _saveDraftBtn.isHidden = isEditEvent
        IQKeyboardManager.shared.enableAutoToolbar = true
        _requestRingMember()
        if !isEditEvent {
            let insta = SocialAccountsModel()
            insta.platform = SocialPlatforms.instagram.rawValue
            socialAccounts.append(insta)
            if !Preferences.saveEventDraft.isEmpty {
                if let socialAccountsArray = PromoterCreateEventVC.eventParams["socialAccountsToMention"] as? [[String: Any]] {
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
                    if PromoterCreateEventVC.eventParams["repeat"] as? String != "none" {
                        self.getDatesBetween(startDate:PromoterCreateEventVC.eventParams["repeatStartDate"] as? String  ?? kEmptyString, endDate: PromoterCreateEventVC.eventParams["repeatEndDate"] as? String  ?? kEmptyString, repeatDays: PromoterCreateEventVC.eventParams["repeatDays"] as? [String] ?? [], startTime: PromoterCreateEventVC.eventParams["startTime"] as? String ?? kEmptyString, endTime: PromoterCreateEventVC.eventParams["endTime"] as? String ?? kEmptyString)
                    }
                    
                    if self.eventInfoKeysAvailable(params: PromoterCreateEventVC.eventParams) {
                        self._nextStepBtn.backgroundColor = ColorBrand.brandPink
                        self._nextStepBtn.isEnabled = true
                    }
                }
            } else {
                PromoterCreateEventVC.eventParams.removeAll()
            }
            _titleLabel.text = "create_your_event".localized()
        } else {
            _titleLabel.text = isRepost ? "repost_your_event".localized() : "update_your_event".localized()
            _nextStepBtn.isEnabled = true
            _nextStepBtn.backgroundColor = ColorBrand.brandPink
            if PromoterCreateEventVC.eventParams["repeat"] as? String != "specific-dates" {
                self.getDatesBetween(startDate:PromoterCreateEventVC.eventParams["repeatStartDate"] as? String  ?? kEmptyString, endDate: PromoterCreateEventVC.eventParams["repeatEndDate"] as? String  ?? kEmptyString, repeatDays: PromoterCreateEventVC.eventParams["repeatDays"] as? [String] ?? [], startTime: PromoterCreateEventVC.eventParams["startTime"] as? String ?? kEmptyString, endTime: PromoterCreateEventVC.eventParams["endTime"] as? String ?? kEmptyString)
            }
            _requestInvitedUserIds()
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestCreateEvent() {
        if let type = PromoterCreateEventVC.eventParams["venueType"] as? String, type == "venue" {
            PromoterCreateEventVC.eventParams.removeValue(forKey: "customVenue")
        }
        if let guestType = PromoterCreateEventVC.eventParams["extraGuestType"] as? String, guestType == "random" {
            PromoterCreateEventVC.eventParams["extraGuestType"] = "anyone"
        }
        if let type = PromoterCreateEventVC.eventParams["repeat"] as? String, type == "specific dates" || type == "specific-dates"  {
            PromoterCreateEventVC.eventParams["repeat"] = "specific-dates"
            if let dateTimeArray = PromoterCreateEventVC.eventParams["repeatDatesAndTime"] as? [RepeatDateAndTimeModel] {
                PromoterCreateEventVC.eventParams["repeatDatesAndTime"] = dateTimeArray.toJSON()
            }
        } else {
            PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime")
        }
        showHUD()
        WhosinServices.createInvite(params: PromoterCreateEventVC.eventParams) { [weak self] contaienr, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = contaienr else { return }
            if data.code == 1 {
                DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                    if let id = PromoterCreateEventVC.eventParams["draftId"] as? String {
                        for (index, item) in Preferences.saveEventDraft.enumerated() {
                            if let existingId = item["draftId"] as? String, existingId == id {
                                Preferences.saveEventDraft.remove(at: index)
                            }
                        }
                    }
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "draftId")
                    self.showSuccessMessage("event_created_successfully".localized(), subtitle: kEmptyString)
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                }
            }
        }
    }
    
    private func _requestInvitedUserIds() {
        guard let id = eventModel?.id else { return }
        WhosinServices.promoterEventInviteUsers(eventId: id) {[weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            PromoterCreateEventVC.eventParams["invitedUser"] = Array(Set(data.invitedUsers.toArray(ofType: String.self)))
            PromoterCreateEventVC.eventParams["selectAllUsers"] = data.selectAllUsers
            PromoterCreateEventVC.eventParams["selectAllCircles"] = data.selectAllCircles
        }
    }
    
    private func _requestRingMember() {
        WhosinServices.getMyRingMemberList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.ringMembersList = data
        }
    }
    
    private func _requestUpdateEvent() {
        if let type = PromoterCreateEventVC.eventParams["venueType"] as? String, type == "venue" {
            PromoterCreateEventVC.eventParams.removeValue(forKey: "customVenue")
        }
        if let type = PromoterCreateEventVC.eventParams["repeat"] as? String, type == "specific-dates" || type == "specific dates"{
            PromoterCreateEventVC.eventParams["repeat"] = "specific-dates"
            if let dateTimeArray = PromoterCreateEventVC.eventParams["repeatDatesAndTime"] as? [RepeatDateAndTimeModel] {
                PromoterCreateEventVC.eventParams["repeatDatesAndTime"] = dateTimeArray.toJSON()
            }
        } else { PromoterCreateEventVC.eventParams.removeValue(forKey: "repeatDatesAndTime") }
        if let guestType = PromoterCreateEventVC.eventParams["extraGuestType"] as? String, guestType == "random" {
            PromoterCreateEventVC.eventParams["extraGuestType"] = "anyone"
        }
        PromoterCreateEventVC.eventParams.removeValue(forKey: "draftId")
        showHUD()
        WhosinServices._updateMyevent(params: PromoterCreateEventVC.eventParams) { [weak self] contaienr, error in
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
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupController(type: ViewType) {
        _currentViewType = type
        
        if _currentVC != nil {
            _currentVC?.view?.removeFromSuperview()
            _currentVC = nil
        }
        
        switch type {
            
        case .FormOne:
            if _formOne == nil {
                _formOne = EventPageOneVC()
                _formOne?.getValCallback = {
                    if self.eventInfoKeysAvailable(params: PromoterCreateEventVC.eventParams) {
                        self._nextStepBtn.backgroundColor = ColorBrand.brandPink
                        self._nextStepBtn.isEnabled = true
                    }
                }
            }
            _currentVC = _formOne
            
        case .FormTwo:
            if _formTwo == nil {
                _formTwo = EventPageTwoVC()
            }
            _currentVC = _formTwo
            
        case .FormThree:
            if _formThree == nil {
                _formThree = EventPageThreeVC()
                if isEditEvent {
                    _formThree?.socialAccounts = socialAccounts
                }
                _formThree?.socialAccountsCallback = { [weak self] updatedSocialAccounts in
                    self?.socialAccounts = updatedSocialAccounts
                    print("Received updated social accounts:", updatedSocialAccounts)
                }
                
            }
            _currentVC = _formThree
            
        case .FormFour:
            if _formFour == nil {
                _formFour = EventPageFourVC()
                _formFour?.ringMembersList = ringMembersList
            }
            _currentVC = _formFour
        case .FormFive:
            if _formFive == nil {
                _formFive = EventPageFiveVC()
            }
            _currentVC = _formFive
        }
        
        guard let controller = _currentVC else { return }
        addChild(controller)
        _backProgressBtn.isHidden = _currentVC == _formOne
        _containerView.addSubview(controller.view)
        controller.view.snp.makeConstraints { maker in
            maker.edges.equalTo(_containerView)
        }
        controller.didMove(toParent: self)
    }
    
    private func _validateData(_ step: Int) {
        switch step {
        case 1:
            if Utils.stringIsNullOrEmpty(PromoterCreateEventVC.eventParams["venueId"] as? String) {
                if let customVenue = PromoterCreateEventVC.eventParams["customVenue"] as? [String: Any], customVenue.isEmpty {
                    alert(message: "select_venue_or_create_custom".localized())
                    return
                }
            }
            
            guard let dateString = PromoterCreateEventVC.eventParams["date"] as? String, !Utils.stringIsNullOrEmpty(dateString) else {
                alert(message: "please_select_a_date".localized())
                return
            }
            
            guard let timeString = PromoterCreateEventVC.eventParams["startTime"] as? String, !Utils.stringIsNullOrEmpty(timeString) else {
                alert(message: "please_select_a_time-slot".localized())
                return
            }
            
            if let selectedDateTime = Utils.stringToDate(dateString + " " + timeString, format: kFormatDateTimeLocal){
                if selectedDateTime.isExpired() {
                    alert(message: "please_select_valid_date_and_time".localized())
                    return
                }
            }
            
            
            if Utils.stringIsNullOrEmpty(PromoterCreateEventVC.eventParams["endTime"] as? String) {
                alert(message: "please_select_a_time-slot".localized())
                return
            }
            
            if Utils.stringIsNullOrEmpty(PromoterCreateEventVC.eventParams["dressCode"] as? String) {
                alert(message: "please_enter_the_dresscode".localized())
                return
            }
            
            if Utils.stringIsNullOrEmpty(PromoterCreateEventVC.eventParams["description"] as? String) {
                alert(message: "please_enter_the_description".localized())
                return
            }
            
            if _stepProgress.currentStep < 4 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
            _setupController(type: .FormTwo)
            print("")
        case 2:
            if PromoterCreateEventVC.eventParams["requirementsAllowed"] as? [String] == nil {
                alert(message: "please_enter_requirements_allowed".localized())
                return
            }
            
            if PromoterCreateEventVC.eventParams["benefitsIncluded"] as? [String] == nil {
                alert(message: "please_enter_benifits_included".localized)
                return
            }
            
            if let reqirements = PromoterCreateEventVC.eventParams["requirementsAllowed"] as? [String], reqirements.isEmpty {
                alert(message: "please_enter_requirements_allowed")
                return
            }
            
            if let benifits = PromoterCreateEventVC.eventParams["benefitsIncluded"] as? [String], benifits.isEmpty {
                alert(message: "please_enter_benifits_included".localized())
                return
            }
            if _stepProgress.currentStep < 5 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/5)"]))
            _setupController(type: .FormThree)
        case 3:
            if socialAccounts.isEmpty {
                alert(message: "Please add social account")
                return
            }
            
            for model in socialAccounts {
                if model.platform == SocialPlatforms.whosin.rawValue {
                    if !Utils.validateUrl(URL(string: model.account)) {
                        alert(message:LANGMANAGER.localizedString(forKey: "vaild_url_social_tagging", arguments: ["value": "WHOSIN"]))
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
            //            _nextStepBtn.setTitle("Next step(\(_stepProgress.currentStep)/5)")
            _nextStepBtn.setTitle(isEditEvent ? isRepost ? "repost_event".localized() : "update_event".localized() : "create_event".localized())
            _setupController(type: .FormFour)
        case 4:
            
            if (PromoterCreateEventVC.eventParams["maxInvitee"] as? Int ?? 0) < 1 {
                alert(message: "valid_spot_available_alert".localized)
                return
            }
            
            if let type = PromoterCreateEventVC.eventParams["type"] as? String, type == "public" {
                if let gender = PromoterCreateEventVC.eventParams["invitedGender"] as? String, gender == "both" {
                    if (PromoterCreateEventVC.eventParams["maleSeats"] as? Int == 0), PromoterCreateEventVC.eventParams["maleSeats"] == nil {
                        alert(message: "please_enter_the_valid_number_of_available_male_seats".localized())
                        return
                    }
                }
            }
            
            if let type = PromoterCreateEventVC.eventParams["type"] as? String, type == "public" {
                if let gender = PromoterCreateEventVC.eventParams["invitedGender"] as? String, gender == "both" {
                    if (PromoterCreateEventVC.eventParams["femaleSeats"] as? Int == 0), PromoterCreateEventVC.eventParams["femaleSeats"] == nil {
                        alert(message: "enter_number_available_female_seats".localized())
                        return
                    }
                }
            }
            
            if let type = PromoterCreateEventVC.eventParams["type"] as? String, type == "public" {
                if let gender = PromoterCreateEventVC.eventParams["invitedGender"] as? String, gender == "both" {
                    if let male = PromoterCreateEventVC.eventParams["maleSeats"] as? Int, let female = PromoterCreateEventVC.eventParams["femaleSeats"] as? Int, let totalInvited = PromoterCreateEventVC.eventParams["maxInvitee"] as? Int {
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
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "maleSeats")
                    PromoterCreateEventVC.eventParams.removeValue(forKey: "femaleSeats")
                }
            }
            
            if let type = PromoterCreateEventVC.eventParams["type"] as? String, type == "private" {
                PromoterCreateEventVC.eventParams.removeValue(forKey: "maleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "femaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "invitedGender")
                let invited = PromoterCreateEventVC.eventParams["invitedUser"] as? [String]
                let circle = PromoterCreateEventVC.eventParams["invitedCircles"] as? [String]
                if (invited == nil || invited!.isEmpty) {
                    if  (circle == nil || circle!.isEmpty) {
                        alert(message: "invite_user_or_circle_required".localized())
                        return
                    }
                }
            }
            
            if (PromoterCreateEventVC.eventParams["isConfirmationRequired"] as? Bool) == false {
                if let gender = PromoterCreateEventVC.eventParams["invitedGender"] as? String, Utils.stringIsNullOrEmpty(gender) {
                    alert(message: "select_invited_gender".localized())
                    return
                }
            }
            
            if let type = PromoterCreateEventVC.eventParams["repeat"] as? String, Utils.stringIsNullOrEmpty(type) {
                PromoterCreateEventVC.eventParams["repeat"] = "none"
            }
            
            if let type = PromoterCreateEventVC.eventParams["repeat"] as? String, type == "specific dates" {
                if let selectDate = PromoterCreateEventVC.eventParams["repeatDate"] as? String, Utils.stringIsNullOrEmpty(selectDate) {
                    alert(message: "select_date".localized())
                    return
                }
            }
            
            if let type = PromoterCreateEventVC.eventParams["repeat"] as? String, type != "none" {
                let startdate = PromoterCreateEventVC.eventParams["repeatStartDate"] as? String
                let endDate = PromoterCreateEventVC.eventParams["repeatEndDate"] as? String
                let days = PromoterCreateEventVC.eventParams["repeatDays"] as? [String]
                if Utils.stringIsNullOrEmpty(startdate) && Utils.stringIsNullOrEmpty(endDate) {
                    alert(message: "select_repetition_date_range".localized())
                    return
                }
                if type == "weekly" && (days == nil || days!.isEmpty) {
                    alert(message: "select_weekly_repetition_days".localized())
                    return
                }
                if type == "specific dates" || type == "specific-dates" {
                    guard let dateArray = PromoterCreateEventVC.eventParams["repeatDatesAndTime"] as? [RepeatDateAndTimeModel],
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
            
            if _stepProgress.currentStep < 4 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            
            if isRepost {
                _requestCreateEvent()
            } else {
                if isEditEvent {
                    _requestUpdateEvent()
                } else {
                    _requestCreateEvent()
                }
            }
            _nextStepBtn.setTitle(isEditEvent ? isRepost ? "repost_event".localized() : "update_event".localized() : "create_event".localized())
        case 5:
            
            if PromoterCreateEventVC.eventParams["plusOneAccepted"] as? Bool == false {
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestType")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "plusOneQty")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestAge")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestDressCode")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestGender")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestNationality")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestMaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestFemaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraSeatPreference")
            }
            
            if PromoterCreateEventVC.eventParams["extraSeatPreference"] as? String == "random" {
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestMaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestFemaleSeats")
            }
            
            if let plusOneQty = PromoterCreateEventVC.eventParams["plusOneQty"] as? Int, plusOneQty < 1 {
                alert(message: "please_enter_valid_plus_one_spots".localized())
                return
            }
            
            if (PromoterCreateEventVC.eventParams["extraGuestGender"] as? String) == "male" {
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestMaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestFemaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraSeatPreference")
                
            }
            
            if (PromoterCreateEventVC.eventParams["extraGuestGender"] as? String) == "female" {
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestMaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestFemaleSeats")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraSeatPreference")
                
            }
            
            if let gender = PromoterCreateEventVC.eventParams["extraGuestGender"] as? String, gender == "both", let genderType = PromoterCreateEventVC.eventParams["extraSeatPreference"] as? String, genderType == "specific" {
                if PromoterCreateEventVC.eventParams["extraGuestMaleSeats"] as? Int == 0 || PromoterCreateEventVC.eventParams["extraGuestMaleSeats"] == nil  {
                    alert(message: "please_enter_valid_male_guest_seat".localized())
                    return
                }
                
                if PromoterCreateEventVC.eventParams["extraGuestFemaleSeats"] as? Int == 0 || PromoterCreateEventVC.eventParams["extraGuestMaleSeats"] == nil {
                    alert(message: "please_enter_valid_female_guest_seats".localized())
                    return
                }
            }
            
            if let guestType = PromoterCreateEventVC.eventParams["extraGuestType"] as? String, guestType == "specific" {
                
                if let guestAge = PromoterCreateEventVC.eventParams["extraGuestAge"] as? String, Utils.stringIsNullOrEmpty(guestAge) {
                    alert(message: "please_select_guest_age_range".lowercased())
                    return
                }
                
                if let dressCode = PromoterCreateEventVC.eventParams["extraGuestDressCode"] as? String, Utils.stringIsNullOrEmpty(dressCode) {
                    alert(message: "please_enter_guest_dress_code".localized())
                    return
                }
                
                if let nationality = PromoterCreateEventVC.eventParams["extraGuestNationality"] as? String, Utils.stringIsNullOrEmpty(nationality) {
                    alert(message: "please_select_guest_nationality".localized())
                    return
                }
                
            } else {
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestAge")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestDressCode")
                PromoterCreateEventVC.eventParams.removeValue(forKey: "extraGuestNationality")
            }
            
            if isRepost {
                _requestCreateEvent()
            } else {
                if isEditEvent {
                    _requestUpdateEvent()
                } else {
                    _requestCreateEvent()
                }
            }
        default:
            print(PromoterCreateEventVC.eventParams)
        }
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
    
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleNextStepEvent(_ sender: UIButton) {
        _validateData(_stepProgress.currentStep)
    }
    
    @IBAction func _handleSaveDraftEvent(_ sender: UIButton) {
        self.showSuccessMessage("event_saved_in_draft_successfully".localized(), subtitle: kEmptyString)
        saveOrUpdateEventDraft(with: PromoterCreateEventVC.eventParams)
    }
    
    @IBAction func _handleStepBackEvent(_ sender: UIButton) {
        if _stepProgress.currentStep > 1 {
            _stepProgress.currentStep -= 1
        }
        _nextStepBtn.setTitle(LANGMANAGER.localizedString(forKey: "next_step", arguments: ["value": "\(_stepProgress.currentStep)/4)"]))
        if _currentVC == _formTwo {
            _setupController(type: .FormOne)
        } else if _currentVC == _formThree {
            _setupController(type: .FormTwo)
        } else if _currentVC == _formFour {
            _setupController(type: .FormThree)
        }
    }

}

