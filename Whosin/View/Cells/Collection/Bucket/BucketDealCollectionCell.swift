import UIKit

class BucketDealCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _containerView: UIView!
    @IBOutlet weak var _coverImage: UIImageView!
    @IBOutlet weak var _descriptionLabel: UILabel!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _badgeView: CustomBadgeView!
    @IBOutlet weak var _buyNowBg: GradientView!
    private var _dealsModel: DealsModel? = nil
    private var _dealsId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        180
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
            self._buyNowBg.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10.0)
        }
        

    }
    
    func setupData(_ data: DealsModel) {
        _dealsId = data.id
        _dealsModel = data
        _coverImage.loadWebImage(data.image)
        _descriptionLabel.text = data.descriptions
        _titleLabel.text = data.title
        
        _badgeView.setupData(originalPrice: data.actualPrice, discountedPrice: "\(data.discountedPrice)", isNoDiscount: data._isNoDiscount)
        _buyNowBg.isHidden = data.isZeroPrice
    }
    
    @IBAction func _handleBuyNowEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let controller = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
        controller.dealsId = _dealsId
        controller.dealsModel = _dealsModel
        controller.setCallback {
            let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
