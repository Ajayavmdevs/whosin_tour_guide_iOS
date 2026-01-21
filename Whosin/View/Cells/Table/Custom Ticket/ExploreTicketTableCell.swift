import UIKit

class ExploreTicketTableCell: UITableViewCell {
    
    @IBOutlet weak var _recentText: CustomLabel!
    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _descriptionText: CustomLabel!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _startingAtPrice: UILabel!
    @IBOutlet private weak var _gallaryView: TicketListGallaryView!
    @IBOutlet weak var _badgePrice: UILabel!
    @IBOutlet weak var _discountView: GradientView!
    @IBOutlet weak var _discountText: UILabel!
    @IBOutlet weak var _recentView: UIView!
    @IBOutlet weak var _likeBtn: CustomLikeButton!
    private var _ticketModel: TicketModel?
    @IBOutlet weak var _ratingView: UIView!
    @IBOutlet weak var _avgRatting: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _gallaryView.cornerRadius = 10
        self._gallaryView.clipsToBounds = true
        self._gallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadOnLike(_:)), name: .reloadOnLike, object: nil)
        setupUi()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _gallaryView.prepareForReuse()
        _ticketModel = nil
    }
    
    @objc private func handleReloadOnLike(_ notification: Notification) {
        if let data = notification.object as? [String: Any],
           let id = data["id"] as? String,
           let flag = data["flag"] as? Bool {
            if id == _ticketModel?._id {
                _ticketModel?.isFavourite = flag
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._badgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._badgeView.layer.cornerRadius = 8
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func clearData() {
        _gallaryView.setupHeader([])
        _gallaryView.isHidden = true
        _ticketModel = nil
        _titleText.text = "     "
        _descriptionText.text = "    "
        _startingAtPrice.text = "       "
        _avgRatting.text = ""
        _recentText.text = "           "
        _discountView.isHidden = true
    }
    
    public func setUpdata(_ data: TicketModel) {
        _ticketModel = data
        _recentView.isHidden = !data.tags.contains("Recently added")
        _recentText.text = "recently_added".localized()
        _likeBtn.isSelected = data.isFavourite
        _avgRatting.text = String(format: "%.1f", data.avg_ratings)
        _ratingView.isHidden = data.avg_ratings == 0 || data.avg_ratings == 0.0
        _likeBtn.tintColor = _likeBtn.isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.8)
        _discountText.text = "\(data.discount)%"
        _discountView.isHidden = data.discount == 0
        _titleText.text = data.title
        _descriptionText.text = data.city
        _startingAtPrice.attributedText = Utils.attributedText(data: data)
        _badgePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(data.startingAmount.formattedDecimal())".withCurrencyFont(18)
        _gallaryView.isHidden = false
        let filteredImages = data.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0) })
        _gallaryView.setupHeader(filteredImages)
        BOOKINGMANAGER.ticketModel = data
    }
    
    @IBAction func _handleLikeButton(_ sender: CustomLikeButton) {
        guard let ticketModel = _ticketModel else { return }
        _likeBtn.showActivity()
        WhosinServices.requestAddRemoveFav(id: ticketModel._id, type: "ticket") { [weak self] container, error in
            guard let self = self else { return }
            self._likeBtn.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            _ticketModel?.isFavourite = !(_ticketModel?.isFavourite ?? false)
            self._likeBtn.isSelected = _ticketModel?.isFavourite ?? false
            NotificationCenter.default.post(name: .reloadOnLike, object: ["id": ticketModel._id, "fav": !(_ticketModel?.isFavourite ?? false)])
            self.parentBaseController?.showSuccessMessage(_ticketModel?.isFavourite == true ?  "thank_you".localized() : "oh_snap".localized(), subtitle: _ticketModel?.isFavourite == true ? LANGMANAGER.localizedString(forKey: "add_favourite", arguments: ["value": _ticketModel?.title ?? ""]) : LANGMANAGER.localizedString(forKey: "remove_favourite", arguments: ["value": _ticketModel?.title ?? ""]))
        }
    }
}
