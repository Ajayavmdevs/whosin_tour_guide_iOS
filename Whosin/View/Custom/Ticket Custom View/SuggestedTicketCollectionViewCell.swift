import UIKit

class SuggestedTicketCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _startingAtPrice: UILabel!
    @IBOutlet weak var _gallaryView: TicketListGallaryView!
    @IBOutlet weak var _discountView: UIView!
    @IBOutlet weak var _badgePrice: UILabel!
    @IBOutlet weak var _discountAmmount: UILabel!
    @IBOutlet weak var _ratingView: UIView!
    @IBOutlet weak var _avgRatting: UILabel!
    @IBOutlet weak var _likebutton: CustomLikeButton!
    @IBOutlet weak var _recentlyView: UIView!
    private var _ticketModel: TicketModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 290 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadOnLike(_:)), name: .reloadOnLike, object: nil)
        setupUi()
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      isTouched = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesEnded(touches, with: event)
      isTouched = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
      isTouched = false
    }
    
    public var isTouched: Bool = false {
      didSet {
        var transform = CGAffineTransform.identity
        if isTouched { transform = transform.scaledBy(x: 0.96, y: 0.96) }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
          self.transform = transform
        }, completion: nil)
      }
    }
    
    @objc private func handleReloadOnLike(_ notification: Notification) {
        if let data = notification.object as? [String: Any],
           let id = data["id"] as? String,
           let flag = data["flag"] as? Bool {
            if id == _ticketModel?._id {
                _ticketModel?.isFavourite = !flag
                _likebutton.isSelected = !flag
                _likebutton.tintColor = _likebutton.isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.8)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _badgeView.isHidden = false
        _titleText.text = ""
        _startingAtPrice.attributedText = nil
        _discountView.isHidden = true
        _badgePrice.text = ""
        _discountAmmount.text = ""
        _ratingView.isHidden = true
        _avgRatting.text = ""
        _likebutton.isSelected = false
        _recentlyView.isHidden = true
        _ticketModel = nil
        _gallaryView.prepareForReuse()
        isTouched = false
    }

    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._badgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._badgeView.layer.cornerRadius = 8
            self._gallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self._gallaryView.layer.cornerRadius = 10
            self._gallaryView.clipsToBounds = true
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: TicketModel) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let images = data.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0)})
            DISPATCH_ASYNC_MAIN {
                self._gallaryView.setupHeader(images)
            }
        }
        _startingAtPrice.isHidden = data.startingAmount == 0
        _badgeView.isHidden = data.startingAmount == 0
        _recentlyView.isHidden = !data.tags.contains("Recently added")
        _likebutton.isSelected = data.isFavourite
        _likebutton.tintColor = _likebutton.isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.8)
        _discountView.isHidden = data.discount == 0
        _avgRatting.text = String(format: "%.1f", data.avg_ratings)
        _ratingView.isHidden = data.avg_ratings == 0 || data.avg_ratings == 0.0
        _discountAmmount.text = "\(data.discount)%"
        _ticketModel = data
        _titleText.text = data.title

        DISPATCH_ASYNC_BG{
            let txt = Utils.attributedText(data: data)
            DISPATCH_ASYNC_MAIN {
                self._startingAtPrice.attributedText = txt
            }
        }
        

        _badgePrice.attributedText = "\(Utils.getCurrentCurrencySymbol()) \(data.startingAmount.formattedDecimal())".withCurrencyFont(15)
        BOOKINGMANAGER.ticketModel = data
    }
    
    
    @IBAction func _handleLikeEvent(_ sender: CustomLikeButton) {
        guard let model = _ticketModel else { return }
        _likebutton.showActivity()
        WhosinServices.requestAddRemoveFav(id: model._id, type: "ticket") { [weak self] container, error in
            guard let self = self else { return }
            self._likebutton.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            _ticketModel?.isFavourite = !(_ticketModel?.isFavourite ?? false)
            self._likebutton.isSelected = _ticketModel?.isFavourite ?? false
            NotificationCenter.default.post(name: .reloadOnLike, object: ["id": model._id, "flag": !(_ticketModel?.isFavourite ?? false)])
            self.parentBaseController?.showSuccessMessage(_ticketModel?.isFavourite == true ?  "thank_you".localized() : "oh_snap".localized(), subtitle: _ticketModel?.isFavourite == true ? LANGMANAGER.localizedString(forKey: "add_favourite", arguments: ["value": _ticketModel?.title ?? ""]) : LANGMANAGER.localizedString(forKey: "remove_favourite", arguments: ["value": _ticketModel?.title ?? ""]))
        }

    }
    
}

