import Foundation
import UIKit
import SnapKit


class CustomVenueInfoView: UIView {
    
    @IBOutlet weak var _logoHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var _logoWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var _venueClcikView: UIView!
    @IBOutlet weak var _venueBtn: UIButton!
    @IBOutlet private weak var _logoBgView: UIView!
    @IBOutlet private weak var _venueLogoImage: UIImageView!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _venueAddress: UILabel!
    var venueId: String = kEmptyString
    var ticketId: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        return 52
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public class func initFromNib() -> CustomVenueInfoView {
        UINib(nibName: "CustomVenueInfoView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! CustomVenueInfoView
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomVenueInfoView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(CustomVenueInfoView.height)
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._logoBgView.layer.cornerRadius = self._logoBgView.frame.size.height / 2
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._imageBgTap))
            self._logoBgView.addGestureRecognizer(gesture)
        }

    }
    
    public func setupData(venue: VenueDetailModel, isAllowClick: Bool = false, showSkeleton: Bool = true, isSmallView: Bool = false) {
        if isAllowClick {
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._clickToOpenVenue))
            _venueClcikView.addGestureRecognizer(gesture)
        }
        if Utils.stringIsNullOrEmpty(venue.address) {
            _venueAddress.text = venue.website
        } else {
            _venueAddress.text = venue.address
        }
        _venueName.text = venue.name
        if venue.logo.isEmpty && venue.name.isEmpty {
            _venueLogoImage.image = nil
        } else {
            if showSkeleton {
                _venueLogoImage.loadWebImage(venue.logo, name: venue.name)
            } else {
                _venueLogoImage.loadWebImageWithoutSkeleton(venue.logo)
            }
        }
        venueId = venue.id
        _logoBgView.setupStoryRing(venue: venue)
        _venueName.font = FontBrand.SFboldFont(size: isSmallView ? 16 : 18)
        _venueAddress.font = FontBrand.SFregularFont(size: isSmallView ? 10 : 12)
        _logoWidthConstraints.constant = isSmallView ? 40 : 44
        _logoHeightConstraints.constant = isSmallView ? 40 : 44
        self._logoBgView.layer.cornerRadius = self._logoBgView.frame.size.height / 2
        _venueLogoImage.layer.cornerRadius = self._venueLogoImage.frame.size.height / 2
    }
    
    public func setupEventData(name: String,image: String, discription: String) {
        _venueLogoImage.cornerRadius = 8
        _venueAddress.text = discription
        _venueName.text = name
        _venueLogoImage.loadWebImage(image, name: name)
    }
    
    public func setupYachtData(yacht: YachtClubModel) {
        if Utils.stringIsNullOrEmpty(yacht.address) {
            _venueAddress.text = yacht.website
        } else {
            _venueAddress.text = yacht.address
        }
        _venueName.text = yacht.name
        if yacht.logo.isEmpty && yacht.name.isEmpty {
            _venueLogoImage.image = nil
        }
        _venueLogoImage.loadWebImageWithoutSkeleton(yacht.logo)
    }
    
    public func setupTicketData(_ ticket: TicketModel) {
//        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._clickToOpenVenue))
//        _venueClcikView.addGestureRecognizer(gesture)
        ticketId = ticket._id
        _venueName.text = ticket.title
        DISPATCH_ASYNC_BG {
            let image = ticket.images.filter({ !Utils.isVideo($0)}).first ?? ""
//            let descriptions = Utils.convertHTMLToPlainText(from: ticket.descriptions)
            DISPATCH_ASYNC_MAIN {
//                self._venueAddress.text = descriptions
                self._venueLogoImage.loadWebImageWithoutSkeleton(image)
            }
        }
    }

    public func setupEmptyData() {
        _venueAddress.text = kEmptyString
        _venueName.text = kEmptyString
        _venueLogoImage.image = nil
        venueId = kEmptyString
    }

    public func setupProviderData(venue: ProviderModel) {
        _venueAddress.text = venue.address
        _venueName.text = venue.name
        if venue.logo.isEmpty && venue.name.isEmpty {
            _venueLogoImage.image = nil
        } else {
            _venueLogoImage.loadWebImage(venue.logo, name: venue.name)
        }
        venueId = venue.id
        _showStoryRing()
    }
  
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    private func _showStoryRing() {
        if !venueId.isEmpty {
            _logoBgView.setupStoryRing(id: venueId)
        }
    }

    
    @objc func _imageBgTap(sender : UITapGestureRecognizer) {
        if venueId.isEmpty { return }
        guard let venues = HomeRepository.getStoryArrayByVenueId(venueId) else { return }
        let randomStr = Utils.randomString(length: 20, id: venueId)
        let _logoHeroId = venueId + "_story_" + randomStr
        _logoBgView.hero.id = _logoHeroId
        _logoBgView.hero.modifiers = HeroAnimationModifier.stories
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = venues
        controller.currentIndex = 0
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = _logoHeroId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        parentViewController?.present(controller, animated: true)
    }
    
    @objc func _clickToOpenVenue(sender : UITapGestureRecognizer) {
        if !Utils.stringIsNullOrEmpty(ticketId) {
            if ticketId.isEmpty { return }
            if let pv = parentViewController?.presentingViewController as? CustomTicketDetailVC, pv.ticketID == ticketId {
                parentViewController?.navigationController?.popViewController(animated: true)
                return
            }
            let controller = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            controller.ticketID = ticketId
            controller.hidesBottomBarWhenPushed = true
            if parentViewController != nil {
                parentViewController?.navigationController?.pushViewController(controller, animated: true)
            } else if parentBaseController != nil {
                parentBaseController?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
}

