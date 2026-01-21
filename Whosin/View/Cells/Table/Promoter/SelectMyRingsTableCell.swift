import UIKit

class SelectMyRingsTableCell: UITableViewCell {

    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet private weak var _selectAllBtn: CustomButton!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifierShareWith = String(describing: UserCollectionCell.self)
    private var myRingsList: [UserDetailModel] = []
    public var selectedIdsCallback: ((_ ids: [String]) -> Void)?
    public var selectAllCallback:((_ isSelectAll: Bool)-> Void)?
    private var _selectedIDs: [String] = []
    private var isSelectAllMember: Bool = false

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
    }

    // --------------------------------------
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: [UserDetailModel], selectedId: [String], isSelectAll: Bool = false) {
        _selectedIDs = selectedId
        myRingsList = model
        isSelectAllMember = isSelectAll
        if (selectedId.count == model.count && selectedId.count > 0) || isSelectAll {
            _selectAllBtn.setTitle("deselect_all".localized())
        } else {
            _selectAllBtn.setTitle("select_all".localized())
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleSelectAllEvent(_ sender: CustomButton) {
        isSelectAllMember.toggle()
        selectAllCallback?(isSelectAllMember)
    }
}

