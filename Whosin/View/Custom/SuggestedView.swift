import Foundation
import UIKit
import ExpandableLabel
import GSKStretchyHeaderView


class SuggestedView: UIView {
    
    @IBOutlet private weak var _emptyTxt: UILabel!
    @IBOutlet private weak var _emptySuggestionView: UIView!
    @IBOutlet weak var _titleLeadingConstriaint: NSLayoutConstraint!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: SuggestedFriendCollectionCell.self)
    private let kVenueCellIdentifier = String(describing: SuggestedVenueCollectionCell.self)
    private var usersModel: [UserDetailModel]?
    private var venueModel: [VenueDetailModel]?
    private var isVenue: Bool = false
    public var removeVenueCallBack: ((_ id: String) -> Void)?
    public var removeUserCallBack: ((_ id: String) -> Void)?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    public class func initFromNib() -> SuggestedView {
        UINib(nibName: "SuggestedView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SuggestedView
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SuggestedFriendCollectionCell.self, kCellHeightKey: SuggestedFriendCollectionCell.height],
                [kCellIdentifierKey: kVenueCellIdentifier, kCellNibNameKey: kVenueCellIdentifier, kCellClassKey: SuggestedVenueCollectionCell.self, kCellHeightKey: SuggestedVenueCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 2, height: 2),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        self._collectionView.contentInset = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if !isVenue {
            usersModel?.forEach { model in
                if APPSESSION.userDetail?.id != model.id {
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: model.id,
                        kCellObjectDataKey: model,
                        kCellClassKey: SuggestedFriendCollectionCell.self,
                        kCellHeightKey: SuggestedFriendCollectionCell.height,
                        kCellClickEffectKey:true
                    ])
                }
            }
        } else {
            venueModel?.forEach { model in
                cellData.append([
                    kCellIdentifierKey: self.kVenueCellIdentifier,
                    kCellTagKey: model.id,
                    kCellObjectDataKey: model,
                    kCellClassKey: SuggestedVenueCollectionCell.self,
                    kCellHeightKey: SuggestedVenueCollectionCell.height,
                    kCellClickEffectKey:true
                ])
            }
        }
        let isEmptyUser = usersModel?.isEmpty == true
        let isEmptyVenue = venueModel?.isEmpty == true
        _collectionView.isHidden = isVenue ? isEmptyVenue : isEmptyUser
        _emptySuggestionView.isHidden = isVenue ? !isEmptyVenue : !isEmptyUser
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }


    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ users: [UserDetailModel] = [], venues: [VenueDetailModel] = [],title: String, isBlock: Bool = true, isVenue: Bool = false) {
        self.isVenue = isVenue
        self._emptyTxt.text = "There are no suggested \(isVenue ? "venue" : "friends".localized())!."
        self._collectionHeight.constant = isVenue ? 170 : 160
        venueModel = venues
        usersModel = users
        _titleLabel.text = title
        self._collectionView.contentInset = UIEdgeInsets(top: 0, left: isBlock ? 11 : 7, bottom: 0, right: isBlock ? 11 : 7)
        self._titleLeadingConstriaint.constant = isBlock ? 14 : 10
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleInviteFriends(_ sender: UIButton) {
            let items: [Any] = [kInviteMessage]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [
                .addToReadingList,
                .assignToContact,
                .openInIBooks,
                .print,
                .message,
                .airDrop,
                .postToWeibo,
                .postToVimeo,
                .postToFlickr,
                .postToTwitter,
                .postToFacebook
            ]
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = parentBaseController?.view
                popoverController.sourceRect = (parentBaseController?.view.bounds)!
            }
        self.parentBaseController?.present(activityViewController, animated: true, completion: nil)
        }


}



// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension SuggestedView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SuggestedFriendCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object)
            cell._mainView.addGradientBorderWithColor(cornerRadius: 8, 1.5, [ColorBrand.brandPink.cgColor, ColorBrand.brandgradientBlue.cgColor])
            cell.closeUserCallBack = { id in
                if let index = self.usersModel?.firstIndex(where: { $0.id == id}) {
                    self.usersModel?.remove(at: index)
                    self._loadData()
                }
                self.removeUserCallBack?(id)
            }
        } else if let cell = cell as? SuggestedVenueCollectionCell, let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel  {
            cell.setupData(object)
            cell._mainView.addGradientBorderWithColor(cornerRadius: 8, 1.5, [ColorBrand.brandPink.cgColor, ColorBrand.brandgradientBlue.cgColor])
            cell.closeVenueCallBack = { id in
                if let index = self.venueModel?.firstIndex(where: { $0.id == id }) {
                    self.venueModel?.remove(at: index)
                    self._loadData()
                }
                self.removeVenueCallBack?(id)
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        if cell is SuggestedFriendCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            guard let user = APPSESSION.userDetail, user.id != object.id else { return }
            if object.isPromoter, user.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = object.id
                vc.isFromPersonal = true
                parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            } else if object.isRingMember, user.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = object.id
                vc.isFromPersonal = true
                parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = object.id
                vc.userDetail = object
                vc.followStateCallBack = { id, isFollow in
                    if let index = self.usersModel?.firstIndex(where: { $0.id == id}) {
                        self.usersModel?[index].follow = isFollow
                        self._loadData()
                    }
                }
                parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            }
        } else if cell is SuggestedVenueCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = object.id
            vc.venueDetailModel = object
            vc.followStateCallBack = { id, isFollow in
                if let index = self.venueModel?.firstIndex(where: { $0.id == id}) {
                    self.venueModel?[index].isFollowing = isFollow
                    self._loadData()
                }
            }
            parentBaseController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if isVenue {
            return  CGSize(width: 150, height: SuggestedVenueCollectionCell.height)
        } else {
            return  CGSize(width: 150, height: SuggestedFriendCollectionCell.height)
        }
    }
    
}
