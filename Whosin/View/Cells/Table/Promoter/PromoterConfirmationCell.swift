import UIKit

class PromoterConfirmationCell: UITableViewCell {
    
    @IBOutlet weak var _checkValidationView: UIView!
    @IBOutlet weak var _checkConditionBtn: UIButton!
    @IBOutlet weak var _applyNowBtn: CustomActivityButton!
    @IBOutlet weak var _desclaimer: CustomLabel!
    private var _imagesArray: [UIImage] = []
    private var _profileImage: UIImage?
    private var isRingType: Bool = false
    private var isEdit: Bool = false
    public var callBack: ((Bool) -> Void)?
    private var isChecked: Bool = false {
        didSet {
            _checkConditionBtn.isSelected = isChecked
        }
    }
    
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
        setupDisclaimerLabel()
    }
    
    func setupDisclaimerLabel() {
        let fullText = "disclamer_policy_apply".localized()
        let attributedString = NSMutableAttributedString(string: fullText)
        let linkRange = (fullText as NSString).range(of: "here".localized())
        attributedString.addAttribute(.foregroundColor, value: ColorBrand.brandPink, range: linkRange)
        attributedString.addAttribute(.font, value: FontBrand.SFsemiboldFont(size: 13), range: linkRange)
        _desclaimer.attributedText = attributedString
        _desclaimer.isUserInteractionEnabled = true
        _desclaimer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel)))
        
    }
    
    @objc func handleTapOnLabel() {
        let vc = INIT_CONTROLLER_XIB(WebViewController.self)
        vc.htmlTxt = APPSETTING.appSetiings?.pages.filter({ $0.title == "Terms & Condition" }).first?.descriptions
        vc.viewTitle = "terms_condition".localized()
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupData(_ isCompelmantry: Bool = false, isEdit: Bool = false, images: [UIImage] = [], profileImage: UIImage?) {
        _profileImage = profileImage
        _imagesArray = images
        self.isEdit = isEdit
        _checkValidationView.isHidden = isEdit
        _desclaimer.isHidden = isEdit
        _applyNowBtn.setTitle(isEdit ? "update".localized() : "apply_now".localized())
        isRingType = isCompelmantry
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func requestRingPromoter() {
        parentBaseController?.showHUD()
        WhosinServices.applyRingPromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            parentBaseController?.hideHUD(error: error)
            PromoterApplicationVC.promoterParams.removeAll()
            self.parentBaseController?.showSuccessMessage("complemantary_request_sent_successfully".localized(), subtitle: kEmptyString)
            self.parentViewController?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func requestPromoter() {
        parentBaseController?.showHUD()
        WhosinServices.applyPromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            parentBaseController?.hideHUD(error: error)
            PromoterApplicationVC.promoterParams.removeAll()
            self.parentBaseController?.showSuccessMessage("promoter_request_sent_successfully".localized(), subtitle: kEmptyString)
            self.parentViewController?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func requestEditRingPromoter() {
        parentBaseController?.showHUD()
        WhosinServices.updateRingPromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            parentBaseController?.hideHUD(error: error)
            PromoterApplicationVC.promoterParams.removeAll()
            NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
//            self.callBack?()
            self.parentViewController?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func requestEditPromoter() {
        parentBaseController?.showHUD()
        WhosinServices.updatePromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            parentBaseController?.hideHUD(error: error)
            PromoterApplicationVC.promoterParams.removeAll()
            NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
//            self.callBack?()
            self.parentViewController?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func _requestUploadProfileImage(_ image: UIImage?, isProfile: Bool = false) {
        guard let image = image else { return }
        parentBaseController?.showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            parentBaseController?.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            parentBaseController?.view.makeToast("image_updated_successfully".localized())
            if isProfile {
                PromoterApplicationVC.promoterParams["image"] = photoUrl.url
                if _imagesArray.count == 1 {
                    _requestUploadProfileImage(_imagesArray.first)
                } else if _imagesArray.count > 1 {
                    _requestUploadProfileImageArray(_imagesArray)
                } else {
                    _createOrUpdate()
                }
            } else {
                var images = PromoterApplicationVC.promoterParams["images"] as? [String]
                images?.append(photoUrl.url)
                PromoterApplicationVC.promoterParams["images"] = images
            }
            self._createOrUpdate()
        }
    }
    
    private func _createOrUpdate() {
        if let images = PromoterApplicationVC.promoterParams["images"] as? [String] {
            if images.isEmpty {
                parentBaseController?.alert(message: "please_minimum_3_pictures_are_required".localized())
                return
            } else if images.count < 3 {
                parentBaseController?.alert(message: "please_minimum_3_pictures_are_required".localized())
                return
            }
        } else { return }
        
        if let profile = PromoterApplicationVC.promoterParams["image"] as? String, Utils.stringIsNullOrEmpty(profile) {
            PromoterApplicationVC.promoterParams["image"] = APPSESSION.userDetail?.image
        } else if PromoterApplicationVC.promoterParams["image"] as? String == nil {
            PromoterApplicationVC.promoterParams["image"] = APPSESSION.userDetail?.image
        }
        
        if isRingType {
            isEdit ? requestEditRingPromoter() : requestRingPromoter()
        } else {
            isEdit ? requestEditPromoter() : requestPromoter()
        }
    }
    
    private func _requestUploadProfileImageArray(_ image: [UIImage]?) {
        guard let image = image else { return }
        parentBaseController?.showHUD()
        WhosinServices.uploadProfileImageArray(image: image) { [weak self] model, error in
            guard let self = self else { return }
            parentBaseController?.hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            parentBaseController?.view.makeToast("image_updated_successfully".localized())
            var images: [String] = PromoterApplicationVC.promoterParams["images"] as? [String] ?? []
            images.append(contentsOf: photoUrl.urlList)
            PromoterApplicationVC.promoterParams["images"] = images
            self._createOrUpdate()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCheckEvnet(_ sender: Any) {
        isChecked.toggle()
        callBack?(isChecked)
    }
    
    @IBAction private func _handleApplyNowEvent(_ sender: CustomActivityButton) {
        endEditing(true)
//        self.validations()
    }
    
    private func validations() {
        let promoterImages = PromoterApplicationVC.promoterParams["images"] as? [String] ?? []
        let totalImageCount = promoterImages.count + _imagesArray.count
        let profile = PromoterApplicationVC.promoterParams["image"] as? String
        if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.image) {
            if _profileImage == nil {
                parentBaseController?.alert(message: "please_update_profile_image".localized())
                return
            }
        }
        
        if totalImageCount < 3 {
            parentBaseController?.alert(message: "please_minimum_3_pictures_are_required".localized())
            return
        }
        
        let requiredFields = [
            "first_name": "enter_first_name".localized(),
            "last_name": "enter_last_name".localized(),
            "address": "your_first_address".localized(),
            "nationality": "please_select_nationality".localized(),
            "country_code": "please_enter_country_code".localized(),
            "email": "please_enter_email".localized(),
            "phone": "please_enter_phone".localized(),
            "instagram": "please_enter_instagram".localized()
        ]

        if isRingType {
            if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["dateOfBirth"] as? String) {
                parentBaseController?.alert(message: "please_select_date_of_birth".localized())
                return
            }
        }
        
        for (key, message) in requiredFields {
            if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams[key] as? String) {
                parentBaseController?.alert(message: message)
                return
            }
        }
        
        if PromoterApplicationVC.promoterParams["bio"] as? String == "bio_info".localized() {
            PromoterApplicationVC.promoterParams["bio"] = kEmptyString
        }
        
        if !Utils.isValidEmail(PromoterApplicationVC.promoterParams["email"] as? String) {
            parentBaseController?.alert(message: "invalid_email".localized())
            return
        }
        
        if let countryCode = Utils.getCountryCode(for: PromoterApplicationVC.promoterParams["country_code"] as? String ?? kEmptyString) {
            if !Utils.isValidNumber(PromoterApplicationVC.promoterParams["phone"] as? String ?? kEmptyString, countryCode) {
                parentBaseController?.alert(message: "phone_number_is_not_valid".localized())
                return
            }
        } else {
            parentBaseController?.alert(message: "phone_number_is_not_valid".localized())
            return
        }
        
//        if !Utils.validateInstagramProfileUrl(URL(string: PromoterApplicationVC.promoterParams["instagram"] as? String ?? "")) {
//            parentBaseController?.alert(message: "Please enter valid instagram profile link.")
//            return
//        }

        
        if !isEdit && !isChecked {
            parentBaseController?.alert(message: "please_check_terms_for_apply".localized())
            return
        }
        
        
        
        if _profileImage != nil && !_imagesArray.isEmpty {
            _requestUploadProfileImage(_profileImage, isProfile: true)
//            _requestUploadProfileImageArray(_imagesArray)
        } else if _profileImage != nil {
            _requestUploadProfileImage(_profileImage, isProfile: true)
        } else {
            if _imagesArray.count == 1 {
                _requestUploadProfileImage(_imagesArray.first)
            } else if _imagesArray.count > 1 {
                _requestUploadProfileImageArray(_imagesArray)
            } else {
                _createOrUpdate()
            }
        }
    }
    
    
}
