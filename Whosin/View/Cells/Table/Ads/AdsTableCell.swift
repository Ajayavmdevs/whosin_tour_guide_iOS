import UIKit

class AdsTableCell: UITableViewCell {

    // Large
    @IBOutlet private weak var _largeView: UIView!
    @IBOutlet private weak var _adTitle: UILabel!
    @IBOutlet private weak var _adSubtitle: UILabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _venueLogo: UIImageView!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _venueDesc: UILabel!
    @IBOutlet private weak var _discountedPrice: UIButton!
    @IBOutlet private weak var _adBadge: UIButton!
    @IBOutlet private weak var _viewBtn: UIButton!
    
    // Medium
    @IBOutlet private weak var _mediumView: UIView!
    @IBOutlet private weak var _mCoverImage: UIImageView!
    @IBOutlet private weak var _mVenueLogo: UIImageView!
    @IBOutlet private weak var _mVenueName: UILabel!
    @IBOutlet private weak var _mVenueDes: UILabel!
    
    private var _currentAd: AdListModel?
    
    var refreshTimer: Timer?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class func height(_ size: AdSize) -> CGFloat {
        switch size {
            case .none:
                return 0
            case .small:
                return 200
            case .medium:
                return 290
            case .large:
                return 370
        }
    }
    
    class var cellProtoType: [String:Any] {
        return [kCellIdentifierKey: String(describing: AdsTableCell.self), kCellNibNameKey: String(describing: AdsTableCell.self), kCellClassKey: AdsTableCell.self, kCellHeightKey: AdsTableCell.height(.large)]
    }
    
    class func cellData(_ adSize: AdSize) -> [String:Any] {
       return [
            kCellIdentifierKey: String(describing: AdsTableCell.self),
            kCellTagKey: String(describing: AdsTableCell.self),
            kCellObjectDataKey: String(describing: AdsTableCell.self),
            kCellClassKey: AdsTableCell.self,
            kCellHeightKey: AdsTableCell.height(adSize)
        ]
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if ADSETTING.getAd != nil {
            setupData(.large)
        }
        
        refreshTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)

        _discountedPrice.roundCorners(corners: [.bottomLeft], radius: 10)
        _adBadge.roundCorners(corners: [.bottomRight], radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestAdLogCreate(adIds: [String], logType: String) {
        WhosinServices.adLogCreate(adsIds: adIds, logType: logType) { [weak self] container, error in
            guard let self = self else { return }
        }
    }
    
    public func setupData(_ adSize: AdSize) {
        if let data = ADSETTING.getAd {
            _currentAd = data
            _requestAdLogCreate(adIds: [data.id], logType: "view")
            switch adSize {
            case .none:
                break
            case .small:
                _mediumView.isHidden = true
                _largeView.isHidden = true
                
            case .medium:
                _largeView.isHidden = true
                _mediumView.isHidden = false
                
            case .large:
                _mediumView.isHidden = true
                _largeView.isHidden = false
                _adTitle.text = data.headline
                _adSubtitle.text = data.subHeadline
                _coverImage.loadWebImage(data.background)
                _venueLogo.loadWebImage(data.logo)
                _venueName.text = data.title
                _venueDesc.text = data.subTitle
                if data.badgeText.hasSuffix("%") {
                    _discountedPrice.setTitle(data.badgeText)
                } else {
                    _discountedPrice.setTitle("\(data.badgeText)%")
                }

                _discountedPrice.setTitle(data.badgeText)
                _viewBtn.setTitle(data.buttonText)
            }
        }
    }
    
    @objc func refreshData() {
        setupData(.large)
    }

    deinit {
        refreshTimer?.invalidate()
    }
    
    @IBAction private func _handleViewEvent(_ sender: UIButton) {
        guard let ads = _currentAd else {return}
        _requestAdLogCreate(adIds: [ads.id], logType: "click")
        _openView(ads)
    }
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            parentBaseController?.alert(title: kAppName, message: "URL is undefined")
        }
    }
    
    private func _openView(_ ads: AdListModel) {
    
        switch ads.type {
        case "link":
            _openURL(urlString: ads.item)
        case "ticket":
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = ads.item
            vc.hidesBottomBarWhenPushed = true
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
}
