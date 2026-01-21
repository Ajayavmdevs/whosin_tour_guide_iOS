import UIKit
import IQKeyboardManagerSwift
import RealmSwift


class PromoterApplicationVC: ChildViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var _nextBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _titleLabel: CustomLabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet weak var _stepProgress: StepIndicatorView!
    @IBOutlet weak var _backProgressBtn: CustomActivityButton!
    @IBOutlet weak var _nextStepBtn: CustomActivityButton!
    private let kCellIdentifierIntro = String(describing: PromoterIntroCell.self)
    private let kCellIdentifierInfo = String(describing: PromoterInfoCell.self)
    private let kCellIdentifierSocial = String(describing: PromoterSocialCell.self)
    private let kCellIdentifierConfirmation = String(describing: PromoterConfirmationCell.self)
    private let kCellIdentifierComplimentary = String(describing: UploadPicturesCell.self)
    public var isComlementry: Bool = false
    public var referredById: String = kEmptyString
    public var isEdit: Bool = false
    public var detailModel: UserDetailModel?
    private var _imagesArray: [UIImage] = []
    private var _profileImages: UIImage? = nil
    public static var promoterParams: [String: Any] = [:]
    public static var reloadOnBack: (() -> Void)?
    private var isChecked: Bool = false
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        hideNavigationBar()
        PromoterApplicationVC.promoterParams.removeAll()
        _titleLabel.text = isEdit ? "edit_your_profile".localized() : isComlementry ? LANGMANAGER.localizedString(forKey: "about_you", arguments: ["value": "\(_stepProgress.currentStep)"]) : "join_our_promoters_platform".localized()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupUi()
        if !isEdit {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            self.navigationController?.delegate = self
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self.navigationController?.viewControllers.first {
            showUnsavedChangesAlert()
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            showUnsavedChangesAlert()
            return false
        }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func requestRingPromoter() {
        showHUD()
        WhosinServices.applyRingPromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            hideHUD(error: error)
            guard let data = contaienr else { return }
            PromoterApplicationVC.promoterParams.removeAll()
            self.showSuccessMessage("show_intrest_promoter".localized(), subtitle: kEmptyString)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func requestPromoter() {
        showHUD()
        WhosinServices.applyPromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            hideHUD(error: error)
            guard let data = contaienr else { return }
            PromoterApplicationVC.promoterParams.removeAll()
            self.showSuccessMessage("show_intrest_promoter".localized(), subtitle: kEmptyString)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func requestEditRingPromoter() {
        showHUD()
        WhosinServices.updateRingPromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            hideHUD(error: error)
            guard let data = contaienr else { return }
            PromoterApplicationVC.promoterParams.removeAll()
            NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
            NotificationCenter.default.post(name: kRelaodActivitInfo, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func requestEditPromoter() {
        showHUD()
        WhosinServices.updatePromoter(params: PromoterApplicationVC.promoterParams) { [weak self] contaienr, error in
            guard let self = self else { return}
            hideHUD(error: error)
            guard let data = contaienr else { return }
            PromoterApplicationVC.promoterParams.removeAll()
            NotificationCenter.default.post(name: .changeUserUpdateState, object: nil)
            NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func _requestUploadProfileImage(_ image: UIImage?, isProfile: Bool = false) {
        guard let image = image else { return }
        showHUD()
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            view.makeToast("image_updated_successfully".localized())
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
    
    private func _requestUploadProfileImageArray(_ image: [UIImage]?) {
        guard let image = image else { return }
        showHUD()
        WhosinServices.uploadProfileImageArray(image: image) { [weak self] model, error in
            guard let self = self else { return }
            hideHUD(error: error)
            guard let photoUrl = model?.data else { return }
            view.makeToast("image_updated_successfully".localized())
            var images: [String] = PromoterApplicationVC.promoterParams["images"] as? [String] ?? []
            images.append(contentsOf: photoUrl.urlList)
            PromoterApplicationVC.promoterParams["images"] = images
            self._createOrUpdate()
        }
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
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
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self)
        if !Utils.stringIsNullOrEmpty(referredById) {
            PromoterApplicationVC.promoterParams["referredBy"] = referredById
        }
        _nextStepBtn.backgroundColor = ColorBrand.brandPink
        _nextStepBtn.isEnabled = true
        _loadData()
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierIntro, kCellNibNameKey: kCellIdentifierIntro, kCellClassKey: PromoterIntroCell.self, kCellHeightKey: PromoterIntroCell.height],
            [kCellIdentifierKey: kCellIdentifierComplimentary, kCellNibNameKey: kCellIdentifierComplimentary, kCellClassKey: UploadPicturesCell.self, kCellHeightKey: UploadPicturesCell.height],
            [kCellIdentifierKey: kCellIdentifierInfo, kCellNibNameKey: kCellIdentifierInfo, kCellClassKey: PromoterInfoCell.self, kCellHeightKey: PromoterInfoCell.height],
            [kCellIdentifierKey: kCellIdentifierSocial, kCellNibNameKey: kCellIdentifierSocial, kCellClassKey: PromoterSocialCell.self, kCellHeightKey: PromoterSocialCell.height],
            [kCellIdentifierKey: kCellIdentifierConfirmation, kCellNibNameKey: kCellIdentifierConfirmation, kCellClassKey: PromoterConfirmationCell.self, kCellHeightKey: PromoterConfirmationCell.height]
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _backProgressBtn.isHidden = true
        _titleLabel.text = isEdit ? "edit_your_profile".localized() : isComlementry ? LANGMANAGER.localizedString(forKey: "about_you", arguments: ["value": "\(_stepProgress.currentStep)"]) : "join_our_promoters_platform".localized()
        switch _stepProgress.currentStep {
        case 1:
            _backProgressBtn.isHidden = true
            //            cellData.append([
            //                kCellIdentifierKey: kCellIdentifierIntro,
            //                kCellTagKey: detailModel,
            //                kCellObjectDataKey: "Intro",
            //                kCellClassKey: PromoterIntroCell.self,
            //                kCellHeightKey: PromoterIntroCell.height
            //            ])
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierComplimentary,
                kCellTagKey: detailModel,
                kCellObjectDataKey: "Complimentary",
                kCellClassKey: UploadPicturesCell.self,
                kCellHeightKey: UploadPicturesCell.height
            ])
            cellData.append([
                kCellIdentifierKey: kCellIdentifierInfo,
                kCellTagKey: detailModel,
                kCellObjectDataKey: "Info",
                kCellClassKey: PromoterInfoCell.self,
                kCellHeightKey: PromoterInfoCell.height
            ])
        case 2:
            cellData.append([
                kCellIdentifierKey: kCellIdentifierInfo,
                kCellTagKey: detailModel,
                kCellObjectDataKey: "Info",
                kCellClassKey: PromoterInfoCell.self,
                kCellHeightKey: PromoterInfoCell.height
            ])
        case 3:
            cellData.append([
                kCellIdentifierKey: kCellIdentifierSocial,
                kCellTagKey: detailModel,
                kCellObjectDataKey: "Social",
                kCellClassKey: PromoterSocialCell.self,
                kCellHeightKey: PromoterSocialCell.height
            ])
        case 4 :
            cellData.append([
                kCellIdentifierKey: kCellIdentifierInfo,
                kCellTagKey: detailModel,
                kCellObjectDataKey: "Info",
                kCellClassKey: PromoterInfoCell.self,
                kCellHeightKey: PromoterInfoCell.height
            ])
            if !isEdit {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierConfirmation,
                    kCellTagKey: kCellIdentifierConfirmation,
                    kCellObjectDataKey: "Confirmation",
                    kCellClassKey: PromoterConfirmationCell.self,
                    kCellHeightKey: PromoterConfirmationCell.height
                ])
            }
        default:
            print("Value is not 1, 2, 3, or 4")
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    private func validations() {
        let promoterImages = PromoterApplicationVC.promoterParams["images"] as? [String] ?? []
        let totalImageCount = promoterImages.count + _imagesArray.count
        let profile = PromoterApplicationVC.promoterParams["image"] as? String
        if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.image) {
            if _profileImages == nil {
                alert(message: "please_update_profile_image".localized())
                return
            }
        }
        
        if totalImageCount < 3 {
            alert(message: "please_minimum_3_pictures_are_required".localized())
            return
        }
        
        let requiredFields = [
            "first_name": "enter_first_name".localized(),
            "last_name": "enter_last_name".localized(),
            //            "address": "Please enter address",
            "nationality": "please_select_nationality".localized(),
            "country_code": "please_enter_country_code".localized(),
            "email": "please_enter_email".localized(),
            "phone": "please_enter_phone".localized(),
            "instagram": "please_enter_instagram_profile".localized()
        ]
        
        if isComlementry {
            if let dateOfBirth = PromoterApplicationVC.promoterParams["dateOfBirth"] as? String, !Utils.stringIsNullOrEmpty(dateOfBirth) {
                PromoterApplicationVC.promoterParams["dateOfBirth"] = dateOfBirth
            } else {
                alert(message: "please_select_date_of_birth".localized())
                return
            }
        }

        
        for (key, message) in requiredFields {
            if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams[key] as? String) {
                alert(message: message)
                return
            }
        }
        
        if PromoterApplicationVC.promoterParams["bio"] as? String == "Travel, Fashion, Modelling, Going out, Discovering, Sporting" {
            PromoterApplicationVC.promoterParams["bio"] = kEmptyString
        }
        
        if !Utils.isValidEmail(PromoterApplicationVC.promoterParams["email"] as? String) {
            alert(message: "invalid_email".localized())
            return
        }
        
        if let countryCode = Utils.getCountryCode(for: PromoterApplicationVC.promoterParams["country_code"] as? String ?? kEmptyString) {
            if !Utils.isValidNumber(PromoterApplicationVC.promoterParams["phone"] as? String ?? kEmptyString, countryCode) {
                alert(message: "phone_number_is_not_valid".localized())
                return
            }
        } else {
            alert(message: "phone_number_is_not_valid".localized())
            return
        }
        
//        if !Utils.validateInstagramProfileUrl(URL(string: PromoterApplicationVC.promoterParams["instagram"] as? String ?? "")) {
//            alert(message: "Please enter valid instagram profile link.")
//            return
//        }
        
        
        if !isEdit && !isChecked {
            alert(message: "please_check_terms_for_apply".localized())
            return
        }
        
        
        
        if _profileImages != nil && !_imagesArray.isEmpty {
            _requestUploadProfileImage(_profileImages, isProfile: true)
        } else if _profileImages != nil {
            _requestUploadProfileImage(_profileImages, isProfile: true)
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
    
    private func _createOrUpdate() {
        if let images = PromoterApplicationVC.promoterParams["images"] as? [String] {
            if images.isEmpty {
                alert(message: "please_minimum_3_pictures_are_required".localized())
                return
            } else if images.count < 3 {
                alert(message: "please_minimum_3_pictures_are_required".localized())
                return
            }
        } else { return }
        
        if let profile = PromoterApplicationVC.promoterParams["image"] as? String, Utils.stringIsNullOrEmpty(profile) {
            PromoterApplicationVC.promoterParams["image"] = APPSESSION.userDetail?.image
        } else if PromoterApplicationVC.promoterParams["image"] as? String == nil {
            PromoterApplicationVC.promoterParams["image"] = APPSESSION.userDetail?.image
        }
        
        if isComlementry {
            isEdit ? requestEditRingPromoter() : requestRingPromoter()
        } else {
            isEdit ? requestEditPromoter() : requestPromoter()
        }
    }
    
    private func showUnsavedChangesAlert() {
        alert(title: "unsaved_changes".localized(), message: "will_lose_all_infomration_confirmation".localized(), okActionTitle: "yes") { action in
            PromoterApplicationVC.reloadOnBack?()
            self.navigationController?.popViewController(animated: true)
        } cancelHandler: { _ in
            self.dismiss(animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {
                self._nextBtnBottomConstraint.constant = keyboardHeight //- self._nextStepBtn.frame.height
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self._nextBtnBottomConstraint.constant = 20
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        guard _stepProgress.currentStep > 1 else {
            if isEdit {
                PromoterApplicationVC.reloadOnBack?()
                self.navigationController?.popViewController(animated: true)
            } else {
                showUnsavedChangesAlert()
            }
            return
        }
        if _stepProgress.currentStep > 1 {
            _stepProgress.currentStep -= 1
        }
        _nextStepBtn.setTitle("next".localized())
        _loadData()
    }
    
    @IBAction func _handleStepBackEvent(_ sender: UIButton) {
        if _stepProgress.currentStep > 1 {
            _stepProgress.currentStep -= 1
        }
        _nextStepBtn.setTitle("next".localized())
        _loadData()
    }
    
    @IBAction func _handleStepNextEvent(_ sender: UIButton) {
        switch _stepProgress.currentStep {
        case 1:
            let promoterImages = PromoterApplicationVC.promoterParams["images"] as? [String] ?? []
            let totalImageCount = promoterImages.count + _imagesArray.count
            let profile = PromoterApplicationVC.promoterParams["image"] as? String
            if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.image) {
                if _profileImages == nil {
                    alert(message: "please_update_profile_image".localized())
                    return
                }
            }
            
            if totalImageCount < 3 {
                alert(message: "please_minimum_3_pictures_are_required".localized())
                return
            }
            
            let requiredFields = [
                "first_name": "enter_first_name".localized(),
                "last_name": "enter_last_name".localized()
            ]
            for (key, message) in requiredFields {
                if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams[key] as? String) {
                    alert(message: message)
                    return
                }
            }
            
            if _stepProgress.currentStep < 4 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle("next".localized())
            _loadData()
            
        case 2:
            let requiredFields = [
                "nationality": "please_select_nationality".localized(),
                "country_code": "please_enter_country_code".localized(),
                "phone": "please_enter_phone".localized(),
                "email": "invalid_email".localized()
            ]
            
            if !Utils.isValidEmail(PromoterApplicationVC.promoterParams["email"] as? String) {
                alert(message: "invalid_email".localized())
                return
            }
            
            if isComlementry {
                if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["dateOfBirth"] as? String) {
                    alert(message: "please_select_date_of_birth".localized())
                    return
                }
            }
            
            for (key, message) in requiredFields {
                if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams[key] as? String) {
                    alert(message: message)
                    return
                }
                if key == "phone" {
                    if let countryCode = Utils.getCountryCode(for: PromoterApplicationVC.promoterParams["country_code"] as? String ?? kEmptyString) {
                        if !Utils.isValidNumber(PromoterApplicationVC.promoterParams["phone"] as? String ?? kEmptyString, countryCode) {
                            alert(message: "phone_number_is_not_valid".localized())
                            return
                        }
                    } else {
                        alert(message: "phone_number_is_not_valid".localized())
                        return
                    }
                }
            }
            
            
            if _stepProgress.currentStep < 3 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
                                  _nextStepBtn.setTitle("next".localized())
            _loadData()
        case 3:
            if Utils.stringIsNullOrEmpty(PromoterApplicationVC.promoterParams["instagram"] as? String) {
                alert(message: "please_enter_instagram_profile".localized())
                return
            }
            if _stepProgress.currentStep < 4 {
                _stepProgress.currentStep = _stepProgress.currentStep + 1
            }
            _nextStepBtn.setTitle(isEdit ? "update".localized() : "apply_now".localized())
            _loadData()
        case 4:
            if PromoterApplicationVC.promoterParams["bio"] as? String == "Travel, Fashion, Modelling, Going out, Discovering, Sporting" {
                PromoterApplicationVC.promoterParams["bio"] = kEmptyString
            }
            
            validations()
        default:
            print("Value is not 1, 2, 3, or 4")
        }
    }
    
}

// --------------------------------------
// MARK: Delegate method
// --------------------------------------

extension PromoterApplicationVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 50
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
        if let cell = cell as? PromoterIntroCell {
            cell.setupData(isEdit ? "edit_your_profile".localized() : isComlementry ? "join_our_complimentary_ring".localized() : "join_our_promoters_platform".localized())
        } else if let cell = cell as? UploadPicturesCell {
            if isEdit {
                guard let object = cellDict?[kCellTagKey] as? UserDetailModel else { return }
                let images = object.images.toArray(ofType: String.self).filter { !$0.isEmpty }
                cell.setupData(images, isEdit: true, profile: detailModel, profileImage: self._profileImages)
            } else {
                cell.setupData([], profile: detailModel, profileImage: self._profileImages)
            }
            cell.profileImageCallback = { image in
                self._profileImages = image
            }
            cell.imageCallback = { images in
                self._imagesArray = images
                if let imageArray = PromoterApplicationVC.promoterParams["images"] as? [String] {
                    self.detailModel?.images = StringListTransform().transformFromJSON(PromoterApplicationVC.promoterParams["images"]) ?? List<String>()
                }
                self._loadData()
            }
        } else  if let  cell = cell as? PromoterInfoCell {
            if isEdit {
                guard let object = cellDict?[kCellTagKey] as? UserDetailModel else { return }
                cell.setup(object, isEdit: true, isComplementary: isComlementry, page1: _stepProgress.currentStep == 1, isLastPage: _stepProgress.currentStep == 4)
            } else {
                cell.setup(UserDetailModel(), isComplementary: isComlementry, page1: _stepProgress.currentStep == 1, isLastPage: _stepProgress.currentStep == 4)
            }
        } else if let cell = cell as? PromoterSocialCell {
            if isEdit {
                guard let object = cellDict?[kCellTagKey] as? UserDetailModel else { return }
                cell.setup(object, isEdit: true)
            } else {
                cell.setup(UserDetailModel())
            }
        } else if let cell = cell as? PromoterConfirmationCell {
            cell.setupData(isComlementry, isEdit: isEdit, images: _imagesArray, profileImage: _profileImages ?? nil)
            cell.callBack = { value in
                self.isChecked = value
            }
        }
    }
}

