import UIKit
import SnapKit

class ActivityHeaderTableCell: UITableViewCell {
    
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _bannerView: UIView!
    @IBOutlet private weak var _safeHeight: NSLayoutConstraint!
    @IBOutlet private weak var _titleLabel: UILabel!
    private var categoryDetailModel: CategoryDetailModel?
    private var _bannerList: [BannerModel] = []
    private var swipeView: SwipeCardView<BannerModel>!{
        didSet{
            self.swipeView.delegate = self
        }
    }
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        disableSelectEffect()
        if let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height {
            _safeHeight.constant = statusBarHeight
        } else {
            _safeHeight.constant = 44
        }
        let img = UIImage(named: "icon_backArrow")?.withRenderingMode(.alwaysTemplate)
        _backButton.setImage(img, for: .normal)
        _backButton.tintColor = .white
        
    }
    
    private func setupCardView() {
        let contentView: (Int, CGRect, BannerModel) -> (UIView) = { (index: Int ,frame: CGRect , userModel: BannerModel) -> (UIView) in
            let customView = CustomView(frame: frame)
            customView.cardModel = userModel
            customView._cardClickButton.addTarget(self, action: #selector(self.customViewButtonSelected), for: UIControl.Event.touchUpInside)
            return customView
        }
        for v in _bannerView.subviews{
            v.removeFromSuperview()
        }
        _bannerView.frame.size.width = kScreenWidth - 40
        swipeView = SwipeCardView<BannerModel>(frame: _bannerView.bounds, contentView: contentView)
        swipeView.sepeatorDistance = 5
        _bannerView.addSubview(swipeView)
        swipeView.showSwipeCards(with: _bannerList ,isDummyShow: false)
    }
    
    @objc private func customViewButtonSelected(button: UIButton) {
        if let customView = button.superview(of: CustomView.self) , let userModel = customView.cardModel {
            if userModel.type == "activity" {
                guard let id = userModel.activity?.id, let name = userModel.activity?.name else { return }
                _openActivity(id: id, name: name)
            } else if userModel.type == "link" {
                _openURL(urlString: userModel.link)
            } else if userModel.type == "ticket" {
                _openTicket(id: userModel.ticketId)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [BannerModel]) {
        _bannerList = data
        self.setupCardView()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func _openActivity(id: String, name: String) {
        let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
        vc.activityId = id
        vc.activityName = name
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func _openTicket(id: String) {
        let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        vc.ticketID = id
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleImageClick(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        _openURL(urlString: categoryDetailModel?.bannersModel.first?.link ?? "")
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        parentViewController?.dismiss(animated: true, completion: nil)
    }
    
}

// --------------------------------------
// MARK: TinderSwipeView Delegate
// --------------------------------------

extension ActivityHeaderTableCell : SwipeCardViewDelegate {
    
    func dummyAnimationDone() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {}, completion: nil)
        print("Watch out shake action")
    }
    
    func didSelectCard(model: Any) {
        print("Selected card")
    }
    
    func fallbackCard(model: Any) {
    }
    
    func cardGoesLeft(model: Any) {
    }
    
    func cardGoesRight(model : Any) {
    }
    
    func undoCardsDone(model: Any) {
    }
    
    func endOfCardsReached() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {}, completion: nil)
        setupCardView()
    }
    
    func currentCardStatus(card object: Any, distance: CGFloat) {
        print(distance)
    }
}
