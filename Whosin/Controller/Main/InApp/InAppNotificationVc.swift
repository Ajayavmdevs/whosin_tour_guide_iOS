import UIKit

class InAppNotificationVc: ChildViewController {
    
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subTitleLabel: UILabel!
    @IBOutlet private weak var _descriptionLabel: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _oneButton: UIButton!
    @IBOutlet private weak var _twoButton: UIButton!
    @IBOutlet private weak var _classicView: UIView!
    @IBOutlet private weak var _titleFeedLabel: UILabel!
    @IBOutlet private weak var _subTitleFeedLabel: UILabel!
    @IBOutlet private weak var _descriptionFeedLabel: UILabel!
    @IBOutlet private weak var _imageFeedView: UIImageView!
    @IBOutlet private weak var _oneFeedButton: UIButton!
    @IBOutlet private weak var _twoFeedButton: UIButton!
    @IBOutlet private weak var _feedView: UIView!
    @IBOutlet weak var _bgImageView: UIImageView!
    @IBOutlet weak var _feedBgImageView: UIImageView!
    @IBOutlet weak var _dialogueStack: UIStackView!
    @IBOutlet weak var _fullScreenStack: UIStackView!
    @IBOutlet weak var _classicFullScreen: UIView!
    @IBOutlet weak var _feedFullScreen: UIView!
    @IBOutlet weak var _fullFeedBgImage: UIImageView!
    @IBOutlet weak var _fullFeedTitle: UILabel!
    @IBOutlet weak var _fullFeedSubTitle: UILabel!
    @IBOutlet weak var _twoFullFeedBtn: UIButton!
    @IBOutlet weak var _titleFullClasic: UILabel!
    @IBOutlet weak var _subtitleFullClasic: UILabel!
    @IBOutlet weak var _fullImageClassic: UIImageView!
    @IBOutlet weak var _fullBgImageClasic: UIImageView!
    @IBOutlet weak var _fullDescriptionClassic: UILabel!
    @IBOutlet weak var _oneFullClassicBtn: UIButton!
    @IBOutlet weak var _twoFullClassicBtn: UIButton!
    @IBOutlet weak var _oneFullFeedBtn: UIButton!
    @IBOutlet weak var _fullFeedDescription: UILabel!
    @IBOutlet weak var _fullFeedImage: UIImageView!
    public var inAppData: InAppNotificationModel?
    public var closeCallback: (()-> Void)?
    public var openDetailScreen: ((_ viewModel: IANComponentModel)-> Void)?

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let model = inAppData else { return }
        if model.readStatus == false {
            readUpdateStatus(model._id)
        }
        if model.viewType == "full-screen" {
            if model.layout == "classic" {
                setLabelValue(_titleFullClasic, model.title)
                setLabelValue(_subtitleFullClasic, model.subTitle)
                setLabelValue(_fullDescriptionClassic, model.description)
                setButtonValue(_oneFullClassicBtn, model.button1)
                setButtonValue(_twoFullClassicBtn, model.button2)
                _fullImageClassic.isHidden = !model.image.isValidURL
                _fullBgImageClasic.isHidden = !(model.background?.image.isValidURL ?? false)
                _fullBgImageClasic.loadWebImage(model.background?.image ?? "")
                _fullImageClassic.loadWebImage(model.image)
//                _classicFullScreen.backgroundColor = UIColor(hexString: model.background?.color ?? "#ffffff")
                if let bg = model.background?.color, !Utils.stringIsNullOrEmpty(bg) {
                    _classicFullScreen.backgroundColor = UIColor(hexString: bg)
                } else {
                    _classicFullScreen.backgroundColor = ColorBrand.white
                }
            }
            else {
                setLabelValue(_fullFeedTitle, model.title)
                setLabelValue(_fullFeedSubTitle, model.subTitle)
                setLabelValue(_fullFeedDescription, model.description)
                setButtonValue(_oneFullFeedBtn, model.button1)
                setButtonValue(_twoFullFeedBtn, model.button2)
                _fullFeedImage.isHidden = !model.image.isValidURL
                _fullFeedImage.loadWebImage(model.image)
                _fullFeedBgImage.loadWebImage(model.background?.image ?? "")
                _fullFeedBgImage.isHidden = !(model.background?.image.isValidURL ?? false)
                if let color = model.background?.color, !Utils.stringIsNullOrEmpty(color) {
                    _feedFullScreen.backgroundColor = UIColor(hexString: color)
                } else {
                    _feedFullScreen.backgroundColor = ColorBrand.white
                }

            }
            _dialogueStack.isHidden = true
            _fullScreenStack.isHidden = false
            _feedView.isHidden = true
            _classicView.isHidden = true
            _feedFullScreen.isHidden = model.layout == "classic"
            _classicFullScreen.isHidden = model.layout != "classic"

        }
        else {
            if model.layout == "classic" {
                setLabelValue(_titleLabel, model.title)
                setLabelValue(_subTitleLabel, model.subTitle)
                setLabelValue(_descriptionLabel, model.description)
                setButtonValue(_oneButton, model.button1)
                setButtonValue(_twoButton, model.button2)
                _imageView.isHidden = !model.image.isValidURL
                _bgImageView.isHidden = !(model.background?.image.isValidURL ?? false)
                _bgImageView.loadWebImage(model.background?.image ?? "")
                _imageView.loadWebImage(model.image)
                if let bg = model.background?.color, !Utils.stringIsNullOrEmpty(bg) {
                    _classicView.backgroundColor = UIColor(hexString: bg)
                } else {
                    _classicView.backgroundColor = ColorBrand.white
                }
                
            }
            else {
                setLabelValue(_titleFeedLabel, model.title)
                setLabelValue(_subTitleFeedLabel, model.subTitle)
                setLabelValue(_descriptionFeedLabel, model.description)
                setButtonValue(_oneFeedButton, model.button1)
                setButtonValue(_twoFeedButton, model.button2)
                _imageFeedView.isHidden = !model.image.isValidURL
                _imageFeedView.loadWebImage(model.image)
                _feedBgImageView.loadWebImage(model.background?.image ?? "")
                _feedBgImageView.isHidden = !(model.background?.image.isValidURL ?? false)
                if let color = model.background?.color, !Utils.stringIsNullOrEmpty(color) {
                    _feedView.backgroundColor = UIColor(hexString: color)
                } else {
                    _feedView.backgroundColor = ColorBrand.white
                }
            }
            _dialogueStack.isHidden = false
            _fullScreenStack.isHidden = true
            _feedView.isHidden = model.layout == "classic"
            _classicView.isHidden = model.layout != "classic"
            _feedFullScreen.isHidden = true
            _classicFullScreen.isHidden = true

            
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func readUpdateStatus(_ id: String) {
        WhosinServices.readInAppNotification(notificationId: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self.inAppData?.readStatus = false
            self.showToast(data.message)
        }
    }
    
    private func setLabelValue(_ label:UILabel, _ model: IANComponentModel?) {
        guard let model = model else {
            label.text = kEmptyString
            return
        }
        label.text = model.text
        label.textColor = UIColor(hexString: model.color )
        label.textAlignment = model.textAlignment
    }
    
    private func setButtonValue(_ button:UIButton, _ model: IANComponentModel?) {
        guard let model = model else {
            button.isHidden = true
            return
        }
        if model.text.isEmpty {
            button.isHidden = true
            return
        }
        button.setTitle(model.text)
        button.setTitleColor(UIColor(hexString: model.color), for: .normal)
        button.backgroundColor = UIColor(hexString: model.bgColor)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true) {
            self.closeCallback?()
        }
    }
    
    
    @IBAction private func _handleOneButtonEvent(_ sender: UIButton) {
        _openView(view: inAppData?.button1)
    }
    
    @IBAction private func _handleTwoButtonEvent(_ sender: UIButton) {
        _openView(view: inAppData?.button2)
    }
    
    private func _openView(view : IANComponentModel?) {
        guard let view = view else { return }
        dismiss(animated: true) {
            self.openDetailScreen?(view)
        }
    }
    
}
