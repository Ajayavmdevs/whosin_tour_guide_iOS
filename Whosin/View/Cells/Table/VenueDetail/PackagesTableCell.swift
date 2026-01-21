import UIKit

class PackagesTableCell: UITableViewCell {
    
    @IBOutlet private weak var _discountView: GradientView!
    @IBOutlet private weak var _discountedPrice: UILabel!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _discountLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenWebView(_:)), name: kOpenWebViewPackagePayment, object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: PackageModel) {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            _discountView.startColor = UIColor.init(hexString: "#686868")
            _discountView.endColor = UIColor.init(hexString: "#8E8E8E")
        }
        if data.discount == "0" {
            _discountView.isHidden = true
        } else {
            _discountView.isHidden = false
            _discountLabel.text = data._discount
        }
        _discountedPrice.text = data.discountedPrice
        _title.text = data.title
    }
    
    @objc func handleOpenWebView(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let url = userInfo["url"] as? URL {
            let vc = INIT_CONTROLLER_XIB(WebViewController.self)
            vc.url = url
            parentBaseController?.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction private func _handeleInfoEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let controller = INIT_CONTROLLER_XIB(PackagesInfoVC.self)
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        parentViewController?.present(controller, animated: true, completion: nil)
    }
    
}

extension PackagesTableCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
    
}
