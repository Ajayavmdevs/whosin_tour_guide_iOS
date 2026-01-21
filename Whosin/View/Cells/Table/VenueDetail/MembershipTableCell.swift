import UIKit

class MembershipTableCell: UITableViewCell {

    @IBOutlet private weak var _bgView: UIView!
    @IBOutlet private weak var _memberShipTitle: UILabel!
    @IBOutlet private weak var _memberShipdesc: UILabel!
    @IBOutlet weak var _priceLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._bgView.addGradientBorderWithColor(cornerRadius: 10.0, 1.5, [ColorBrand.brandgradientBlue.cgColor, ColorBrand.brandgradientPink.cgColor])
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: MembershipPackageModel, isFromSubscription: Bool = false) {
        _memberShipTitle.text = model.title
        _memberShipdesc.text = model.descriptions
        _priceLabel.text = "validity".localized() + "\(model.validTill)"
    }

//    @IBAction private func _handleGetItNowAction(_ sender: UIButton) {
//        guard let userDetail = APPSESSION.userDetail else { return }
//        _url = _url.replacingOccurrences(of: "user_email_here", with: userDetail.email)
//        _url = _url.replacingOccurrences(of: "user_id_here", with: userDetail.id)
//        parentViewController?.dismiss(animated: true, completion: nil)
//        guard let url = URL(string: _url) else { return }
//        NotificationCenter.default.post(name: kOpenWebViewPackagePayment, object: nil, userInfo: ["url": url])
//    }
    
//    @IBAction func _handlePlanDetailEvent(_ sender: UIButton) {
//        let vc = INIT_CONTROLLER_XIB(PlanDetailsVC.self)
//        vc.membershipDetail = membershipDetail
//        parentViewController?.navigationController?.pushViewController(vc, animated: true)
//    }
    
}
