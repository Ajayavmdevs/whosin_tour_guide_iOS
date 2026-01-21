import UIKit

class PlusOneDetailViewCell: UITableViewCell {

    @IBOutlet private weak var _plusOneStatus: CustomLabel!
    @IBOutlet private weak var _titleLabel: CustomLabel!
    @IBOutlet private weak var _spotsView: UIView!
    @IBOutlet private weak var _genderView: UIView!
    @IBOutlet weak var _plusOneStatusview: UIView!
    @IBOutlet private weak var _ageView: UIView!
    @IBOutlet private weak var _dressCodeView: UIView!
    @IBOutlet private weak var _nationalityView: UIView!
    @IBOutlet private weak var _seatText: CustomLabel!
    @IBOutlet private weak var _genderText: CustomLabel!
    @IBOutlet private weak var _ageRangeText: CustomLabel!
    @IBOutlet private weak var _dressCodeText: CustomLabel!
    @IBOutlet private weak var _nationalityText: CustomLabel!
    @IBOutlet weak var _invitePlusOneButton: CustomButton!
    @IBOutlet weak var _plusOneListView: UIView!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private var _eventModel: PromoterEventsModel?
    private let kCellIdentifierShareWith = String(describing: SharedUsersCollectionCell.self)
    
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
        _setupCollectionView()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupCollectionView() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              emptyDataDescription: "",
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(users: [UserDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        users.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellDifferenceContentKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: SharedUsersCollectionCell.self,
                kCellHeightKey: SharedUsersCollectionCell.height
            ])
        })

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SharedUsersCollectionCell.self), kCellNibNameKey: String(describing: SharedUsersCollectionCell.self), kCellClassKey: SharedUsersCollectionCell.self, kCellHeightKey: SharedUsersCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: PromoterEventsModel, isPlusOne: Bool = false) {
        _eventModel = model
        _plusOneStatusview.isHidden = !model.plusOneMandatory
        if model.extraGuestType == "anyone" {
            _genderView.isHidden = model.extraGuestGender == "both"
            _genderText.text = model.extraGuestGender.capitalizedSentence
            _ageView.isHidden = true
            _dressCodeView.isHidden = true
            _nationalityView.isHidden = true
        } else {
            _genderView.isHidden = Utils.stringIsNullOrEmpty(model.extraGuestGender)
            _ageView.isHidden = Utils.stringIsNullOrEmpty(model.extraGuestAge)
            _dressCodeView.isHidden = Utils.stringIsNullOrEmpty(model.extraGuestDressCode)
            _nationalityView.isHidden = Utils.stringIsNullOrEmpty(model.extraGuestNationality)
            _genderText.text = model.extraGuestGender.capitalizedSentence
            _ageRangeText.text = model.extraGuestAge
            _dressCodeText.text = model.extraGuestDressCode.capitalizedSentence
            _nationalityText.text = model.extraGuestNationality.capitalizedSentence
        }
        _seatText.text = "\(model.plusOneQty) " + "seats".localized()
        _invitePlusOneButton.isHidden = !(model.invite?.promoterStatus == "accepted" && model.invite?.inviteStatus == "in" && model.plusOneAccepted == true && model.status == "upcoming")
        _plusOneListView.isHidden = model.plusOneMembers.isEmpty
        _loadData(users: model.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self))
        if isPlusOne {
            _invitePlusOneButton.isHidden = true
        }
    }
    
    @IBAction func _handleInvitePlusOneEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(PlusOneInivteBottomSheet.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.isEventPlusOne = true
        vc.event = _eventModel
        vc.groupMembers = _eventModel?.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self) ?? []
        vc.isMultiSelect = true
        parentViewController?.present(vc, animated: true)

    }
}

extension PlusOneDetailViewCell:  CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SharedUsersCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object, inviteStatus: true)
            cell._button.isEnabled = false
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 5
        return CGSize(width: 50, height: SharedUsersCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        if object.isRingMember && APPSESSION.userDetail?.isPromoter == true {
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = object.userId
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let controller = INIT_CONTROLLER_XIB(UsersProfileVC.self)
            controller.contactId = object.userId
            self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
