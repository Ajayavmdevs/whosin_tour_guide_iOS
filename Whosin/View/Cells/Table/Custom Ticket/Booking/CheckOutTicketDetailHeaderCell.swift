import UIKit
import FloatRatingView
import ExpandableLabel
import CountdownLabel
import MapKit

class CheckOutTicketDetailHeaderCell: UITableViewCell {
    
    @IBOutlet weak var _gallayView: CustomTicketGalleryView!
    @IBOutlet private weak var _titleText: UILabel!
    @IBOutlet private weak var _descriptionText: ExpandableLabel!
    @IBOutlet private weak var _descriptionView: UIView!
    private var ticketModel: TicketModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _descriptionText.isUserInteractionEnabled = true
        _descriptionText.addGestureRecognizer(tapGesture)
        _descriptionText.delegate = self
        _descriptionText.shouldCollapse = false
        _descriptionText.shouldExpand = false
        _descriptionText.numberOfLines = 3
        _descriptionText.ellipsis = NSAttributedString(string: "....")
        _descriptionText.collapsedAttributedLink = NSAttributedString(string: "see_more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _descriptionText.setLessLinkWith(lessLink: "see_less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
    }
       
    @objc private func labelTapped() {
        let vc = INIT_CONTROLLER_XIB(DeclaimerBottomSheet.self)
        vc.disclaimerTitle = "description".localized()
        vc.disclaimerdescriptions = ticketModel?.descriptions ?? ""
        parentBaseController?.presentAsPanModal(controller: vc)
    }
    
    deinit {
        _gallayView.pauseVideos()
    }
    
    public func cellDidDisappear() {
        _gallayView.pauseVideos()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: TicketModel) {
        self.ticketModel = model
        _gallayView.setupData(model.images.toArray(ofType: String.self))
        _titleText.text = model.title.isEmpty ? model.tourData?.tourName : model.title
        if Utils.stringIsNullOrEmpty(model.descriptions) {
            _descriptionText.text = kEmptyString
            _descriptionView.isHidden = true
        }
        else {
            _descriptionText.text = Utils.convertHTMLToPlainText(from: model.descriptions)
            _descriptionView.isHidden = Utils.stringIsNullOrEmpty(_descriptionText.text)
        }
//        _discountView.isHidden = model.discount == 0
//        _discountPercentage.text = "\(model.discount)%"
    }
    
}

extension CheckOutTicketDetailHeaderCell: ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        labelTapped()
        label.collapsed = false
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
    }
}
