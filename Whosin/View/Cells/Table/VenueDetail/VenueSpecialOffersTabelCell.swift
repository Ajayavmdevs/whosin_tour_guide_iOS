import UIKit

class VenueSpecialOffersTabelCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieght: NSLayoutConstraint!
    
    private var _specialOffersModel: [SpecialOffersModel] = []
    private let kCellIdentifier = String(describing: VenueSpecialOffersCollectionCell.self)

    private var _venueDetailModel: VenueDetailModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _collectionView.isScrollEnabled = false
        layer.zPosition = 0
        _collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        setupUi()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: VenueSpecialOffersCollectionCell.self, kCellHeightKey: VenueSpecialOffersCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.layer.cornerRadius = 10
        _collectionView.clipsToBounds = true
        _collectionView.setup(cellPrototypes: _prototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 1,
                                   rows: 5,
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        NotificationCenter.default.addObserver(self, selector: #selector(openSuccessClaim(_:)), name: .openClaimSuccessCard, object: nil)
    }
    
    @objc func openSuccessClaim(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
           let data = userInfo["data"] as? ClaimHistoryModel,
           let isFromBrunch = userInfo["isFromBrunch"] as? Bool, let specialOffer = userInfo["specialOffer"] as? SpecialOffersModel, let venue = userInfo["venue"] as? VenueDetailModel {
            let vc = INIT_CONTROLLER_XIB(ClaimSuccessfullVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.isFromBrunch = isFromBrunch
            vc.model = data
            vc.venueModel = venue
            vc.specialOffer = specialOffer
            self.parentViewController?.present(vc, animated: true)
        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
            _specialOffersModel.forEach { specialOffersModel in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: specialOffersModel.id,
                    kCellObjectDataKey: specialOffersModel,
                    kCellClassKey: VenueSpecialOffersCollectionCell.self,
                    kCellHeightKey: VenueSpecialOffersCollectionCell.height
                ])
            }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionViewHieght.constant = 90 * CGFloat(cellData.count)
        _collectionView.loadData(cellSectionData)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: VenueDetailModel) {
        _specialOffersModel = model.specialOffers.toArrayDetached(ofType: SpecialOffersModel.self)
        _venueDetailModel = model
        _loadData()
    }
    
    private func _timingLogic() -> Bool {
        let timeLabel = _venueDetailModel?.timing.toArrayDetached(ofType: TimingModel.self)
        let weekdayComponent = Calendar.current.component(.weekday, from: Date())
        if let shortDayName = Calendar.current.shortWeekdaySymbols[weekdayComponent - 1] as String? {
            let currentTime = timeLabel?.filter { $0.day.capitalized == shortDayName }
            let currentdate = Utils.dateToString(Date(), format: kFormatDate)
            let dateString = "\(currentdate) \((currentTime?.first?.closingTime ?? kEmptyString))"
            return Utils.isDateExpiredWith2Hour(dateString: dateString, format: "yyyy-MM-dd HH:mm")
        }
        return true
    }

}

extension VenueSpecialOffersTabelCell: CustomCollectionViewDelegate, UICollectionViewDelegate {

    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueSpecialOffersCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? SpecialOffersModel else { return }
            cell.setUpdata(object)
        } 
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.95, height: VenueSpecialOffersCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? SpecialOffersModel else { return }
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let venue = _venueDetailModel else {
            parentBaseController?.alert(message: "you_can_claim_only_when_venue_is_open".localized())
            return
        }
//        if !venue.isOpen {
//            if _timingLogic() {
//                parentBaseController?.alert(message: "Venue is close. You can claim only when venue is open.")
//                return
//            }
//        }

        if object.type == "brunch" {
            let controller = INIT_CONTROLLER_XIB(ClaimBrunchVC.self)
            controller.venueModel = venue
            controller.specialOffer = object
            let navController = NavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(navController, animated: true)

        } else {
            let controller = INIT_CONTROLLER_XIB(ClaimTotalBillVC.self)
            controller.venueModel = venue
            controller.specialOffer = object
            controller.modalPresentationStyle = .overFullScreen
            self.parentViewController?.present(controller, animated: true)
        }


    }
    
}

extension VenueSpecialOffersTabelCell: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}


extension VenueSpecialOffersTabelCell: ShowMembershipInfoDelegate {
    func ShowMembershipDetail() {
        let vc = INIT_CONTROLLER_XIB(MembershipDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.present(vc, animated: true)
    }
}
