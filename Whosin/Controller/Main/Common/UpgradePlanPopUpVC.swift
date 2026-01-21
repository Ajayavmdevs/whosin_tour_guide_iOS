import UIKit

class UpgradePlanPopUpVC: ChildViewController {

    @IBOutlet private weak var _containerView: GradientView!
    @IBOutlet private weak var _bgImage: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _boosterImage: UIImageView!
    @IBOutlet private weak var _boosterTitle: UILabel!
    @IBOutlet private weak var _descLabel: UILabel!
    @IBOutlet private weak var _buyNowBtn: UIButton!
    @IBOutlet private weak var _seeOptionBtn: UIButton!
    var subscriptionModel: SubscriptionModel?
    private var _url: String = kEmptyString

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenWebView(_:)), name: kOpenWebViewPackagePayment, object: nil)
        guard let subscription = subscriptionModel else { return }
        _containerView.startColor = UIColor.init(hexString: subscription.startColor)
        _containerView.endColor = UIColor.init(hexString: subscription.endColor)
        _titleLabel.text = subscription.title
        _boosterTitle.text = subscription.subTitle
        _descLabel.text = subscription.descriptions
        _buyNowBtn.setTitle(subscription.buttonText)
        _boosterImage.loadWebImage(subscription.image)
        _url = subscription.packageId?.paymentLink ?? kEmptyString
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleSeeOptionEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(PlanDetailsVC.self)
        vc.membershipDetail = subscriptionModel?.packageId
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
        guard let userDetail = APPSESSION.userDetail else { return }
        _url = _url.replacingOccurrences(of: "user_email_here", with: userDetail.email)
        _url = _url.replacingOccurrences(of: "user_id_here", with: userDetail.id)
        dismiss(animated: true)
        guard let url = URL(string: _url) else { return }
        NotificationCenter.default.post(name: kOpenWebViewPackagePayment, object: nil, userInfo: ["url": url])
    }
    
    @objc private func handleOpenWebView(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let url = userInfo["url"] as? URL {
            let vc = INIT_CONTROLLER_XIB(WebViewController.self)
            vc.url = url
            self.present(vc, animated: true, completion: nil)
        }
    }
}

