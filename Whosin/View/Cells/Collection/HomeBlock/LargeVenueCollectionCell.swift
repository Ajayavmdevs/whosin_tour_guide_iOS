import UIKit


class LargeVenueCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    private var _venueDetail: VenueDetailModel?
    @IBOutlet weak var _discountLbl: UILabel!

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 272 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._mainContainerView.cornerRadius = 10
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: VenueDetailModel) {
        _venueInfoView.setupData(venue: data)
        if Utils.stringIsNullOrEmpty(data.discountText) {
            _discountLbl.superview?.isHidden = true
            _discountLbl.text = ""
        } else {
            _discountLbl.superview?.isHidden = false
            _discountLbl.text = "🔥 " + data.discountText 
        }

        _venueDetail = data
        _coverImage.loadWebImage(data.cover)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleInviteEvent(_ sender: UIButton) {
    }
    
    @IBAction func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.veneuDetail = _venueDetail
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
}

