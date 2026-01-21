import UIKit
import CollectionViewPagingLayout

class HomeBlockDealsCollectionView: UICollectionViewCell {

    @IBOutlet weak var _bgImage: UIImageView!
    @IBOutlet private weak var _venueView: CustomVenueInfoView!
    @IBOutlet weak var _coverImage: UIImageView!
    @IBOutlet public weak var _mainContainer: UIView!
    @IBOutlet private weak var _countDownview: CountDownView!
    @IBOutlet private weak var _descriptionText: CustomLabel!
    @IBOutlet private weak var _buyNowBtn: CustomButton!
    @IBOutlet private weak var _subtitleText: CustomLabel!
    @IBOutlet public weak var _mainTrailing: NSLayoutConstraint!
    private var _starttime : Date?
    private var _endtime : Date?
    private var _dealsId: String = kEmptyString
    private var _dealsModel: DealsModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 540 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._mainContainer.cornerRadius = 10
            self._coverImage.cornerRadius = 10
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ model: DealsModel) {
        let venueModel = model.venueModel// Utils.getModelFromId(model: APPSETTING.venueModel, id: model.venueId)
        self._venueView.setupData(venue: venueModel ?? VenueDetailModel(), isAllowClick: true, isSmallView: true)
        _dealsModel = model
        _dealsId = model.id
        _subtitleText.text = model.title
        _descriptionText.text = model.descriptions
        _buyNowBtn.setTitle("from".localized() + "\(Utils.getCurrentCurrencySymbol())\(model.discountedPrice)", for: .normal)
        _buyNowBtn.isHidden = model.isZeroPrice

        if !Utils.stringIsNullOrEmpty(model.startDate) && !Utils.stringIsNullOrEmpty(model.endDate) {
            _countDownview.setupCountdown(String(describing: "\(model.endDate) \(model.endTime)"), isBlureView: true)
            _countDownview.isHidden = model._isExpired ? true : false
        } else {
            _countDownview.isHidden = true
        }
        _bgImage.loadWebImage(model.image)
        _coverImage.loadWebImage(model.image)
//        DispatchQueue.global(qos: .userInitiated).async {
//            DispatchQueue.main.async {
//                self._coverImage.loadWebImage(model.image) { [weak self] in
//                    if let img  = self?._coverImage.image {
//                        DispatchQueue.global(qos: .userInitiated).async {
//                            let color = try? img.averageColor()
//                            DISPATCH_ASYNC_MAIN {
//                                self?._mainContainer.borderColor = color ?? .red
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    
    @IBAction func _handleBuyNowEvent(_ sender: CustomButton) {
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

extension HomeBlockDealsCollectionView: ScaleTransformView {
//    var scaleOptions: ScaleTransformViewOptions {
//        ScaleTransformViewOptions(
//            minScale: 0.99,
//            scaleRatio: 0.4 ,
//            translationRatio: CGPoint(x: 1.02, y: 0.0),
//            maxTranslationRatio: CGPoint(x: 2, y: 0)
//        )
//    }
    var scaleOptions: ScaleTransformViewOptions {
        ScaleTransformViewOptions(
            minScale: 0.99,
            scaleRatio: 0.4 ,
            translationRatio: CGPoint(x: 1.023, y: 0.0),
            maxTranslationRatio: CGPoint(x: 2, y: 0)
        )
    }
}
