import UIKit

class SmallVenueCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _venueInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _bookButton: UIButton!
    private var _venueDetailModel: VenueDetailModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.03) { [self] in
            self._bookButton.layer.cornerRadius = self._bookButton.frame.size.height / 2
        }
    }
    
    override func prepareForReuse() {
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 56 }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: VenueDetailModel) {
        _venueDetailModel = data
        _venueInfoView.setupData(venue: data)
    }

    @IBAction private func _handleViewEvent(_ sender: UIButton) {
        guard let _venueDetailModel = _venueDetailModel else { return }
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = _venueDetailModel.id
        vc.venueDetailModel = _venueDetailModel
        vc.hidesBottomBarWhenPushed = false
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
