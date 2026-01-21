import UIKit

class TicketBasicDetailTableCell: UITableViewCell {

    @IBOutlet private weak var _cancellationView: CustomLabel!
    @IBOutlet private weak var _durationView: UIView!
    @IBOutlet private weak var _cityNameView: UIView!
    @IBOutlet private weak var _tourtypeView: UIView!
    @IBOutlet private weak var _durationText: CustomLabel!
    @IBOutlet private weak var _cityNameText: CustomLabel!
    @IBOutlet private weak var _tourtypeText: CustomLabel!
    @IBOutlet private weak var _cancellationText: CustomLabel!
    @IBOutlet weak var _startTimeDuration: UIView!
    @IBOutlet weak var _departurePoint: CustomLabel!
    
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
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(model: TicketModel) {
        if !Utils.stringIsNullOrEmpty(model.tourData?.duration) {
            _durationView.isHidden = false
            _durationText.text = model.tourData?.duration
        } else {
            _durationView.isHidden = true
        }
        
        if !Utils.stringIsNullOrEmpty(model.tourData?.cityName) {
            _cityNameView.isHidden = false
            _cityNameText.text = model.tourData?.cityName
        } else if !Utils.stringIsNullOrEmpty(model.city) {
            _cityNameView.isHidden = false
            _cityNameText.text = model.city
        } else {
            _cityNameView.isHidden = true
        }
        
        if !Utils.stringIsNullOrEmpty(model.tourData?.cityTourType) {
            _tourtypeView.isHidden = false
            _tourtypeText.text = model.tourData?.cityTourType
        } else if !Utils.stringIsNullOrEmpty(model.cityTourType) {
            _tourtypeView.isHidden = false
            _tourtypeText.text = model.cityTourType
        } else {
            _tourtypeView.isHidden = true
        }
        
        if !Utils.stringIsNullOrEmpty(model.departurePoint) {
            _startTimeDuration.isHidden = false
            _departurePoint.text = model.departurePoint
        } else if !Utils.stringIsNullOrEmpty(model.duration) {
            _startTimeDuration.isHidden = false
            _departurePoint.text = model.duration
        }  else {
            _startTimeDuration.isHidden = true
        }
        
//        if !Utils.stringIsNullOrEmpty(model.cancellationPolicyText) {
//            _cancellationView.isHidden = false
//            _cancellationText.text = model.cancellationPolicyText
//        } else { _cancellationView.isHidden = true }
        _cancellationView.isHidden = true
    }

}
