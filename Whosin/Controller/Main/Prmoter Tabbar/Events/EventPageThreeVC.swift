import UIKit

class EventPageThreeVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifiereSocial = String(describing: SocialTableCell.self)
    public var socialAccounts: [SocialAccountsModel] = []
    var socialAccountsCallback: (([SocialAccountsModel]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiereSocial, kCellNibNameKey: kCellIdentifiereSocial, kCellClassKey: SocialTableCell.self, kCellHeightKey: SocialTableCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereSocial,
            kCellObjectDataKey: socialAccounts,
            kCellClassKey: SocialTableCell.self,
            kCellHeightKey: SocialTableCell.height
        ])
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
        
    }
}

extension EventPageThreeVC: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SocialTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [SocialAccountsModel] else { return }
            cell.setupData(object)
            cell.callback = { model in
                self.socialAccounts = model
                let socialAccountsToMention = model.map { socialAccount in
                    return [
                        "platform": socialAccount.platform,
                        "account": socialAccount.account
                    ]
                }
                PromoterCreateEventVC.eventParams["socialAccountsToMention"] = socialAccountsToMention
                self.socialAccountsCallback?(self.socialAccounts)
                self._loadData()
            }
        }
    }
}


