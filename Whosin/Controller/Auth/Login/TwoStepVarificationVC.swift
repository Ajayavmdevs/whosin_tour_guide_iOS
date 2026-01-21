import UIKit
import DeviceKit

class TwoStepVarificationVC: ChildViewController {

    @IBOutlet weak var _discriptionText: UILabel!
    @IBOutlet weak var _bottomTitleText: UILabel!
    @IBOutlet weak var _phoneNumber: UILabel!
    @IBOutlet weak var _progress: RoundProgressView!
    
    private var _requestId: String = kEmptyString

    // --------------------------------------
    // MARK: Life-cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _phoneNumber.text = "\(APPSESSION.userDetail?._countryCode ?? kEmptyString) \(APPSESSION.userDetail?.phone ?? kEmptyString)"
        _progress.startCountdown()
        _progress.timerCompletion = {
            APPSESSION.clearSessionData()
            APPSESSION._moveToLogin()
        }
        let attributedString = NSMutableAttributedString(string: "notification_for_varification_text".localized(), attributes: [
            .foregroundColor: ColorBrand.white.withAlphaComponent(0.5),
            .font: UIFont.systemFont(ofSize: 16)
        ])
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorBrand.white.withAlphaComponent(0.7),
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorBrand.white.withAlphaComponent(0.5),
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]

        let boldString = NSAttributedString(string: "yes".localized(), attributes: boldAttributes)
        let regularString = NSAttributedString(string: "to_continue".localized(), attributes: regularAttributes)
        attributedString.append(boldString)
        attributedString.append(regularString)
        _discriptionText.attributedText = attributedString
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(_handleAuthApproved(_:)), name: .approvedAuthRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    @objc func _handleAuthApproved(_ notification: Notification) {
        guard let model = notification.object as? LoginApprovalModel else { return }
        if let metadata = model.metadata {
            if metadata.status == "approved" && metadata.deviceId == Utils.getDeviceID() {
                if !Utils.stringIsNullOrEmpty(metadata.token) {
                   Preferences.token = metadata.token
                   Preferences.didLogin = true
                }
                
                APPSESSION.moveToHome()
                _progress.stopTimer()
            } else if metadata.status == "reject" && metadata.deviceId == Utils.getDeviceID() {
                APPSESSION.clearSessionData()
                APPSESSION._moveToLogin()
                _progress.stopTimer()
            }
        }
    }
    
    @objc func appWillEnterForeground() {
        _requestGetLoginRequest()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestGetLoginRequest() {
        if _requestId.isEmpty { return }
        let params: [String: Any] = ["reqId": _requestId]
        WhosinServices.getLoginRequest(params: params) { [weak self] container , error in
            guard let self = self else { return }
            guard let model = container, model.isSuccess else {
                self.showError(error)
                return
            }
            guard let data = model.data, let metadata = data.metadata else { return }
            if data.status == "approved" && metadata.deviceId == Utils.getDeviceID() {
                if !Utils.stringIsNullOrEmpty(metadata.token) {
                   Preferences.token = metadata.token
                   Preferences.didLogin = true
                }
                APPSESSION.moveToHome()
                _progress.stopTimer()
            } else if data.status == "reject" && metadata.deviceId == Utils.getDeviceID() {
                APPSESSION.clearSessionData()
                APPSESSION._moveToLogin()
                _progress.stopTimer()
            }
        }
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    @IBAction func _handleResendEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(TwoStepEmailOptionVc.self)
        controller.delegate = self
        self.presentAsPanModal(controller: controller)
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        APPSESSION.clearSessionData()
        APPSESSION._moveToLogin()
        _progress.stopTimer()
    }
    
}

extension TwoStepVarificationVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        if tag == 1 {
            _progress.stopTimer()
            _progress.totalTime = 120
            _progress.startCountdown()
            
            _phoneNumber.text = APPSESSION.userDetail?.email
            _bottomTitleText.text = "check_your_email".localized()
            _discriptionText.text = "sent_link_email".localized()
        }
        
    }
    
    func buttonClicked(tag: String, type: ActionType) {
        if type == .none {
            _progress.stopTimer()
            _progress.totalTime = 120
            _progress.startCountdown()
            _requestId = tag
            
            _phoneNumber.text = APPSESSION.userDetail?.email
            _bottomTitleText.text = "Check your email"
            _discriptionText.text = "sent_link_email".localized()
        }
    }
}


class RoundProgressView: UIView {
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = ColorBrand.white
        label.font = FontBrand.SFboldFont(size: 40)
        return label
    }()

    @IBInspectable var totalTime: TimeInterval = 120 {
        didSet {
            progressLabel.text = "\(Int(totalTime))"
            elapsedTime = totalTime
        }
    }

    private var elapsedTime: TimeInterval = 120 { // Initialize elapsedTime with totalTime
        didSet {
            setNeedsDisplay()
            progressLabel.text = "\(Int(elapsedTime))"
            if elapsedTime <= 0 {
                timerCompletion?()
            }
        }
    }

    @IBInspectable var progressColor: UIColor = ColorBrand.brandPink {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var fontSize: CGFloat = 40 {
        didSet {
            progressLabel.font = FontBrand.SFboldFont(size: fontSize)
        }
    }
    
    @IBInspectable var borderwidth: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var timer: Timer?
    var timerCompletion: (() -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - borderwidth
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        ColorBrand.white.withAlphaComponent(0.5).setStroke()
        circlePath.lineWidth = borderwidth
        circlePath.stroke()
        
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi * CGFloat(elapsedTime / totalTime) - CGFloat.pi / 2, clockwise: true)
        
        progressColor.setStroke()
        progressPath.lineWidth = borderwidth + 1 // slightly wider to distinguish
        progressPath.lineCapStyle = .round
        progressPath.stroke()
    }
    
    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.elapsedTime -= 1
            if self.elapsedTime <= 0 {
                timer.invalidate()
            }
        }
    }
    
    func stopTimer() {
        if let _time = timer {
            if _time.isValid {
                _time.invalidate()
            }
        }
    }
}

