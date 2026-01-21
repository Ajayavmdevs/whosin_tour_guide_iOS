import UIKit

class PackagesCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _discountView: GradientView!
    @IBOutlet private weak var _discountedPrice: UILabel!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _discountLabel: UILabel!
    @IBOutlet private weak var _discription: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        50
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenWebView(_:)), name: kOpenWebViewPackagePayment, object: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: PackageModel, isFromCatefory:Bool = false) {
        _discountView.startColor = UIColor.init(hexString: "#F30092")
        _discountView.endColor = UIColor.init(hexString: "#9026E3")
        _discription.isHidden = Utils.stringIsNullOrEmpty(data.descriptions)
        if Utils.stringIsNullOrEmpty(data.discount) {
            if data._discounts == "0%" {
                _discountView.isHidden = true
            } else {
                _discountView.isHidden = false
                _discountLabel.text = data._discounts
            }
        } else {
            if data._discount == "0%" {
                _discountView.isHidden = true
            } else {
                _discountView.isHidden = false
                _discountLabel.text = data._discount
            }
        }
        _discountedPrice.text = "D" + Utils.formatDiscountValue(data._flootdiscountedPrice)
        _title.text = data.title
        _discription.text = data.descriptions
    }

    public func setupHomeOfferData(_ data: PackageModel) {
        _discountView.startColor = UIColor.init(hexString: "#F30092")
        _discountView.endColor = UIColor.init(hexString: "#9026E3")
        _discription.isHidden = true
        if Utils.stringIsNullOrEmpty(data.discount) {
            if data.discounts == 0 {
                _discountView.isHidden = true
            } else {
                _discountView.isHidden = false
                _discountLabel.text = data._discount
            }
        } else {
            if data._discount == "0%" {
                _discountView.isHidden = true
            } else {
                _discountView.isHidden = false
                _discountLabel.text = data._discount
            }
        }
        _discountedPrice.text = "D" + Utils.formatDiscountValue(data._flootdiscountedPrice)
        _title.text = data.title
    }

    public func setupEventData(_ data: PackageModel) {
        _discription.isHidden = false
        _discountView.startColor = UIColor.init(hexString: "#F30092")
        _discountView.endColor = UIColor.init(hexString: "#9026E3")
        if Utils.stringIsNullOrEmpty(data.discount) {
            if data.discounts == 0 {
                _discountView.isHidden = true
            } else {
                _discountView.isHidden = false
                _discountLabel.text = data._discounts
            }
        } else {
            if data._discount == "0%" {
                _discountView.isHidden = true
            } else {
                _discountView.isHidden = false
                _discountLabel.text = data._discount
            }
        }
        _discountedPrice.text = "D" + Utils.formatDiscountValue(data._flootdiscountedPrice)
        _title.text = data.title
        _discription.text = data.descriptions
    }
    
    @objc func handleOpenWebView(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let url = userInfo["url"] as? URL {
            let vc = INIT_CONTROLLER_XIB(WebViewController.self)
            vc.url = url
            parentBaseController?.present(vc, animated: true, completion: nil)
        }
    }
    
}

extension PackagesCollectionCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}
