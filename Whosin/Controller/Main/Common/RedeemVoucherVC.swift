import UIKit
import PDFKit
import StripeCore

class RedeemVoucherVC: PanBaseViewController {
    
    @IBOutlet weak var _downlaodBtn: UIButton!
    @IBOutlet weak var _paxLabel: UILabel!
    @IBOutlet weak var _cardView: UIView!
    @IBOutlet weak var _qrCodeImageView: UIImageView!
    @IBOutlet weak var _logoImg: UIImageView!
    @IBOutlet weak var _covoreImage: UIImageView!
    @IBOutlet weak var _venueAddress: UILabel!
    @IBOutlet weak var _venueTitle: UILabel!
    @IBOutlet weak var _logoBgView: UIView!
    @IBOutlet weak var _totalVoucher: UILabel!
    @IBOutlet weak var _voucherName: UILabel!
    @IBOutlet weak var _voucherDisc: UILabel!
    @IBOutlet weak var _voucherPrice: UILabel!
    @IBOutlet weak var _voucherDetail: UILabel!
    @IBOutlet weak var _holderName: UILabel!
    @IBOutlet weak var _date: UILabel!
    public var type: String = kEmptyString
    public var vouchersList: VouchersListModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        if vouchersList?.type == "activity" {
            guard let activity = vouchersList?.activity else { return }
            _venueTitle.text = activity.provider?.name
            _venueAddress.text = activity.provider?.address
            _logoImg.loadWebImage(activity.provider?.logo ?? "")
            _covoreImage.loadWebImage(activity.cover)
            _voucherDisc.text = activity.descriptions
            _voucherName.text = activity.name
            _voucherPrice.text = "D\(activity._disocuntedPrice)"
            _holderName.text = APPSESSION.userDetail?.fullName
            _voucherDetail.text = activity.descriptions
            _totalVoucher.text = "(X\(vouchersList?.items.reduce(0) { $0 + $1.remainingQty } ?? 0))"

            guard let date = vouchersList?.items.first?._activityDate else { return }
            if let startTime = vouchersList?.items.first?.time.components(separatedBy: "-").first, let time = Utils.stringToDate(startTime, format: kFormatDateTimeUS) {
                let dateText = "\(Utils.dateToString(date, format: "dd MMM, yyyy")) at \(Utils.dateToString(time, format: "HH:mm"))"
                _date.text = dateText
                if Utils.isDateExpired(dateString: dateText, format: "dd MMM, yyyy 'at' HH:mm") {
                    _qrCodeImageView.image = UIImage(named: "image_expired")
                    _downlaodBtn.isHidden = true
                    _qrCodeImageView.cornerRadius = 1
                } else {
                    _downlaodBtn.isHidden = false
                    if let qrImage = Utils.generateQRCode(from: vouchersList?.uniqueCode ?? "", with: CGSize(width: 200, height: 200)) {
                        _qrCodeImageView.image = qrImage
                    }
                }
            }

        } else if vouchersList?.type == "deal" {
            if let deal = vouchersList?.deal {
                let venue = APPSETTING.venueModel?.filter({ $0.id == deal.venueId  }).first
                _venueTitle.text = venue?.name
                _venueAddress.text = venue?.address
                _logoImg.loadWebImage(venue?.logo ?? "")
                _covoreImage.loadWebImage(venue?.cover ?? "")
                _voucherDisc.text = "Paxes per voucher"
                _voucherName.text = deal.title
                _holderName.text = APPSESSION.userDetail?.fullName
                _voucherDetail.text = deal.descriptions
                _totalVoucher.text = "(X\(vouchersList?.items.reduce(0) { $0 + $1.remainingQty } ?? 0))"
                _paxLabel.text = "\(deal.paxPerVoucher)"
                guard let date = Utils.stringToDate(deal.endDate, format: "yyyy-MM-dd") else { return }
                guard let time = Utils.stringToDate(deal.endTime, format: "HH:mm") else { return }
                _date.text = "\(Utils.dateToString(date, format: "dd MMM, yyyy")) at \(Utils.dateToString(time, format: "HH:mm"))"
                if deal._isExpired {
                    _qrCodeImageView.image = UIImage(named: "image_expired")
                    _downlaodBtn.isHidden = true
                    _qrCodeImageView.cornerRadius = 1
                } else {
                    _downlaodBtn.isHidden = false
                    if let qrImage = Utils.generateQRCode(from: deal.id, with: CGSize(width: 200, height: 200)) {
                        _qrCodeImageView.image = qrImage
                    }
                }
            }
        }
        
        
    }
        
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleDownoadEvent(_ sender: UIButton) {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: _cardView.bounds)
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            _cardView.layer.render(in: context.cgContext)
        }
        let pdfDocument = PDFDocument(data: data)
        if let pdfData = pdfDocument?.dataRepresentation(), let filePath = Utils.savePDFFileToLocal(data: pdfData, fileName: "WhosIn\(vouchersList?.id ?? "").pdf") {
            
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath.path) {
                print("PDF file not found")
                return
            }
            let documentInteractionController = UIDocumentInteractionController(url: filePath)
            documentInteractionController.delegate = self
            documentInteractionController.presentOptionsMenu(from: sender.frame, in: view, animated: true)
        }
    }
    
}

extension RedeemVoucherVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
