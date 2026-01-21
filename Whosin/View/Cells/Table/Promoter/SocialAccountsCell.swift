import UIKit

class SocialAccountsCell: UITableViewCell {

    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: SocialCollectionViewCell.self)
    var eventNm = ""
    var height: CGFloat = 0
    
    class var height : CGFloat { UITableView.automaticDimension }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }

    private func _setupCollectionView() {
        _customCollectionView.setup(cellPrototypes: _prototype,
                                    hasHeaderSection: false,
                                    enableRefresh: false,
                                    columns: 1,
                                    rows: 1,
                                    scrollDirection: .vertical,
                                    emptyDataText: "There is no data available",
                                    emptyDataIconImage: UIImage(named: "empty_following"),
                                    delegate: self)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ model: [SocialAccountsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !model.isEmpty {
            model.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: SocialCollectionViewCell.self,
                    kCellHeightKey: height
                ])
            }
        }
        
        _collectionHight.constant = CGFloat(cellData.count * 80)
        _customCollectionView.layoutIfNeeded()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SocialCollectionViewCell.self, kCellHeightKey: height]]
    }

    
    public func setUpSocialTag(_ model: [SocialAccountsModel]) {
        _loadData(model)
    }
    
    
}

extension SocialAccountsCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SocialCollectionViewCell, let object = cellDict?[kCellObjectDataKey] as? SocialAccountsModel else  { return }
        cell.setup(object.account, placeHolder: kEmptyString, icon: "\(object.platform)", platform: SocialPlatforms.checkType(object.platform) ?? .instagram, titleText: object.title)
        cell.deleteBtn.isHidden = true
        cell._deleteView.isHidden = true
        cell._copyView.isHidden = false
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? SocialAccountsModel else {
            return CGSize(width: collectionView.frame.width - 28, height: 80.0)
        }
        
        let height: CGFloat = Utils.stringIsNullOrEmpty(object.title) ? 50.0 : 80.0
        return CGSize(width: collectionView.frame.width - 28, height: height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? SocialAccountsModel else  { return }
        openUrlLink(object)
    }
    
    private func openUrlLink(_ type: SocialAccountsModel) {
        let appURLString: String
        let webURLString: String
        var account = type.account
        if type.platform == SocialPlatforms.instagram.rawValue, account.hasPrefix("@") {
            account.remove(at: account.startIndex)
        } else if type.platform == SocialPlatforms.whatsapp.rawValue {
            let phoneRegex = "^\\+[0-9]+"
            let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !phonePredicate.evaluate(with: account) {
                account = "+961" + account
            }
        }

        if !account.hasPrefix("https://explore.whosin.me/") && (account.hasPrefix("http://") || account.hasPrefix("https://")) {
            // Use the URL directly for both app and web
            appURLString = account
            webURLString = account
        } else {
            switch type.platform {
            case SocialPlatforms.instagram.rawValue:
                appURLString = "instagram://user?username=\(account)"
                webURLString = "https://www.instagram.com/\(account)"
            case SocialPlatforms.tiktok.rawValue:
                appURLString = "snssdk1128://user/profile/\(account)"
                webURLString = "https://www.tiktok.com/@\(account)"
            case SocialPlatforms.facebook.rawValue:
                appURLString = "fb://profile/\(type.account)"
                webURLString = "https://www.facebook.com/\(account)"
            case SocialPlatforms.google.rawValue:
                appURLString = "google://search?q=\(account)"
                webURLString = "https://www.google.com/search?q=\(account)"
            case SocialPlatforms.youtube.rawValue:
                appURLString = "youtube://channel/\(type.account)"
                webURLString = "https://www.youtube.com/channel/\(account)"
            case SocialPlatforms.snapchat.rawValue:
                appURLString = "snapchat://add/\(account)"
                webURLString = "https://www.snapchat.com/add/\(account)"
            case SocialPlatforms.website.rawValue:
                appURLString = "https://\(account)"
                webURLString = "https://\(account)"
            case SocialPlatforms.whatsapp.rawValue:
                appURLString = "whatsapp://send?phone=\(account.replacingOccurrences(of: " ", with: ""))"
                webURLString = "https://api.whatsapp.com/send?phone=\(account.replacingOccurrences(of: " ", with: ""))"
            case SocialPlatforms.email.rawValue:
                appURLString = "mailto:\(account)"
                webURLString = "mailto:\(account)"
            case SocialPlatforms.whosin.rawValue:
                appURLString = "whosInApp://\(account)"
                webURLString = "https://www.whosin.me/\(account)"
            default:
                return
            }
        }

        guard let appURL = URL(string: appURLString), let webURL = URL(string: webURLString) else { return }
        openActionSheet(appURL: appURL, webURL: webURL)
    }

    
    private func openApp(appURL: URL, webURL: URL) {
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    private func openActionSheet(appURL: URL, webURL: URL) {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "open".localized(), style: .default, handler: { action in
            self.openApp(appURL: appURL, webURL: webURL)
        }))
            
        alert.addAction(UIAlertAction(title: "copy".localized(), style: .default, handler: { action in
            UIPasteboard.general.string = webURL.absoluteString
            self.parentViewController?.showToast("copied".localized())
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
}
