import UIKit
import CollectionViewPagingLayout
import CountdownLabel

class ExclusiveDealsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _countDownView: UIView!
    @IBOutlet weak var _countDownVisualView: UIVisualEffectView!
    @IBOutlet private weak var _countDownLabel: CountdownLabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _buyNowBg: UIView!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subTitleLabel: UILabel!
    @IBOutlet weak var _mainTrailing: NSLayoutConstraint!
    @IBOutlet weak var _leadingTrailing: NSLayoutConstraint!
    private var _starttime : Date?
    private var _endtime : Date?
    private var _dealsId: String = kEmptyString
    private var _dealsModel: DealsModel?
    
    // --------------------------------------
    // MARK: Class1
    // --------------------------------------
    
    class var height: CGFloat { 358 }
    
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
            self._mainContainerView.cornerRadius = 10
            self._coverImage.cornerRadius = 10
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 8)
//            self._buyNowBg.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
            self._buyNowBg.hero.id = self._dealsId+"_open_buy_package_info"
            self._buyNowBg.hero.modifiers = HeroAnimationModifier.stories
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ model: DealsModel) {
        let venueModel = model.venueModel// Utils.getModelFromId(model: APPSETTING.venueModel, id: model.venueId)
        self._venueInfoView.setupData(venue: venueModel ?? VenueDetailModel(), isAllowClick: true)
        _dealsModel = model
        _dealsId = model.id
        _titleLabel.text = model.title
        _subTitleLabel.text = model.descriptions
        if model.originalPrice != 0 {
            _badgeView.setupData(originalPrice: model.originalPrice, discountedPrice: "\(model.discountedPrice)", isNoDiscount: model._isNoDiscount, text: "starting_from")
        } else {
            _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: "\(model.discountedPrice)", isNoDiscount: model._isNoDiscount, text: "starting_from")
        }
        _buyNowBg.isHidden = model.isZeroPrice
        if !Utils.stringIsNullOrEmpty(model.startDate) && !Utils.stringIsNullOrEmpty(model.endDate) {
            _starttime = Date(timeInterval: "\(Date())".toDate(format: "yyyy-MM-dd").timeIntervalSince(Date()), since: Date())
            _endtime = Date(timeInterval: "\(model.endDate) \(model.endTime)".toDate(format: "yyyy-MM-dd HH:mm").timeIntervalSince(Date()), since: Date())
            _countDownLabel.animationType = .Evaporate
            _countDownLabel.timeFormat = "dd:HH:mm:ss"
            _countDownLabel.setCountDownDate(fromDate: _starttime! as NSDate, targetDate: _endtime! as NSDate)
            _countDownLabel.start()
            _countDownVisualView.isHidden = model._isExpired ? true : false
        } else {
            _countDownVisualView.isHidden = true
        }
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self._coverImage.loadWebImage(model.image) { [weak self] in
                    if let img  = self?._coverImage.image {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let color = try? img.averageColor()
                            DISPATCH_ASYNC_MAIN {
                                self?._mainContainerView.borderColor = color ?? .red
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction private func _handleBuyNowEvent(_ sender: UIButton) {
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

extension ExclusiveDealsCollectionCell: ScaleTransformView {
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


extension String {
    func toDate(format : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        if let formattedDate = dateFormatter.date(from: self) {
            return formattedDate
        } else {
            return Utils.stringDateLocal(self, format: kStanderdDate) ?? Date()
        }
    }
    
    func toDateUae(format : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Dubai")!
        if let formattedDate = dateFormatter.date(from: self) {
            return formattedDate
        } else {
            return Utils.stringDateLocal(self, format: kStanderdDate) ?? Date()
        }
    }
}
