import Foundation
import UIKit
import SnapKit
import CountdownLabel

class CountDownView: UIView {
    
    @IBOutlet weak var _backgroundView: UIView!
    @IBOutlet private weak var _eventTitle: UILabel!
    @IBOutlet private weak var _dayLabel: CountdownLabel!
    @IBOutlet private weak var _hoursLabel: CountdownLabel!
    @IBOutlet private weak var _minLabel: CountdownLabel!
    @IBOutlet private weak var _secLabel: CountdownLabel!
    @IBOutlet private weak var _dayView: UIView!
    @IBOutlet private weak var _hourView: UIView!
    @IBOutlet private weak var _minitView: UIView!
    @IBOutlet private weak var _secondView: UIView!
    @IBOutlet private weak var _daysBlure: UIVisualEffectView!
    @IBOutlet private weak var _hoursBlure: UIVisualEffectView!
    @IBOutlet private weak var _minitBlur: UIVisualEffectView!
    @IBOutlet private weak var _secBlure: UIVisualEffectView!
    
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        Bundle.main.loadNibNamed("CountDownView", owner: self, options: nil)
        addSubview(_backgroundView)
        _backgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    public func setupCountdown(_ dateString: String, isBlureView: Bool = false) {
        let tmpEndDate = "\(dateString)".toDateUae(format: kFormatDateTimeLocal)
        scheduleTimerNotification(endDateString: tmpEndDate)
        setupLabel(_dayLabel, format: "dd", targetDate: tmpEndDate)
        setupLabel(_hoursLabel, format: "HH", targetDate: tmpEndDate)
        setupLabel(_minLabel, format: "mm", targetDate: tmpEndDate)
        setupLabel(_secLabel, format: "ss", targetDate: tmpEndDate)
        _dayView.backgroundColor = isBlureView ? .clear : UIColor(hexString: "#232323")
        _hourView.backgroundColor = isBlureView ? .clear : UIColor(hexString: "#232323")
        _minitView.backgroundColor = isBlureView ? .clear : UIColor(hexString: "#232323")
        _secondView.backgroundColor = isBlureView ? .clear : UIColor(hexString: "#232323")
        _daysBlure.isHidden = !isBlureView
        _minitBlur.isHidden = !isBlureView
        _hoursBlure.isHidden = !isBlureView
        _secBlure.isHidden = !isBlureView
        
    }
    
    private func setupLabel(_ label: CountdownLabel, format: String, targetDate: Date) {
        label.font = FontBrand.SFboldFont(size: 24)
        label.animationType = .Evaporate
        label.timeFormat = format
        label.setCountDownDate(targetDate: targetDate as NSDate)
        DISPATCH_ASYNC_MAIN_AFTER(0.015) {
            label.start()
        }
    }
    
    func scheduleTimerNotification(endDateString: Date) {
        let timeInterval = endDateString.timeIntervalSinceNow
        
        if timeInterval > 0 {
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
                self._dayLabel.text = "00"
                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
            }
        }
    }

}


