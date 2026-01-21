import UIKit

class YachHourlyCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _durationStack: UIStackView!
    @IBOutlet weak var _counterLabel: UILabel!
    @IBOutlet weak var _counterStack: UIStackView!
    @IBOutlet weak var _titileText: UILabel!
    @IBOutlet weak var _subTitle: UILabel!
    @IBOutlet weak var _conditionText: UILabel!
    @IBOutlet weak var _duration: UILabel!
    @IBOutlet weak var _total: UILabel!
    private var stepperValue: Int = 0
    private var stepperMaxValue: Int = 0
    private var stepperMinValue: Int = 0
    private var packageModel: YachtPackgeModel?
    public var updateDataCallback: ((_ model: YachtPackgeModel?, _ duration: Int)-> Void)?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 103 }


    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupPackage(model: YachtPackgeModel, isHourly: Bool) {
        packageModel = model
            _titileText.text = model.title
            _subTitle.text = model.descriptions
            _conditionText.text = "💡 Min. \(model.minimumHour)hr - Max. \(model.maximumHour)hrs (check availability)"
            _total.text = "D\((packageModel?.pricePerHour ?? 0) * model.minimumHour)"
            stepperMaxValue = model.maximumHour
            stepperMinValue = model.minimumHour
            stepperValue = model.minimumHour
            _counterStack.isHidden = false
            updateLabel()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func updateLabel() {
        _counterLabel.text = "\(stepperValue)hrs"
        _total.text = "D\((packageModel?.pricePerHour ?? 0) * stepperValue)"
        updateDataCallback?(packageModel, stepperValue)
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handlePlusEvent(_ sender: Any) {
        if stepperValue < stepperMaxValue {
            stepperValue += 1
            updateLabel()
        }
    }
    
    @IBAction func _handleMinusEvent(_ sender: UIButton) {
        if stepperValue > stepperMinValue {
            stepperValue -= 1
            updateLabel()
        }

    }
}
