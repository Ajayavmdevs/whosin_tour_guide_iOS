import UIKit
import WebKit
import PDFKit

class ViewRaynaTicketVC: ChildViewController {

    @IBOutlet weak var _scrollView: UIScrollView!
    @IBOutlet weak var _cancellationText: CustomLabel!
    @IBOutlet weak var _ticketHolderView: UIView!
    @IBOutlet private weak var _ticketName: CustomLabel!
    @IBOutlet private weak var _ticketDesc: CustomLabel!
    @IBOutlet private weak var _ticketImage: UIImageView!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _duration: UILabel!
    @IBOutlet private weak var _tourType: UILabel!
    @IBOutlet private weak var _tourOptionName: CustomLabel!
    @IBOutlet private weak var _tourDesc: CustomLabel!
    @IBOutlet private weak var _paxesabel: CustomLabel!
    @IBOutlet private weak var _guestNames: CustomLabel!
    @IBOutlet private weak var _ticketPrice: CustomLabel!
    @IBOutlet weak var _btnStack: UIStackView!
    @IBOutlet weak var _cancellationpolicy: UIStackView!
    @IBOutlet weak var _discount: CustomLabel!
    @IBOutlet weak var _finalPrice: CustomLabel!
    @IBOutlet weak var _discountStack: UIStackView!
    @IBOutlet weak var _finalAmmountStack: UIStackView!
    @IBOutlet weak var _cancelBookinBtn: UIView!
    @IBOutlet weak var _ticketID: CustomLabel!
    @IBOutlet weak var downloadBtn: CustomActivityButton!
    @IBOutlet weak var _downloadPDFBtn: CustomActivityButton!
    @IBOutlet weak var _cancelBtn: UIButton!
    @IBOutlet weak var _downloadBtnView: UIView!
    @IBOutlet weak var _cancelView: UIView!
    @IBOutlet weak var _pdfView: UIView!
    @IBOutlet weak var _btnsView: UIView!
    @IBOutlet weak var _pdfContainerView: UIView!
    @IBOutlet weak var _departureTime: UILabel!
    @IBOutlet weak var _totalPxInfo: CustomLabel!
    @IBOutlet weak var _pendingView: UIStackView!
    @IBOutlet weak var _confirmedView: UIStackView!
    @IBOutlet weak var _ticketUpdatebutton: CustomActivityButton!
    @IBOutlet weak var _bookingRefrenceView: UIStackView!
    @IBOutlet weak var _bookingRefrenceNo: CustomLabel!
    public var ticketBooking: TicketBookingModel?
    private var _webView: WKWebView!
    var createdAt: Date?
    private var updateTimer: Timer?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        if let booking = ticketBooking, let detail = booking.tourDetails.first {
            LOGMANAGER.logTicketEvent(.viewTicket, id: booking.id, name: detail.tour?.tourName ?? "")
        }
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    private func setupData() {
        if let url = self.ticketBooking?.downloadTicket, !Utils.stringIsNullOrEmpty(url) {
            showHUD()
            _scrollView.isHidden = true
            _pdfContainerView.isHidden = false
            _cancelBookinBtn.isHidden = ticketBooking?.cancellationPolicy.isEmpty == true ||
                                        !(ticketBooking?.cancellationPolicy.contains(where: { $0.percentage > 0 }) ?? false)
            displayPDF(url)
        }
        else {
            createdAt = Utils.stringToDate(ticketBooking?.createdAt, format: kStanderdDate)
            _bookingRefrenceView.isHidden = Utils.stringIsNullOrEmpty(ticketBooking?.referenceNo)
            startTicketUpdateTimer()
            _scrollView.isHidden = false
            _pdfContainerView.isHidden = true
            guard let data = ticketBooking?.tourDetails.first else { return }
            _bookingRefrenceNo.text = ticketBooking?.referenceNo
            let paxes = LANGMANAGER.localizedString(forKey: "numberOfPax", arguments: ["value1": "\(data.adult)","value2": "\(data.child)","value3": "\(data.infant)" ])
            _totalPxInfo.attributedText = Utils.setAtributedTitleText(title: "paxes".localized(), subtitle: paxes, titleFont: FontBrand.SFboldFont(size: 12.0), subtitleFont: FontBrand.SFregularFont(size: 12.0))
            let titleFont = FontBrand.SFboldFont(size: 12.0)
            let subtitleFont = FontBrand.SFregularFont(size: 12.0)
            _ticketID.text = ticketBooking?.id
            _ticketName.text = data.tour?.tourName
            _ticketDesc.text = Utils.convertHTMLToPlainText(from: data.tour?.customData?.descriptions ?? kEmptyString)
            _ticketImage.loadWebImage(data.tour?.customData?.images.first ?? kEmptyString)
            let time = Utils.stringIsNullOrEmpty(ticketBooking?.details.first?.slot) ?  Utils.stringToDate(data.startTime, format: "HH:mm:ss") : Utils.stringToDate(ticketBooking?.details.first?.slot, format: "HH:mm:ss")
            _timeLabel.text = Utils.dateToString(time, format: "HH:mm")
            let date = Utils.stringToDate(data.tourDate, format: kFormatDate)
            _dateLabel.text = Utils.dateToString(date, format: kFormatEventDate)
            _tourOptionName.text = data.tourOption?.optionName
            _tourDesc.text = data.tourOption?.optionDescription
            if let slot = ticketBooking?.details.first?.slot, !Utils.stringIsNullOrEmpty(slot) {
                let slotDate = Utils.stringToDate(slot, format: "HH:mm:ss")
                _duration.attributedText = Utils.setAtributedTitleText(title: "", subtitle: Utils.dateToString(slotDate, format: "HH:mm"), titleFont: titleFont, subtitleFont: subtitleFont)
            } else {
                _duration.attributedText = Utils.setAtributedTitleText(title: "", subtitle: data.tourOption?.duration ?? kEmptyString, titleFont: titleFont, subtitleFont: subtitleFont)
            }
            _tourType.attributedText = Utils.setAtributedTitleText(title: "tour_type".localized(), subtitle: data.tour?.cityTourType ?? kEmptyString, titleFont: titleFont, subtitleFont: subtitleFont)
            _departureTime.text = ticketBooking?.departureTime ?? ""
            _paxesabel.text = "guest_detail".localized()
            
            
            if let passengers = ticketBooking?.passengers, !passengers.isEmpty {
                if let primaryGuest = passengers.first(where: { $0.leadPassenger == 1 }) {
                    let fullName = "\(primaryGuest.prefix) \(primaryGuest.firstName) \(primaryGuest.lastName)"
                    _guestNames.text = "\(fullName) (\(primaryGuest.paxType)) (Primary Guest)"
                }
                
                if let tourDetails = ticketBooking?.tourDetails.first {
                    var additionalInfo = ""
                    let adult = tourDetails.adult - 1
                    if adult > 0 {
                        additionalInfo += "\(adult) x Adult\n"
                    }
                    if tourDetails.child > 0 {
                        additionalInfo += "\(tourDetails.child) x Child\n"
                    }
                    if tourDetails.infant > 0 {
                        additionalInfo += "\(tourDetails.infant) x Infant"
                    }
                    
                    if !additionalInfo.isEmpty {
                        if let existingText = _guestNames.text, !existingText.isEmpty {
                            _guestNames.text = existingText + "\n" + additionalInfo.trimmingCharacters(in: .whitespacesAndNewlines)
                        } else {
                            _guestNames.text = additionalInfo.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
            } else {
                _guestNames.text = ""
            }
            
            
            let serviceTotal = Double(data.serviceTotal) ?? 0.0
            let discount = data.tour?.customData?.discount ?? 0
            let discountValue = Utils.calculateDiscountValueDouble(originalPrice: serviceTotal, discountPercentage: discount)
            
            let formattedDiscountValue = Double(round(100 * discountValue) / 100)
            let formattedFinalAmount = Double(round(100 * serviceTotal) / 100)
            let discountPrice = formattedFinalAmount - formattedDiscountValue
            let formattedDiscountPrice =  Double(round(100 * discountPrice) / 100)
            
            _ticketPrice.text = String(format: "D %.2f", Double(round(100 * (ticketBooking?.totalAmount ?? 0)) / 100))
            _discount.text = String(format: "D %.2f", Double(round(100 * (ticketBooking?.discount ?? 0)) / 100))
            _finalPrice.text = String(format: "D %.2f", Double(round(100 * (ticketBooking?.amount ?? 0)) / 100))
            _discountStack.isHidden = ticketBooking?.discount == 0
            _finalAmmountStack.isHidden = ticketBooking?.amount == 0
            _cancelBookinBtn.isHidden = ticketBooking?.cancellationPolicy.isEmpty == true ||
                                        !(ticketBooking?.cancellationPolicy.contains(where: { $0.percentage > 0 }) ?? false)
            if ticketBooking?.bookingStatus == "initiated" {
                _pendingView.isHidden = false
                _confirmedView.isHidden = true
            } else {
                _pendingView.isHidden = true
                _confirmedView.isHidden = false
            }
        }
    }
    
    func displayPDF(_ url: String) {
        showHUD()
        
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        _webView = webView
        _pdfView.addSubview(_webView)
        NSLayoutConstraint.activate([
            _webView.topAnchor.constraint(equalTo: _pdfView.topAnchor),
            _webView.bottomAnchor.constraint(equalTo: _pdfView.bottomAnchor),
            _webView.leadingAnchor.constraint(equalTo: _pdfView.leadingAnchor),
            _webView.trailingAnchor.constraint(equalTo: _pdfView.trailingAnchor)
        ])

        guard let pdfURL = URL(string: url) else {
            hideHUD()
            return
        }
        let request = URLRequest(url: pdfURL)
        _webView.load(request)
        _webView.navigationDelegate = self
    }

    // --------------------------------------
    // MARK: Timer for Update Button
    // --------------------------------------

    private func startTicketUpdateTimer() {
        updateTimer?.invalidate()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
        
        updateRemainingTime()
    }
    
    private func updateRemainingTime() {
        guard let createdAt = createdAt else { return }
        
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(createdAt)
        
        let remainingTime = max(0, 10 * 60 - elapsedTime)
        
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        _ticketUpdatebutton.setTitle(String(format: "ticket_will_be_updated_in".localized() + "%02d:%02d", minutes, seconds), for: .normal)
        if remainingTime == 0 {
            updateTimer?.invalidate()
            NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
            _ticketUpdatebutton.setTitle(String(format: "ticket_will_be_updated_soon".localized()), for: .normal)
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requstCancelBooking(_ text: String) {
        guard let id = ticketBooking?.id else { return }
        showHUD()
        WhosinServices.raynaBookingCancel(id: id, bookingId: "0", cancellationReason: text) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            self.showSuccessMessage("Your Ticket \(ticketBooking?.tourDetails.first?.tour?.tourName ?? kEmptyString) Cancelled Successfully.", subtitle: kEmptyString)
            NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleCancelBooking(_ sender: UIButton) {
        let amount = ticketBooking?.amount.formatted()
        let refundAMount = Utils.calculateRefundAmount(amount: amount ?? 0.0, policies: ticketBooking?.cancellationPolicy ?? [])
        
        let vc = INIT_CONTROLLER_XIB(CancelBookingVC.self)
        vc.refundAmount = refundAMount ?? 0.0
        vc.submitCallback = { [weak self] text in
            guard let self = self else { return }
            self._requstCancelBooking(text)
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    @IBAction func _handleCancellationPolicyEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(CancellationPolicyBottomSheet.self)
//        vc.modalPresentationStyle = .overFullScreen
        vc.isFromBooking = true
        if let option = ticketBooking?.tourDetails.first?.tourOption {
            vc.tourOptionDataModel = option
        }
        vc._raynaTourPolicyModel = ticketBooking?.cancellationPolicy ?? []
        self.present(vc, animated: true)
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleDownloadTicketEvent(_ sender: UIButton) {
        downloadBtn.showActivity()
        _downloadPDFBtn.showActivity()
        if let urlString = self.ticketBooking?.downloadTicket, !Utils.stringIsNullOrEmpty(urlString) {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                downloadBtn.hideActivity()
                _downloadPDFBtn.hideActivity()
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                alert(title: kAppName, message: "URL is undefined")
            }
        } else {
            _btnStack.isHidden = true
            _cancellationpolicy.isHidden = true
            
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: _ticketHolderView.bounds)
            
            let data = pdfRenderer.pdfData { context in
                context.beginPage()
                _ticketHolderView.layer.render(in: context.cgContext)
            }
            
            _btnStack.isHidden = false
            _cancellationpolicy.isHidden = false
            downloadBtn.showActivity()
            if let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileName = "WhosIn\(ticketBooking?.id ?? "").pdf"
                let filePath = tempDirectory.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: filePath)
                    downloadBtn.hideActivity()
                    let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = sender
                    activityViewController.popoverPresentationController?.sourceRect = sender.frame
                    present(activityViewController, animated: true, completion: nil)
                } catch {
                    print("Error saving PDF to file: \(error.localizedDescription)")
                    downloadBtn.hideActivity()
                }
            }
        }
    }
    
    func downloadAndSharePDF(from urlString: String, sender: UIButton) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.downloadBtn.hideActivity()
                self._downloadPDFBtn.hideActivity()
            }
            return
        }

        // Start a URL session to download the PDF
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            // Handle error
            if let error = error {
                print("Download Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.downloadBtn.hideActivity()
                    self?._downloadPDFBtn.hideActivity()
                }
                return
            }

            // Ensure we received data
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self?.downloadBtn.hideActivity()
                    self?._downloadPDFBtn.hideActivity()
                }
                return
            }

            // Ensure that the file is a PDF
            if let mimeType = response?.mimeType, mimeType == "application/pdf" {
                DispatchQueue.main.async { [weak self] in
                    // Get the file path to save the PDF
                    if let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileName = "\(self?.ticketBooking?.referenceNo ?? "").pdf"
                        let filePath = tempDirectory.appendingPathComponent(fileName)

                        do {
                            // Write data to file
                            try data.write(to: filePath)
                            print("PDF saved at: \(filePath)")

                            // Hide activity indicators
                            self?.downloadBtn.hideActivity()
                            self?._downloadPDFBtn.hideActivity()

                            // Create and present the activity view controller to share the file
                            let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
                            activityViewController.popoverPresentationController?.sourceView = sender
                            activityViewController.popoverPresentationController?.sourceRect = sender.frame
                            self?.present(activityViewController, animated: true, completion: nil)
                        } catch {
                            print("Error saving PDF: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self?.downloadBtn.hideActivity()
                                self?._downloadPDFBtn.hideActivity()
                            }
                        }
                    }
                }
            } else {
                print("Downloaded file is not a PDF.")
                DispatchQueue.main.async {
                    self?.downloadBtn.hideActivity()
                    self?._downloadPDFBtn.hideActivity()
                }
            }
        }

        task.resume()
    }
    
}

extension ViewRaynaTicketVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

extension ViewRaynaTicketVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showHUD()
        _btnStack.isHidden = true
        _cancellationpolicy.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideHUD()
        _btnsView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideHUD()
        _btnsView.isHidden = false
        alert(message: "Failed to load the PDF. Please try again.")
    }
}
