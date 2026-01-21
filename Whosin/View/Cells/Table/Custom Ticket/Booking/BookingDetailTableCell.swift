import UIKit
import PassKit

class BookingDetailTableCell: UITableViewCell {

    @IBOutlet weak var _bookingRefrenceLbl: CustomLabel!
    @IBOutlet weak var _grettingsText: CustomLabel!
    @IBOutlet weak var _totalPrice: CustomLabel!
    @IBOutlet weak var downloadBtn: CustomActivityButton!
    @IBOutlet weak var _downloadBgView: UIView!
    @IBOutlet weak var _ticketName: CustomLabel!
    @IBOutlet weak var _ticketDescription: CustomLabel!
    @IBOutlet weak var _ticketImage: UIImageView!
    @IBOutlet weak var _downloadView: TimeProgressBar!
    @IBOutlet weak var _addToWalletView: UIView!
    @IBOutlet weak var _addToWalletBtn: CustomActivityButton!
    private var bookingModel: TicketBookingModel?
    var createdAt: Date?
    private var updateTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _grettingsText.attributedText = getAttributedText(boldText: "thank_you_for_booking_with_us".localized(), fullText: "thank_you_for_booking_with_us_you_can_download_tickets".localized())
    }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func getAttributedText(boldText: String, fullText: String, fontSize: CGFloat = 13) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: fullText)
        let regularFont = FontBrand.SFregularFont(size: fontSize)
        attributedText.addAttribute(.font, value: regularFont, range: NSRange(location: 0, length: attributedText.length))
        if let boldRange = fullText.range(of: boldText) {
            let nsRange = NSRange(boldRange, in: fullText)
            let boldFont = FontBrand.SFboldFont(size: fontSize)
            attributedText.addAttribute(.font, value: boldFont, range: nsRange)
        }
        return attributedText
    }



    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ model: TicketBookingModel, voucher: VouchersListModel) {
        bookingModel = model
        if model.bookingType == "travel-desk" {
            _bookingRefrenceLbl.text = model.bookingCode
            
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(model.amount).formattedWithoutDecimal())".withCurrencyFont(16)
            _ticketName.text = model.tourDetails.first?.customTicket?.title
            _ticketDescription.text = Utils.convertHTMLToPlainText(from: model.tourDetails.first?.customTicket?.descriptions ?? "")
            let image =  model.tourDetails.first?.customTicket?.images.first ?? ""
            _ticketImage.loadWebImage(image)
        } else if model.bookingType == "big-bus" || model.bookingType == "hero-balloon" {
            _bookingRefrenceLbl.text = model.bookingCode
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(model.amount).formattedWithoutDecimal())".withCurrencyFont(16)
            _ticketName.text = model.tourDetails.first?.customTicket?.title
            _ticketDescription.text = Utils.convertHTMLToPlainText(from: model.tourDetails.first?.customTicket?.descriptions ?? "")
            let image =  model.tourDetails.first?.customTicket?.images.first ?? ""
            _ticketImage.loadWebImage(image)
        } else if model.bookingType == "juniper-hotel" {
            _bookingRefrenceLbl.text = model.bookingCode
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(model.amount).formattedWithoutDecimal())".withCurrencyFont(16)
            _ticketName.text = model.tourDetails.first?.customTicket?.title
            _ticketDescription.text = Utils.convertHTMLToPlainText(from: model.tourDetails.first?.customTicket?.descriptions ?? "")
            let image =  model.tourDetails.first?.customTicket?.images.first ?? ""
            _ticketImage.loadWebImage(image)
        } else {
            _bookingRefrenceLbl.text = model.bookingType == "whosin-ticket" ? Utils.stringIsNullOrEmpty(model.bookingCode) ? model.referenceNo : model.bookingCode : model.referenceNo
            _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Utils.convertCurrent(model.amount).formattedWithoutDecimal())".withCurrencyFont(16)
            _ticketName.text = model.bookingType == "whosin-ticket" ? Utils.stringIsNullOrEmpty(model.tourDetails.first?.customData?.title ) ? model.tourDetails.first?.customTicket?.title : model.tourDetails.first?.customData?.title : model.tourDetails.first?.tour?.customData?.title
            _ticketDescription.text = Utils.convertHTMLToPlainText(from: model.bookingType == "whosin-ticket" ? model.tourDetails.first?.customData?.descriptions ?? "" : model.tourDetails.first?.tour?.customData?.descriptions ?? "")
        

            let image = model.bookingType == "whosin-ticket" ? Utils.stringIsNullOrEmpty(model.tourDetails.first?.tourOption?.images.first) ? model.tourDetails.first?.customData?.images.first ?? "" : model.tourDetails.first?.tourOption?.images.first ?? "" :  model.tourDetails.first?.tour?.customData?.images.first ?? ""
            _ticketImage.loadWebImage(image)
        }
        _addToWalletView.isHidden = !(PKAddPassesViewController.canAddPasses())
        let isDownloadEmpty = Utils.stringIsNullOrEmpty(model.downloadTicket)
        if model.bookingStatus == "initiated" {
        createdAt = Utils.stringToDate(voucher.createdAt, format: kStanderdDate)
            startTicketUpdateTimer()
            _downloadBgView.backgroundColor = ColorBrand.clear
            downloadBtn.setTitleColor(ColorBrand.white, for: .normal)
            downloadBtn.isEnabled = false
            _addToWalletView.isHidden = true
        } else if model.paymentStatus == "paid" && (model.bookingStatus == "rejected" || model.bookingStatus == "failed") {
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(voucher._createdAt)

            let totalDuration: TimeInterval = 15 * 60 // 15 minutes
            let remainingTime = max(0, totalDuration - elapsedTime)
            if remainingTime == 0 {
                _downloadBgView.backgroundColor = .clear
                _downloadView.backgroundColor = .clear
                downloadBtn.setTitleColor(ColorBrand.buyNowColor, for: .normal)
                downloadBtn.isEnabled = true
                _addToWalletView.isHidden = true
                downloadBtn.setTitle(model.paymentStatus == "refunded" ? "booking_failed_refunded".localized() : "booking_failed".localized())
            } else {
                createdAt = voucher._createdAt
                startTicketUpdateTimer()
                _downloadBgView.backgroundColor = ColorBrand.clear
                downloadBtn.setTitleColor(ColorBrand.white, for: .normal)
                downloadBtn.isEnabled = false
                _addToWalletView.isHidden = true
            }
        } else if model.paymentStatus == "paid" && model.bookingStatus == "confirmed" {
            _downloadBgView.backgroundColor = isDownloadEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
            _downloadView.backgroundColor = isDownloadEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
            downloadBtn.setTitleColor(ColorBrand.white, for: .normal)
            downloadBtn.isEnabled = isDownloadEmpty ? false : true
            downloadBtn.setTitle("download_ticket".localized())
        } else if model.paymentStatus == "paid" && model.bookingStatus == "completed" {
            _downloadBgView.backgroundColor = isDownloadEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
            _downloadView.backgroundColor = isDownloadEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
            downloadBtn.setTitleColor(ColorBrand.white, for: .normal)
            downloadBtn.isEnabled = isDownloadEmpty ? false : true
            _addToWalletView.isHidden = false
        } else if model.bookingStatus == "failed" {
            _downloadBgView.backgroundColor = .clear
            _downloadView.backgroundColor = .clear
            downloadBtn.setTitleColor(ColorBrand.buyNowColor, for: .normal)
            downloadBtn.isEnabled = true
            _addToWalletView.isHidden = true
            downloadBtn.setTitle(model.paymentStatus == "refunded" ? "booking_failed_refunded".localized() : "booking_failed".localized())
        } else if model.bookingStatus == "cancelled" {
            _downloadBgView.backgroundColor = .clear
            _downloadView.backgroundColor = .clear
            downloadBtn.isEnabled = false
            downloadBtn.setTitleColor(ColorBrand.brandPink, for: .normal)
            _addToWalletView.isHidden = true
            downloadBtn.setTitle(LANGMANAGER.localizedString(forKey: "booking_cancelled", arguments: ["value": model.paymentStatus]))
        }
    }
    
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

        let totalDuration: TimeInterval = 15 * 60 // 15 minutes
        let remainingTime = max(0, totalDuration - elapsedTime)

        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        let regularText = "ticket_will_be_updated_in".localized()
        let timeText = String(format: "%02d:%02d", minutes, seconds)
        let fullText = regularText + timeText
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: FontBrand.SFregularFont(size: 15), range: NSRange(location: 0, length: fullText.count))
        if let timeRange = fullText.range(of: timeText) {
            let nsRange = NSRange(timeRange, in: fullText)
            attributedString.addAttribute(.font, value: FontBrand.SFboldFont(size: 15), range: nsRange)
        }

        downloadBtn.setAttributedTitle(attributedString, for: .normal)

        let progress = min(max(CGFloat(elapsedTime / totalDuration), 0), 1)
        _downloadView.setProgress(progress)

        if remainingTime == 0 {
            updateTimer?.invalidate()
            NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
            downloadBtn.setTitle("ticket_will_be_updated_soon".localized(), for: .normal)
            downloadBtn.setAttributedTitle(attributedString, for: .normal)
            _downloadView.setProgress(1)
            self.parentViewController?.navigationController?.popViewController(animated: true)
        }
    }

    
    func downloadAndPresentMultiplePasses(from urls: [URL]) {
        var downloadedPasses: [PKPass] = []
        let downloadGroup = DispatchGroup()

        self._addToWalletBtn.showActivity()
        self._addToWalletBtn.setImage(nil)

        for url in urls {
            downloadGroup.enter()
            URLSession.shared.downloadTask(with: url) { localURL, response, error in
                defer { downloadGroup.leave() }

                guard let localURL = localURL, error == nil else {
                    print("Error downloading pass: \(error?.localizedDescription ?? "unknown")")
                    return
                }

                do {
                    let data = try Data(contentsOf: localURL)
                    let pass = try PKPass(data: data)
                    downloadedPasses.append(pass)
                } catch {
                    print("Failed to create PKPass from \(url): \(error)")
                }
            }.resume()
        }

        downloadGroup.notify(queue: .main) {
            self._addToWalletBtn.hideActivity()
            self._addToWalletBtn.setImage(UIImage(named: "ic_appleWallet"))

            if downloadedPasses.isEmpty {
                self.parentBaseController?.alert(title: "apple_wallet".localized(), message: "no_valid_passes_could_be_downloaded.".localized())
                return
            }
            
            let passLibrary = PKPassLibrary()
            let newPasses = downloadedPasses.filter { !passLibrary.containsPass($0) }

            if newPasses.isEmpty {
                self.parentBaseController?.alert(title: "apple_wallet".localized(), message: "all_passes_are_already_added_to_wallet".localized())
                return
            }


            self.presentPass(newPasses)
        }
    }

    func downloadAndPresentPass(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                self._addToWalletBtn.hideActivity()
                self.parentBaseController?.alert(message: "Error downloading pass: \(error?.localizedDescription ?? "unknown")")
                self._addToWalletBtn.hideActivity()
                self._addToWalletBtn.setImage(UIImage(named: "ic_appleWallet"))

                return
            }
            
            do {
                let data = try Data(contentsOf: localURL)
                let pass = try PKPass(data: data)
                
                DispatchQueue.main.async {
                    self._addToWalletBtn.hideActivity()
                    self._addToWalletBtn.setImage(UIImage(named: "ic_appleWallet"))
                    self.presentPass([pass])
                }
            } catch {
                self._addToWalletBtn.hideActivity()
                self._addToWalletBtn.setImage(UIImage(named: "ic_appleWallet"))
                print("Failed to create PKPass: \(error)")
            }
        }
        task.resume()
    }
    
    func presentPass(_ pass: [PKPass]) {
        if let passVC = PKAddPassesViewController(passes: pass) {
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController?.present(passVC, animated: true)
            }
        } else {
            print("Cannot create PKAddPassesViewController")
        }
    }

    private func _requestWalletPass(_ id: String) {
        WhosinServices.requestPkPass(bookingId: id) { [weak self] container, error in
            guard let self = self else { return}
            parentBaseController?.hideHUD(error: error)
            if error != nil {
                self._addToWalletBtn.hideActivity()
                self._addToWalletBtn.setImage(UIImage(named: "ic_appleWallet"))
            }
            guard let urlStrings = container?.data else { return }
            let urls = urlStrings.compactMap { URL(string: $0) }
            guard !urls.isEmpty else {
                parentBaseController?.alert(message: "No valid URLs found.")
                _addToWalletBtn.hideActivity()
                self._addToWalletBtn.setImage(UIImage(named: "ic_appleWallet"))
                return
            }
            self.downloadAndPresentMultiplePasses(from: urls)
        }
    }

    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleAddToWalletEvent(_ sender: CustomActivityButton) {
        if let id = bookingModel?.tourDetails.first?.bookingId, bookingModel?.bookingType == "whosin-ticket" {
            self._addToWalletBtn.showActivity()
            self._addToWalletBtn.setImage(nil)
            _requestWalletPass(id)
        } else if let id = bookingModel?.id {
            self._addToWalletBtn.showActivity()
            self._addToWalletBtn.setImage(nil)
            _requestWalletPass(id)
        }
    }
    

    @IBAction func _handleDownloadEvent(_ sender: CustomActivityButton) {
        if let urlString = self.bookingModel?.downloadTicket, !Utils.stringIsNullOrEmpty(urlString) {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                downloadBtn.hideActivity()
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                parentBaseController?.alert(title: kAppName, message: "URL is undefined")
            }
        }
    }
}
