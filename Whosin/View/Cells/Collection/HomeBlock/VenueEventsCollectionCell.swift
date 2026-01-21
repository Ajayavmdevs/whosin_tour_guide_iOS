import UIKit
import ColorKit
import CollectionViewPagingLayout

class VenueEventsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet private weak var _badgeButton: UIButton!
    @IBOutlet private weak var _descTitle: UILabel!
    @IBOutlet private weak var _descriptionLabel: UILabel!
    @IBOutlet private weak var _viewButtonBg: UIView!
    @IBOutlet private weak var _viewButton: UIButton!
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString
    private var _venueDetailModel: VenueDetailModel?
    private var _ticketModel: TicketModel?
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 460 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _mainContainerView.cornerRadius = 10
        _coverImage.cornerRadius = 10
        setupUi()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._viewButton.cornerRadius = self._viewButtonBg.frame.size.height/2
            self._mainContainerView.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10)
            self._badgeButton.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
    }
    
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: CustomComponentModel) {
        
        _badgeButton.isHidden = data.badge == "0"
        
        let title = data.badge.hasSuffix("%") ? data.badge : "\(data.badge)%"
        _badgeButton.setTitle(title, for: .normal)
        _descTitle.text = data.title
        _descriptionLabel.setFontWieght(data.descriptions, 0.85)
        if !Utils.stringIsNullOrEmpty(data.ticketId) {
            _ticketModel = APPSETTING.ticketList?.first(where: { $0._id == data.ticketId })
            _venueInfoView.setupTicketData(_ticketModel ?? TicketModel())
        } else {
            _venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: data.venueId)
            _venueInfoView.setupData(venue: _venueDetailModel ?? VenueDetailModel(), isAllowClick: true)
        }
        _coverImage.loadWebImage(data.image)
        _venueId = _venueDetailModel?.id ?? kEmptyString
        _mainContainerView.hero.id = _venueId + "_open_detail_from_venue_event_cell" + data.id
        _mainContainerView.hero.modifiers = HeroAnimationModifier.stories
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleViewEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let venueDetail = _venueDetailModel else {
            return
        }
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = self._venueId
        vc.venueDetailModel = venueDetail
        vc.hidesBottomBarWhenPushed = false
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension VenueEventsCollectionCell: ScaleTransformView {
    var scaleOptions: ScaleTransformViewOptions {
        ScaleTransformViewOptions(
            minScale: 0.99,
            scaleRatio: 0.4 ,
            translationRatio: CGPoint(x: 0.89, y: 0.0),
            maxTranslationRatio: CGPoint(x: 2, y: 0)
        )
    }
}
