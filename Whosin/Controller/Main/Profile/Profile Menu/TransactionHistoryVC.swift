import UIKit

class TransactionHistoryVC: ChildViewController {
    
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: TransactionHistoryCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _loadData(true)
        setupUI()
    }

    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "no_reviews".localized(),
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: nil,
            delegate: self)
        DISPATCH_ASYNC_MAIN_AFTER(5) {
            self._loadData()
        }
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            let dummyModels = _getDummyData()
            for model in dummyModels {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: TransactionHistoryCell.self,
                    kCellHeightKey: TransactionHistoryCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func _getDummyData() -> [TransactionHistoryModel] {
        var data = [TransactionHistoryModel]()
        
        data.append(TransactionHistoryModel(
            title: "Payment Received",
            subtitle: "From John Doe",
            date: "20 Oct, 2023",
            amount: "+$50.00",
            status: "Completed",
            bottomText: "Completed",
            bottomRightText: "Total: $50.00",
            bottomIcon: "icon_selectedGreen",
            imageName: "https://whosin-production.s3.me-central-1.amazonaws.com/file/1744787008306the_vie_the_pam_day.jpg",
            isCredit: true
        ))
        
        data.append(TransactionHistoryModel(
            title: "Ticket Purchase",
            subtitle: "Concert X",
            date: "18 Oct, 2023",
            amount: "-$120.00",
            status: "Pending",
            bottomText: "Processing",
            bottomRightText: "Total: $120.00",
            bottomIcon: "icon_invitePending",
            imageName: "https://whosin-production.s3.me-central-1.amazonaws.com/file/1744787008306the_vie_the_pam_day.jpg",
            isCredit: false
        ))
        
        data.append(TransactionHistoryModel(
            title: "Refund",
            subtitle: "Cancelled Event",
            date: "15 Oct, 2023",
            amount: "+$30.00",
            status: "Refund",
            bottomText: "Refunded",
            bottomRightText: "Total: $30.00",
            bottomIcon: "icon_selectedGreen", imageName: "https://whosin-production.s3.me-central-1.amazonaws.com/file/1744787008306the_vie_the_pam_day.jpg",
            isCredit: true
        ))
        
        data.append(TransactionHistoryModel(
            title: "Booking Cancelled",
            subtitle: "Museum Tour",
            date: "10 Oct, 2023",
            amount: "$0.00",
            status: "Cancelled",
            bottomText: "Cancelled",
            bottomRightText: "Total: $0.00",
            bottomIcon: "icon_inviteOut", imageName: "https://whosin-production.s3.me-central-1.amazonaws.com/file/1744787008306the_vie_the_pam_day.jpg",
            isCredit: false
        ))
        
        return data
    }
    
    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: TransactionHistoryCell.self, kCellHeightKey: TransactionHistoryCell.height],
                [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]

        ]
    }

    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: CustomNoKeyboardTableViewDelegate
// --------------------------------------

extension TransactionHistoryVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? TransactionHistoryCell, let data = cellDict?[kCellObjectDataKey] as? TransactionHistoryModel {
            cell.setUpdata(model: data)
        }
    }
    
}
