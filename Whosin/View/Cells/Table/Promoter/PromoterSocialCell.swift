import UIKit

class PromoterSocialCell: UITableViewCell {
    
    @IBOutlet private weak var _instagramField: CustomFormField!
    @IBOutlet private weak var _tiktokField: CustomFormField!
    @IBOutlet private weak var _youTubeField: CustomFormField!
    @IBOutlet private weak var _facebookFeild: CustomFormField!
    private var userModel: UserDetailModel?
    private var isEdit: Bool = false
    
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
        let tapInstagram = UITapGestureRecognizer(target: self, action: #selector(openInstagram))
        let tapTiktok = UITapGestureRecognizer(target: self, action: #selector(openTiktok))
        let tapYoutube = UITapGestureRecognizer(target: self, action: #selector(openYoutube))
        let tapFacebook = UITapGestureRecognizer(target: self, action: #selector(openFacebook))
        _instagramField.addGestureRecognizer(tapInstagram)
        _tiktokField.addGestureRecognizer(tapTiktok)
        _youTubeField.addGestureRecognizer(tapYoutube)
        _facebookFeild.addGestureRecognizer(tapFacebook)
//        setup(UserDetailModel())
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setup(_ model: UserDetailModel?, isEdit: Bool = false, isBgChange: Bool = false) {
        self.isEdit = isEdit
//        if isEdit {
//            if !Utils.stringIsNullOrEmpty(model?.instagram) {
//                PromoterApplicationVC.promoterParams["instagram"] = model?.instagram
//            }
//                        
//            if !Utils.stringIsNullOrEmpty(model?.tiktok) {
//                PromoterApplicationVC.promoterParams["tiktok"] = model?.tiktok
//            }
//            if !Utils.stringIsNullOrEmpty(model?.youtube) {
//                PromoterApplicationVC.promoterParams["youtube"] = model?.youtube
//            }
//            if !Utils.stringIsNullOrEmpty(model?.facebook) {
//                PromoterApplicationVC.promoterParams["facebook"] = model?.facebook
//            }
//        }
        let instagram = isEdit ? model?.instagram : APPSESSION.userDetail?.instagram
        let tiktok = isEdit ? model?.tiktok : APPSESSION.userDetail?.tiktok
        let youtube = isEdit ? model?.youtube : APPSESSION.userDetail?.youtube
        let facebook = isEdit ? model?.facebook : APPSESSION.userDetail?.facebook

        if isBgChange {
            _instagramField._socialBgView.backgroundColor = UIColor(hexString: "#4E0054")
            _tiktokField._socialBgView.backgroundColor = UIColor(hexString: "#4E0054")
            _youTubeField._socialBgView.backgroundColor = UIColor(hexString: "#4E0054")
            _facebookFeild._socialBgView.backgroundColor = UIColor(hexString: "#4E0054")
        }
        _instagramField.fieldType = FormFieldType.social.rawValue
        _tiktokField.fieldType = FormFieldType.social.rawValue
        _youTubeField.fieldType = FormFieldType.social.rawValue
        _facebookFeild.fieldType = FormFieldType.social.rawValue
        setupEditData(field: _instagramField, icon: "icon_instagram", paramValue: PromoterApplicationVC.promoterParams["instagram"] as? String ?? kEmptyString, subtile: "add_your_instagram_handle".localized(), modelValue: instagram ?? kEmptyString, key: "instagram")
        
        setupEditData(field: _tiktokField, icon: "icon_tiktok", paramValue: PromoterApplicationVC.promoterParams["tiktok"] as? String ?? kEmptyString, subtile: "add_your_tiktok_account_optional".localized(), modelValue: tiktok ?? kEmptyString, key: "tiktok")

        setupEditData(field: _youTubeField, icon: "icon_youtube", paramValue: PromoterApplicationVC.promoterParams["youtube"] as? String ?? kEmptyString, subtile: "add_your_youtube_channel_optional".localized(), modelValue: youtube ?? kEmptyString, key: "youtube")
        
        setupEditData(field: _facebookFeild, icon: "icon_facebook", paramValue: PromoterApplicationVC.promoterParams["facebook"] as? String ?? kEmptyString, subtile: "add_your_facebook_account_optional".localized(), modelValue: facebook ?? kEmptyString, key: "facebook")
        _instagramField.callback = { text in
            PromoterApplicationVC.promoterParams["instagram"] = text
        }
        _tiktokField.callback = { text in
            PromoterApplicationVC.promoterParams["tiktok"] = text
        }
        _youTubeField.callback = { text in
            PromoterApplicationVC.promoterParams["youtube"] = text
        }
        _facebookFeild.callback = { text in
            PromoterApplicationVC.promoterParams["facebook"] = text
        }
    }
    
    private func setupEditData(field: CustomFormField, icon: String, paramValue: String, subtile: String, modelValue: String, key: String) {
        if Utils.stringIsNullOrEmpty(paramValue) {
            field.setupData(modelValue, subtitle: subtile, icon: icon, isEnable: true)
            PromoterApplicationVC.promoterParams[key] = modelValue
        } else {
            field.setupData(paramValue, subtitle: subtile, icon: icon, isEnable: true)
            PromoterApplicationVC.promoterParams[key] = paramValue
        }
    }
    
    public func setupData(_ model: UserDetailModel) {
        userModel = model
        if !Utils.stringIsNullOrEmpty(model.instagram) {
            _instagramField.fieldType = FormFieldType.socialForm.rawValue
            _instagramField.setupData(model.instagram, icon: "icon_instagram", isEnable: false)
        } else {
            _instagramField.isHidden = true
        }
        if !Utils.stringIsNullOrEmpty(model.tiktok) {
            _tiktokField.fieldType = FormFieldType.socialForm.rawValue
            _tiktokField.setupData(model.tiktok, icon: "icon_tiktok", isEnable: false)
        } else {
            _tiktokField.isHidden = true
        }
        if !Utils.stringIsNullOrEmpty(model.youtube) {
            _youTubeField.fieldType = FormFieldType.socialForm.rawValue
            _youTubeField.setupData(model.youtube, icon: "icon_youtube", isEnable: false)
        } else {
            _youTubeField.isHidden = true
        }
        if !Utils.stringIsNullOrEmpty(model.facebook) {
            _facebookFeild.fieldType = FormFieldType.socialForm.rawValue
            _facebookFeild.setupData(model.facebook, icon: "icon_facebook", isEnable: false)
        } else {
            _facebookFeild.isHidden = true
        }
        
    }
    
    @objc private func openInstagram() {
        if !isEdit, let account = userModel?.instagram, !Utils.stringIsNullOrEmpty(account), let profileUrl = URL(string: account) {
            openActionSheet(appURL: profileUrl, webURL: profileUrl)
        }
    }
    
    @objc private func openTiktok() {
        if !isEdit, let account = userModel?.tiktok, !Utils.stringIsNullOrEmpty(account) {
            let appURLString: String
            let webURLString: String
            if (account.hasPrefix("http://") || account.hasPrefix("https://")) {
                appURLString = account
                webURLString = account
            } else {
                appURLString = "snssdk1128://user/profile/\(account)"
                webURLString = "https://www.tiktok.com/@\(account)"
            }
            guard let appURL = URL(string: appURLString), let webURL = URL(string: webURLString) else { return }
            openActionSheet(appURL: appURL, webURL: webURL)
        }
    }
    
    
    @objc private func openYoutube() {
        if !isEdit, let account = userModel?.youtube, !Utils.stringIsNullOrEmpty(account) {
            let appURLString: String
            let webURLString: String
            if (account.hasPrefix("http://") || account.hasPrefix("https://")) {
                appURLString = account
                webURLString = account
            } else {
                appURLString = "youtube://channel/\(account)"
                webURLString = "https://www.youtube.com/channel/\(account)"
            }
            guard let appURL = URL(string: appURLString), let webURL = URL(string: webURLString) else { return }
            openActionSheet(appURL: appURL, webURL: webURL)
        }
    }
    
    
    @objc private func openFacebook() {
        if !isEdit, let account = userModel?.facebook, !Utils.stringIsNullOrEmpty(account) {
            let appURLString: String
            let webURLString: String
            if (account.hasPrefix("http://") || account.hasPrefix("https://")) {
                appURLString = account
                webURLString = account
            } else {
                appURLString = "fb://profile/\(account)"
                webURLString = "https://www.facebook.com/\(account)"
            }
            guard let appURL = URL(string: appURLString), let webURL = URL(string: webURLString) else { return }
            openActionSheet(appURL: appURL, webURL: webURL)
        }
    }
    

    private func openApp(appURL: URL, webURL: URL) {
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    private func openActionSheet(appURL: URL, webURL: URL) {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "open".localized(), style: .default, handler: { action in
            self.openApp(appURL: appURL, webURL: webURL)
        }))
            
        alert.addAction(UIAlertAction(title: "copy".localized(), style: .default, handler: { action in
            if let decodedString = webURL.absoluteString.removingPercentEncoding {
                UIPasteboard.general.string = decodedString
            } else {
                UIPasteboard.general.string = webURL.absoluteString 
            }
            self.parentViewController?.showToast("copied".localized())
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }

}
