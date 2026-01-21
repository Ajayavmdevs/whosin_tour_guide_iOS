import UIKit
import DialCountries

class PromoterInfoCell: UITableViewCell {

    @IBOutlet private weak var _selectDateOfBirth: CustomFormField!
    @IBOutlet private weak var _firstName: CustomFormField!
    @IBOutlet private weak var _lastName: CustomFormField!
    @IBOutlet private weak var _email: CustomFormField!
    @IBOutlet private weak var _phone: CustomFormField!
    @IBOutlet private weak var _nantionality: CustomFormField!
    @IBOutlet private weak var _location: CustomFormField!
    @IBOutlet private weak var _about: CustomFormField!
    @IBOutlet private weak var _genderField: CustomFormField!
    
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
//        setup(UserDetailModel())
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ model: UserDetailModel, isEdit: Bool = false, isComplementary: Bool = false, page1: Bool = false, isLastPage: Bool = false) {
        _firstName.isHidden = !page1
        _lastName.isHidden = !page1
        _selectDateOfBirth.isHidden = page1 || !isComplementary
        _email.isHidden = page1
        _phone.isHidden = page1
        _nantionality.isHidden = page1
        _genderField.isHidden = page1
        _location.isHidden = page1
        _about.isHidden = !isLastPage
        if isLastPage {
            _firstName.isHidden = isLastPage
            _lastName.isHidden = isLastPage
            _selectDateOfBirth.isHidden = isLastPage
            _email.isHidden = isLastPage
            _phone.isHidden = isLastPage
            _nantionality.isHidden = isLastPage
            _genderField.isHidden = isLastPage
            _location.isHidden = isLastPage
            _about.isHidden = !isLastPage
        }
        
        //        _selectDateOfBirth.isHidden = !isComplementary
        _firstName.setupData("firstname".localized(), subtitle: "enter_your_first_name".localized())
        _firstName.fieldType = FormFieldType.name.rawValue
        _firstName.callback = { text in
            PromoterApplicationVC.promoterParams["first_name"] = text
        }
        _lastName.setupData("lastname".localized(), subtitle: "enter_your_last_name".localized())
        _lastName.fieldType = FormFieldType.name.rawValue
        _lastName.callback = { text in
            PromoterApplicationVC.promoterParams["last_name"] = text
        }
        _selectDateOfBirth.setupData("dob".localized(), subtitle: "enter_your_birth_date".localized())
        _selectDateOfBirth.fieldType = FormFieldType.date.rawValue
        _selectDateOfBirth.callback = { text in
            PromoterApplicationVC.promoterParams["dateOfBirth"] = text
        }
        _email.setupData("emailRequired".localized(), subtitle: "enter_your_email".localized())
        _email.fieldType = FormFieldType.email.rawValue
        _email.callback = { text in
            PromoterApplicationVC.promoterParams["email"] = text
        }
        _nantionality.setupData("national".localized(), subtitle: "select_nationality".localized())
        _nantionality.fieldType = FormFieldType.nationality.rawValue
        _nantionality.callback = { country in
            PromoterApplicationVC.promoterParams["nationality"] = country
        }
        _location.setupData("location".localized(), subtitle: "nationality".localized())
        _location.fieldType = FormFieldType.name.rawValue
        _location.callback = { text in
            PromoterApplicationVC.promoterParams["address"] = text
        }
        _about.fieldType = FormFieldType.about.rawValue
        _about.callback = { text in
            PromoterApplicationVC.promoterParams["bio"] = text
        }
        _genderField.setupData("genderReq".localized(), subtitle: "select_gender".localized())
        _genderField.fieldType = FormFieldType.gender.rawValue
        _genderField.callback = { text in
            PromoterApplicationVC.promoterParams["gender"] = text
        }
        _phone.setupData("mobile_number".localized(), subtitle: "enter_your_mobile_number".localized(), isComplementary: true)
        _phone.fieldType = FormFieldType.phone.rawValue
        _phone.callback = { text in
            PromoterApplicationVC.promoterParams["phone"] = text
        }
        _phone.dialCodecallback = { text in
            PromoterApplicationVC.promoterParams["country_code"] = text
        }
        
        let firstName = isEdit ? model.firstName : APPSESSION.userDetail?.firstName
        let lastName = isEdit ? model.lastName : APPSESSION.userDetail?.lastName
        let dateOfBirth = isEdit ? model.dateOfBirth : APPSESSION.userDetail?.dateOfBirth
        let email = isEdit ? model.email : APPSESSION.userDetail?.email
        let phone = isEdit ? model.phone : APPSESSION.userDetail?.phone
        var countryCode =  PromoterApplicationVC.promoterParams["country_code"] as? String
        let address = isEdit ? model.address : APPSESSION.userDetail?.address
        let gender = isEdit ? model.gender : APPSESSION.userDetail?.gender
        let location = isEdit ? model.location : APPSESSION.userDetail?.location
        let bio = isEdit ? model.bio : APPSESSION.userDetail?.bio
        if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["country_code"] as? String) {
            countryCode = isEdit ? model._countryCode : APPSESSION.userDetail?._countryCode
        }
        if Utils.stringIsNullOrEmpty(countryCode) {
            countryCode = Utils.getCurrentDialCode()
        }
        if isEdit { PromoterApplicationVC.promoterParams["country_code"] = countryCode }
        if isEdit { 
            if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["nationality"] as? String) {  PromoterApplicationVC.promoterParams["nationality"] = model.nationality
            }
        }

        setupEditData(field: _genderField, label: "genderReq".localized(), paramValue: PromoterApplicationVC.promoterParams["gender"] as? String ?? kEmptyString, subtile: "select_gender".localized(), modelValue: gender ?? kEmptyString, key: "gender")

        setupEditData(field: _firstName, label: "firstname".localized(), paramValue: PromoterApplicationVC.promoterParams["first_name"] as? String ?? kEmptyString, subtile: "enter_your_first_name".localized(), modelValue: firstName ?? kEmptyString, key: "first_name")
        
        setupEditData(field: _lastName, label: "lastname".localized(), paramValue: PromoterApplicationVC.promoterParams["last_name"] as? String ?? kEmptyString, subtile: "enter_your_last_name".localized(), modelValue: lastName ?? kEmptyString, key: "last_name")

        setupEditData(field: _selectDateOfBirth, label: "dob".localized(), paramValue: PromoterApplicationVC.promoterParams["dateOfBirth"] as? String ?? kEmptyString, subtile: "select_dob".localized(), modelValue: dateOfBirth ?? kEmptyString, key: "dateOfBirth")
        
        setupEditData(field: _email, label: "emailRequired".localized(), paramValue: PromoterApplicationVC.promoterParams["email"] as? String ?? kEmptyString, subtile: "enter_your_email".localized(), modelValue: email ?? kEmptyString, key: "email")

        setupEditData(field: _phone, label: "mobile_number".localized(), paramValue: PromoterApplicationVC.promoterParams["phone"] as? String ?? kEmptyString, subtile: "enter_your_mobile_number".localized(), modelValue: phone ?? kEmptyString, key: "phone", countryCode: countryCode ?? kEmptyString)
        
        if !Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["country_code"] as? String) {
            setupEditData(field: _phone, label: "mobile_number".localized(), paramValue: PromoterApplicationVC.promoterParams["phone"] as? String ?? kEmptyString, subtile: "enter_your_mobile_number".localized(), modelValue: phone ?? kEmptyString, key: "phone", countryCode: PromoterApplicationVC.promoterParams["country_code"] as? String ?? kEmptyString)
        } else {
            setupEditData(field: _phone, label: "mobile_number".localized(), paramValue: PromoterApplicationVC.promoterParams["phone"] as? String ?? kEmptyString, subtile: "enter_your_mobile_number".localized(), modelValue: phone ?? kEmptyString, key: "phone", countryCode: countryCode ?? kEmptyString)
        }
        
        if !Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["nationality"] as? String) {
            let dialCode = Utils.getCountryCodeByName(byCountryName: PromoterApplicationVC.promoterParams["nationality"] as? String ?? kEmptyString) ?? Country.getCurrentCountry()?.code ?? "AE"
            let flag = Utils.getCountyFlag(code: dialCode)
            _nantionality.setupEdit("national".localized(), text: "\(flag) \(PromoterApplicationVC.promoterParams["nationality"] as? String ?? kEmptyString)", subtitle: "select_nationality".localized())
        } else {
            let dialCode = Utils.getCountryCodeByName(byCountryName: PromoterApplicationVC.promoterParams["nationality"] as? String ?? kEmptyString) ?? Country.getCurrentCountry()?.code ?? "AE"
            let flag = Utils.getCountyFlag(code: dialCode)
            _nantionality.setupEdit("national".localized(), text: isEdit ? "\(flag)\(model.nationality)" : kEmptyString, subtitle: "select_nationality".localized())
        }

        setupEditData(field: _location, label: "location".localized(), paramValue: PromoterApplicationVC.promoterParams["address"] as? String ?? kEmptyString, subtile: "enter_your_location".localized(), modelValue: address ?? kEmptyString, key: "address")

        setupEditData(field: _about, label: "What_do_you_love_to_do".localized(), paramValue: PromoterApplicationVC.promoterParams["bio"] as? String ?? kEmptyString, subtile: "bio_info".localized(), modelValue: bio ?? kEmptyString, key: "bio")
    }

    
    private func setupEditData(field: CustomFormField, label: String, paramValue: String, subtile: String, modelValue: String, key: String, countryCode: String = kEmptyString) {
        if Utils.stringIsNullOrEmpty(paramValue) {
            field.setupEdit(label, text: modelValue, subtitle: subtile, countryCode: countryCode)
            PromoterApplicationVC.promoterParams[key] = modelValue
        } else {
            field.setupEdit(label, text: paramValue, subtitle: subtile, countryCode: countryCode)
            PromoterApplicationVC.promoterParams[key] = paramValue
        }
    }
    
}
