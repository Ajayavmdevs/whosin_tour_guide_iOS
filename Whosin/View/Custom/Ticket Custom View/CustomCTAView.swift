import UIKit
import PanModal
import SnapKit

class CustomCTAView: UIView {
    
    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: CTACollectionCell.self)
    private var ctaModel: [CTAModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 8
    }

    
    
    private func _setupCollectionView() {
        _customCollectionView.setup(cellPrototypes: _prototype,
                                    hasHeaderSection: false,
                                    enableRefresh: false,
                                    columns: 2,
                                    rows: 1,
                                    spacing: CGSize(width: 0, height: 0),
                                    scrollDirection: .vertical,
                                    emptyDataText: kEmptyString,
                                    emptyDataIconImage: nil,
                                    delegate: self)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
        _customCollectionView.isScrollEnabled = false
    }
    
    private func _loadData() {

        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        ctaModel.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: CTACollectionCell.self,
                kCellHeightKey: 38
            ])
        }

        let rowHeight: CGFloat = 38
        let spacing: CGFloat = 10
        let rows: Int

        if ctaModel.count <= 2 {
            rows = 1
        } else {
            rows = 2
        }

        _collectionHight.constant =
            CGFloat(rows) * rowHeight +
            CGFloat(rows - 1) * spacing

        _customCollectionView.layoutIfNeeded()

        cellSectionData.append([
            kSectionTitleKey: kEmptyString,
            kSectionDataKey: cellData
        ])

        _customCollectionView.loadData(cellSectionData)
    }

    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: CTACollectionCell.self, kCellHeightKey: 38]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomCTAView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    
    public func setupData(_ model: [CTAModel]) {
        ctaModel = model
        _customCollectionView.isScrollEnabled = false
        _loadData()
    }
    
}

extension CustomCTAView: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? CTACollectionCell, let object = cellDict?[kCellObjectDataKey] as? CTAModel else  { return }
        cell.contentView.cornerRadius = 8
        cell.setup(object.text, color: object.backgroundColor)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? CTAModel else { return }
        if !object.link.isEmpty {
            openExternalLink(object.link)
            return
        }
        if object.actionType == "whosin_chat" {
            guard let parentVC = parentViewController else { return }
            let vc = INIT_CONTROLLER_XIB(ContactOptionSheet.self)
            vc.openWhosinAdmin = {
                self.openWhosinAdminChat()
            }
            vc.openWhatsappContact = {
                self.openWhatsAppChat()
            }
            if vc is PanModalPresentable {
                parentVC.presentPanModal(vc)
            } else {
                parentVC.presentAsPanModal(controller: vc)
            }
        }

    }
    
    private func openExternalLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func openWhosinAdminChat() {
        guard let parentVC = parentViewController else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = "https://whosin-bucket.nyc3.digitaloceanspaces.com/file/1721896083557_image-1721896083557.jpg"
        chatModel.title = "Whosin Admin"
        chatModel.members.append(kLiveAdminId)
        chatModel.members.append(userDetail.id)
        let chatIds = [kLiveAdminId, userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        chatModel.chatType = "friend"
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc.hidesBottomBarWhenPushed = true
//            Utils.openViewController(vc)
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }


    private func openWhatsAppChat() {
        let phoneNumber = "971554373163"
        let message = "Hello, I need a customized itinerary!"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let appURL = URL(string: "whatsapp://send?phone=\(phoneNumber)&text=\(encodedMessage)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:])
            return
        }

        if let webURL = URL(string: "https://wa.me/\(phoneNumber)?text=\(encodedMessage)") {
            UIApplication.shared.open(webURL, options: [:])
        }
    }


    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let totalCount = ctaModel.count
        let spacing: CGFloat = 10
        let fullWidth = collectionView.frame.width
        let halfWidth = (fullWidth - spacing) / 2
        let height: CGFloat = 38

        if totalCount == 1 {
            return CGSize(width: fullWidth, height: height)
        }

        if totalCount == 2 {
            return CGSize(width: halfWidth, height: height)
        }

        if indexPath.item < 2 {
            return CGSize(width: halfWidth, height: height)
        } else {
            return CGSize(width: fullWidth, height: height)
        }
    }
    
}


