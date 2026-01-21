import UIKit
import DialCountries

class CompDescriptionCell: UITableViewCell {

    @IBOutlet private weak var _addressView: UIView!
    @IBOutlet private weak var _nationalityView: UIView!
    @IBOutlet private weak var _genderView: UIView!
    @IBOutlet private weak var _ageView: UIView!
    @IBOutlet private weak var _emailView: UIView!
    @IBOutlet weak var _dateView: UIView!
    @IBOutlet private weak var _genderLabel: CustomLabel!
    @IBOutlet private weak var _ageLabel: CustomLabel!
    @IBOutlet private weak var _emailLabel: CustomLabel!
    @IBOutlet private weak var _addressLbl: CustomLabel!
    @IBOutlet private weak var _nationality: CustomLabel!
    @IBOutlet private weak var _discHeight: NSLayoutConstraint!
    @IBOutlet private weak var _discLbl: CustomLabel!
    @IBOutlet weak var _dateApplyLabel: CustomLabel!
    @IBOutlet weak var _dateApproveLabel: CustomLabel!
    
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

    public func setupData(_ model: UserDetailModel, logs: [LogsModel] = []) {
        _emailView.isHidden = Utils.stringIsNullOrEmpty(model.email)
        _ageView.isHidden = Utils.stringIsNullOrEmpty(model.dateOfBirth)
        _nationalityView.isHidden = Utils.stringIsNullOrEmpty(model.nationality)
        _addressView.isHidden = Utils.stringIsNullOrEmpty(model.address)
        _genderView.isHidden = Utils.stringIsNullOrEmpty(model.gender)
        _discLbl.text = model.bio
        _discHeight.constant = _discLbl.sizeThatFits(CGSize(width: _discLbl.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        let dialCode: String
        if Utils.isValidCountryCode(model.nationality) {
            dialCode = model.nationality.uppercased()
        } else {
            dialCode = Utils.getCountryCodeByName(byCountryName: model.nationality) ?? Country.getCurrentCountry()?.code ?? "AE"
        }
        let flag = Utils.getCountyFlag(code: dialCode)
        _addressLbl.text = model.address
        _nationality.text = flag + " " + model.nationality
        _emailLabel.text = model.email
        _ageLabel.text = "\(Utils.calculateAge(from: model.dateOfBirth) ?? 0)" + "years".localized()
        _genderLabel.text = model.gender.capitalized
        configureLabel(for: "applied", label: _dateApplyLabel, title: "applied".localized(), logs: logs)
        configureLabel(for: "approved", label: _dateApproveLabel, title: "approved".localized(), logs: logs)
    }
   
    func configureLabel(for subtype: String, label: UILabel, title: String, logs: [LogsModel]) {
        if let log = logs.first(where: { $0.subType == subtype }) {
            let formattedDate = Utils.dateToString(log.dateTime, format: kValidityDateFormat)
            label.attributedText = Utils.setAtributedTitleText(
                title: "\(title) : ",
                subtitle: formattedDate,
                titleFont: FontBrand.SFboldFont(size: 14.0),
                subtitleFont: FontBrand.SFregularFont(size: 14.0)
            )
            label.isHidden = false
        } else {
            label.isHidden = true
        }
        _dateView.isHidden = logs.isEmpty
    }
}
