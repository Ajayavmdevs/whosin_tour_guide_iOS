import UIKit

class CustomTicketCollectionCell: UICollectionViewCell {    

    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _descriptionText: CustomLabel!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _startingAtPrice: UILabel!
    @IBOutlet private weak var _gallaryView: TicketListGallaryView!
    @IBOutlet weak var _discountView: UIView!
    @IBOutlet weak var _discountPercentage: UILabel!
    private var _ticketModel: TicketModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 315 }

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
            self._badgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._badgeView.layer.cornerRadius = 8
            self._gallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self._gallaryView.layer.cornerRadius = 10

        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: TicketModel) {
        _ticketModel = data
        _titleText.text = data.title
        if !Utils.stringIsNullOrEmpty(data.descriptions) {
            DISPATCH_ASYNC_MAIN {
                self._descriptionText.text = Utils.convertHTMLToPlainText(from: data.descriptions)
            }
        }
        _startingAtPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(data.startingAmount.formattedDecimal())".withCurrencyFont(14)
        let images = data.images.toArray(ofType: String.self)
        _gallaryView.setupHeader(images.filter({ !Utils.isVideo($0) }))
        _discountView.isHidden = data.discount == 0
        _discountPercentage.text = "\(data.discount)%"
        BOOKINGMANAGER.ticketModel = data
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleGetTicket(_ sender: CustomActivityButton) {
        guard let id = _ticketModel?._id else { return }
        let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        vc.ticketID = id
        vc.hidesBottomBarWhenPushed = true
        parentBaseController?.navigationController?.pushViewController(vc, animated: true)
    }

    
}
