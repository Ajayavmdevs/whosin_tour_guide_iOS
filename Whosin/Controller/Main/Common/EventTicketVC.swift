import UIKit
import Lottie

class EventTicketVC: ChildViewController {

    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _eventImage: UIImageView!
    @IBOutlet weak var _venueDesc: CustomLabel!
    @IBOutlet weak var _eventDays: UILabel!
    @IBOutlet weak var _eventTime: UILabel!
    @IBOutlet weak var _eventDate: UILabel!
    @IBOutlet weak var _eventReservationDate: UILabel!
    @IBOutlet weak var _eventName: CustomLabel!
    @IBOutlet weak var _eventDesc: CustomLabel!
    @IBOutlet weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _colletionView: CustomCollectionView!
    @IBOutlet weak var _successView: LottieAnimationView!
    private let kCellIdentifier = String(describing: PurchasedPackageCell.self)
    public var voucherListModel: VouchersListModel?
    private var _packages: [PackageModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        setupData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        _colletionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 5,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _colletionView.showsVerticalScrollIndicator = false
        _colletionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: PurchasedPackageCell.self), kCellClassKey: PurchasedPackageCell.self, kCellHeightKey: PurchasedPackageCell.height] ]
    }
    
    private func setupData() {
        guard let model = voucherListModel else { return }
        guard let event = model.event else { return }
        _venueImage.loadWebImage(event.venueDetail?.slogo ?? kEmptyString)
        _venueName.text = event.venueDetail?.name
        _venueDesc.text = event.venueDetail?.descriptions
        _eventImage.loadWebImage(event.image)
        _eventName.text = event.title
        _eventDesc.text = event.descriptions
        _eventDays.text = event._eventDay
        _eventTime.text = event.eventTimeSlot
        _eventReservationDate.text = "Reservation Date: " + (event._reservationTime)
        _eventDate.text = "Event Date: " + (event._eventDate)
        _packages.removeAll()
        _packages = filterPackages(model)
        let item = model.items.toArrayDetached(ofType: VoucherItems.self)
        loadPackages(item)
        _successView.loopMode = .loop
        _successView.play()
    }
    
    private func filterPackages(_ voucherListModel: VouchersListModel) -> [PackageModel] {
        var model: [PackageModel] = []
        model.removeAll()
        if voucherListModel.type == "event" {
            if let eventPackages = voucherListModel.event?.packages {
                let packageIDs = Set(eventPackages.map { $0.id } )
                let itemIDs = Set(voucherListModel.items.map { $0.packageId } )
                let commonIDs = packageIDs.intersection(itemIDs)
                let filteredPackages = eventPackages.filter { package in
                    return commonIDs.contains(package.id)
                }
                model.append(contentsOf: filteredPackages)
                return model.sorted { $0._createdAt < $1._createdAt }
            } else { return model }
        } else {
            return model
        }
    }
    
    private func loadPackages(_ voucherItem: [VoucherItems]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        voucherItem.forEach { item in
            if _packages.contains(where: { $0.id == item.packageId }) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: item.id,
                    kCellObjectDataKey: item.detached(),
                    kCellClassKey: PurchasedPackageCell.self,
                    kCellHeightKey: PurchasedPackageCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _colletionView.loadData(cellSectionData)
        _collectionViewHieghtConstraint.constant = PurchasedPackageCell.height * CGFloat(cellData.count)
        _colletionView.isHidden = voucherItem.isEmpty
        _colletionView.reload()
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

// --------------------------------------
// MARK: Collection View
// --------------------------------------

extension EventTicketVC: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PurchasedPackageCell ,let object = cellDict?[kCellObjectDataKey] as? VoucherItems, let _voucherListModel = voucherListModel else { return }
        guard let packages = filterPackages(_voucherListModel).first(where: { $0.id == object.packageId }) else { return }
        cell.setupData(packages, item: object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: PurchasedPackageCell.height)
    }
}
