import UIKit
import MediaBrowser

class ProfileMediaTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _mediaCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _seeAllBtn: UIButton!
    private let kCellIdentifier = String(describing: ImageViewCell.self)
    
    private var _messageList:[MessageModel]?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        disableSelectEffect()
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0),
                              spacing: CGSize(width: 15, height: 15),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ImageViewCell.self, kCellHeightKey: ImageViewCell.height]
        ]
    }
    
    private func _loadData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        

        _messageList?.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: model.id,
                kCellObjectDataKey: model.msg,
                kCellClassKey: ImageViewCell.self,
                kCellHeightKey: ImageViewCell.height
            ])
        })
        
        if _messageList?.isEmpty == true {
            _mediaCollectionHeightConstraint.constant = 0
            _seeAllBtn.isHidden = true
        } else {
            _mediaCollectionHeightConstraint.constant = 102
            _seeAllBtn.isHidden = false
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleSeeAllClick(_ sender:UIButton) {
        let browser = MediaBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        browser.modalPresentationStyle = .pageSheet
        parentViewController?.present(browser, animated: true)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ chatId: String) {
        let chatRepo = ChatRepository()
        let messages = chatRepo.getMediaMessages(chatId: chatId)
        _messageList = messages
        _loadData()
    }
}


extension ProfileMediaTableCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ImageViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.setupData(imageUrl: object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

extension ProfileMediaTableCell: MediaBrowserDelegate {
    
    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        let msg = _messageList?[index].msg ?? kEmptyString
        let media = Utils.webMediaPhoto(url: msg, caption: nil)!
        return media
    }
    
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int {
        _messageList?.count ?? 0
    }
    
    func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        let msg = _messageList?[index].msg ?? kEmptyString
        let media = Utils.webMediaPhoto(url: msg, caption: nil)!
        return media
    }
    
    func gridCellSize() -> CGSize {
        return CGSize(width: (self.frame.width - kCollectionDefaultMargin)/4 , height: (self.frame.width - kCollectionDefaultMargin)/4)
    }
}
