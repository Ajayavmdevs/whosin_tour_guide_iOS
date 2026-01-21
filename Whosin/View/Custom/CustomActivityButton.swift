import NVActivityIndicatorView
import UIKit

public class CustomActivityButton: CustomButton {
    
	public var isLoading: Bool = false
	private var _titleText: String = kEmptyString
	private var _activity: NVActivityIndicatorView!

	// --------------------------------------
	// MARK: Overrides
	// --------------------------------------

	public override func customize() {
		super.customize()
        _titleText = self.titleLabel?.text ?? kEmptyString
		_activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        _activity.color = titleLabel?.textColor ?? ColorBrand.white
        _activity.type = .ballPulse
		addSubview(_activity)
	}

    public override func draw(_ rect: CGRect) {
		super.draw(rect)
		_activity.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
	}

	// --------------------------------------
	// MARK: Public
	// --------------------------------------

	public func showActivity() {
        _titleText = titleLabel?.text ?? kEmptyString
		setTitle(kEmptyString, for: .normal)
		setTitle(kEmptyString, for: .highlighted)
		setTitle(kEmptyString, for: .selected)
		isEnabled = false
		isLoading = true
		_activity.startAnimating()
	}

    public func hideActivity() {
		setTitle(_titleText, for: .normal)
		setTitle(_titleText, for: .highlighted)
		setTitle(_titleText, for: .selected)
		isEnabled = true
		isLoading = false
		_titleText = titleLabel?.text ?? kEmptyString
		_activity.stopAnimating()
	}
}

public class CustomFollowButton: CustomActivityButton {
    
    private var isFilled: Bool = false
    private var userModel: UserDetailModel?
    public var callback: ((_ isFollowing: String) -> Void)?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    private func commonInit() {
        layer.cornerRadius = layer.frame.height / 2
        setTitleColor(ColorBrand.white, for: .normal)
        
    }
    
    func setupData(_ model: UserDetailModel, isFillColor: Bool = false, font: UIFont = FontBrand.SFregularFont(size: 12), callback: ((_ isFollowing: String) -> Void)? ) {
        self.callback = callback
        isFilled = isFillColor
        userModel = model
        updateButtonAppearance(model.follow)
        titleLabel?.font = font
        NotificationCenter.default.addObserver(self, selector: #selector(_handleFollowStatusEvent(_:)), name: kReloadFollowStatus, object: nil)
    }
    
    @objc func _handleFollowStatusEvent(_ notification: Notification) {
        guard let model = notification.object as? UserDetailModel else { return }
        if model.id == userModel?.id {
            userModel?.follow = model.status
            updateButtonAppearance(model.status)
        }
    }

    private func requestFollowUnfollow() {
        guard let user = userModel else { return }
        WhosinServices.userFollow(id: user.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            guard let data = container?.data else { return }
            self.updateButtonAppearance(data.status)
            self.callback?(data.status)
            self._showMessage(status: data.status, name: user.fullName)
            data.id = user.id
            NotificationCenter.default.post(name: kReloadFollowStatus, object: data, userInfo: nil)
        }
    }
    
    private func updateButtonAppearance(_ status: String) {
        borderColor = ColorBrand.white
        borderWidth = isFilled ? 0 : 1
        backgroundColor = isFilled ? ColorBrand.brandPink : ColorBrand.clear
        switch status {
        case "approved":
            setTitle("following", for: .normal)
            borderColor = ColorBrand.white
            borderWidth =  1
            backgroundColor = ColorBrand.clear
        case "pending":
            setTitle("Requested", for: .normal)
            borderColor = ColorBrand.white
            borderWidth = 1
            backgroundColor = ColorBrand.clear
        case "cancelled":
            setTitle("Follow", for: .normal)
            borderColor = ColorBrand.white
            borderWidth =  isFilled ? 0 : 1
            backgroundColor =   isFilled ? ColorBrand.brandPink :ColorBrand.clear
        default:
            setTitle("Follow", for: .normal)
            borderColor = ColorBrand.white
            borderWidth =  isFilled ? 0 : 1
            backgroundColor =   isFilled ? ColorBrand.brandPink :ColorBrand.clear
        }
    }
    
    
    private func _showMessage(status: String, name: String) {
        switch status {
        case "approved":
            self.parentBaseController?.showSuccessMessage("thank_you".localized(), subtitle: LANGMANAGER.localizedString(forKey: "following_toast", arguments: ["value": name]) )
        case "pending":
            self.parentBaseController?.showSuccessMessage("thank_you".localized() , subtitle: LANGMANAGER.localizedString(forKey: "request_toast", arguments: ["value": name]))
        case "cancelled":
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": name]))
        default:
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": name]))
        }
    }

    
    @objc private func buttonClicked() {
        requestFollowUnfollow()
    }
}


public class CustomLikeButton: CustomButton {
    
    public var isLoading: Bool = false
    private var _titleText: String = kEmptyString
    private var _activity: NVActivityIndicatorView!

    // --------------------------------------
    // MARK: Overrides
    // --------------------------------------

    public override func customize() {
        super.customize()
        _titleText = self.titleLabel?.text ?? kEmptyString
        _activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        _activity.color = titleLabel?.textColor ?? ColorBrand.white
        _activity.type = .circleStrokeSpin
        addSubview(_activity)
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        _activity.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func showActivity() {
        _titleText = titleLabel?.text ?? kEmptyString
        setTitle(kEmptyString, for: .normal)
        setTitle(kEmptyString, for: .highlighted)
        setTitle(kEmptyString, for: .selected)
        isEnabled = false
        isLoading = true
        _activity.startAnimating()
    }

    public func hideActivity() {
        setTitle(_titleText, for: .normal)
        setTitle(_titleText, for: .highlighted)
        setTitle(_titleText, for: .selected)
        isEnabled = true
        isLoading = false
        _titleText = titleLabel?.text ?? kEmptyString
        _activity.stopAnimating()
    }
}

