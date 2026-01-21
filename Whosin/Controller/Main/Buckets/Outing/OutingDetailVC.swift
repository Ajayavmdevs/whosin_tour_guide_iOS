import UIKit

class OutingDetailVC: ChildViewController {
    
    @IBOutlet private weak var _editBtn: UIButton!
    @IBOutlet weak var _editOwnerStack: UIStackView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _logoImage: UIImageView!
    @IBOutlet private weak var _logoBgView: UIView!
    @IBOutlet private weak var _headerTitleLbl: UILabel!
    @IBOutlet private weak var _headerSubTitleLbl: UILabel!
    @IBOutlet weak var _openVenueStack: UIStackView!
    private var _logoHeroId: String = kEmptyString
    public var outingModel: OutingListModel?
    public var outingId: String = kEmptyString
    private let kCellIdentifireheader = String(describing: OutingHeaderDetailCell.self)
    private let kCellIdentifirFetures = String(describing: OutingFeaturesCell.self)
    private let kCellIdentifierTimeAndDisc = String(describing: OutingTimeAndDiscCell.self)
    private let kCellIdentifireWhosin = String(describing: OutingWhosinCell.self)
    private let kCellIdentifierOffers = String(describing: OutingOfferTableCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _loadData(isLoading: true)
        _requestGetOutingDetail(outingId)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: kReloadBucketList, object: nil)
    }

    // --------------------------------------
    // MARK: Setup
    // --------------------------------------

    override func setupUi() {
        hideNavigationBar()
        self._logoBgView.layer.cornerRadius = self._logoBgView.frame.size.height / 2
        
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no outings detail available",
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: "thair is no detail found for this outing.",
            delegate: self)
        _tableView.proxyDelegate = self
        _visualEffectView.alpha = 0
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 70, right: 0)
        _editOwnerStack.isHidden = true
        
        let openVenue = UITapGestureRecognizer(target: self, action:  #selector(self._openVenueDetails))
        self._openVenueStack.addGestureRecognizer(openVenue)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestGetOutingDetail(_ id: String) {
        WhosinServices.getOutingDetail(outingId: id) { [weak self] container, error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error)
            }
            guard let data = container?.data else  { return }
            self.outingModel = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: "",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if let _model = outingModel {
                if _model.isOwner {
                    let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._imageBgTap))
                    self._logoBgView.addGestureRecognizer(gesture)
                    _showStoryRing()
                    
                    _headerTitleLbl.text = _model.venue?.name
                    _headerSubTitleLbl.text = _model.venue?.address
                    _headerSubTitleLbl.isHidden = false
                    _logoImage.loadWebImage(_model.venue?.logo ?? "",placeholder: UIImage(named: "img_default_thumb"))
                } else if let owner = _model.owner {
                    
                    let inviteText = " invited you to"
                    let attributedText = NSMutableAttributedString(string: owner.fullName)
                    let boldFont = FontBrand.SFlightFont(size: 13.0, isItalic: true)
                    attributedText.append(NSAttributedString(string: inviteText, attributes: [NSAttributedString.Key.font: boldFont]))
                    
                    _headerTitleLbl.attributedText = attributedText
                    _headerSubTitleLbl.isHidden = true
                    _editOwnerStack.isHidden = true
                    _logoImage.loadWebImage(owner.image, name: owner.fullName)
                }
                if _model.status == "upcoming" {
                    if _model.owner?.id == APPSESSION.userDetail?.id {
                        _editOwnerStack.isHidden = false
                    } else {
                        _editOwnerStack.isHidden = true
                    }
                } else {
                    _editOwnerStack.isHidden = true
                }
            }
            
            
            guard let outingModel = outingModel else { return }
            if outingModel.offer == nil  {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifireheader,
                    kCellTagKey: outingModel.id,
                    kCellObjectDataKey: outingModel,
                    kCellClassKey: OutingHeaderDetailCell.self,
                    kCellHeightKey: OutingHeaderDetailCell.height
                ])
                
                if let venue = outingModel.venue {
                    if !venue.feature.isEmpty || !venue.cuisine.isEmpty || !venue.theme.isEmpty || !venue.music.isEmpty {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifirFetures,
                            kCellTagKey: outingModel.id,
                            kCellObjectDataKey: outingModel,
                            kCellClassKey: OutingFeaturesCell.self,
                            kCellHeightKey: OutingFeaturesCell.height
                        ])
                    }
                }
                
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierTimeAndDisc,
                    kCellTagKey: outingModel.id,
                    kCellObjectDataKey: outingModel,
                    kCellClassKey: OutingTimeAndDiscCell.self,
                    kCellHeightKey: OutingTimeAndDiscCell.height
                ])
            }
            
            if outingModel.offer != nil {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierOffers,
                    kCellTagKey: kCellIdentifierOffers,
                    kCellObjectDataKey: outingModel,
                    kCellClassKey: OutingOfferTableCell.self,
                    kCellHeightKey: OutingOfferTableCell.height
                ])
                
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierTimeAndDisc,
                    kCellTagKey: outingModel.id,
                    kCellObjectDataKey: outingModel,
                    kCellClassKey: OutingTimeAndDiscCell.self,
                    kCellHeightKey: OutingTimeAndDiscCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifireWhosin,
                kCellTagKey: outingModel.id,
                kCellObjectDataKey: outingModel,
                kCellClassKey: OutingWhosinCell.self,
                kCellHeightKey: OutingWhosinCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    private func _showStoryRing() {
        _logoBgView.setupStoryRing(id: outingModel?.venueId ?? "")
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifireheader, kCellNibNameKey: kCellIdentifireheader, kCellClassKey: OutingHeaderDetailCell.self, kCellHeightKey: OutingHeaderDetailCell.height],
            [kCellIdentifierKey: kCellIdentifirFetures, kCellNibNameKey: kCellIdentifirFetures, kCellClassKey: OutingFeaturesCell.self, kCellHeightKey: OutingFeaturesCell.height],
            [kCellIdentifierKey: kCellIdentifierTimeAndDisc, kCellNibNameKey: kCellIdentifierTimeAndDisc, kCellClassKey: OutingTimeAndDiscCell.self, kCellHeightKey: OutingTimeAndDiscCell.height],
            [kCellIdentifierKey: kCellIdentifireWhosin, kCellNibNameKey: kCellIdentifireWhosin, kCellClassKey: OutingWhosinCell.self, kCellHeightKey: OutingWhosinCell.height],
            [kCellIdentifierKey: kCellIdentifierOffers, kCellNibNameKey: kCellIdentifierOffers, kCellClassKey: OutingOfferTableCell.self, kCellHeightKey: OutingOfferTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]

    }
    
    private func transferOwnership() {
        let vc = INIT_CONTROLLER_XIB(TransferOwnershipBottomSheet.self)
        vc.isFromOuting = true
        vc.sharedWith = outingModel?.invitedUser.toArrayDetached(ofType: UserDetailModel.self) ?? []
        vc.outingId = outingModel?.id ?? kEmptyString
        self.presentAsPanModal(controller: vc)
    }
    
    private func _changeOwnerActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Change Ownership", style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self.transferOwnership() }
        }))
        
        alert.addAction(UIAlertAction(title: "Delete Invitation", style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self._requestDelete() }
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        self.present(alert, animated: true)
    }
    
    private func _requestDelete() {
        confirmAlert(message: "Are you sure want to delete \(outingModel?.title ?? kEmptyString) invitation?", okHandler: { [weak self] action in
            guard let id = self?.outingModel?.id else { return }
            WhosinServices.requestDeleteOuting(outingId: id) { [weak self] container, error in
                guard let self = self else { return }
                if let error = error {
                    self.showError(error)
                }
                guard let data = container?.data else  { return }
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
                NotificationCenter.default.post(name: .reloadShoutouts, object: nil)
                DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                    if self.isVCPresented {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func handleReload() {
        _requestGetOutingDetail(outingId)
    }
    
    @objc func _openVenueDetails(sender : UITapGestureRecognizer) {
        if outingModel?.isOwner == true {
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = outingModel?.venueId ?? ""
            vc.venueDetailModel = outingModel?.venue
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
            vc.contactId = outingModel?.owner?.id ?? kEmptyString
            vc.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func _imageBgTap(sender : UITapGestureRecognizer) {
        guard let venueId = outingModel?.venueId else { return }
        guard let venues = HomeRepository.getStoryArrayByVenueId(venueId) else { return }

        _logoBgView.hero.id = "\(venueId)_story_top"
        _logoBgView.hero.modifiers = HeroAnimationModifier.stories
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = venues
        controller.currentIndex = 0
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = "\(venueId)_story_top"
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        self.present(controller, animated: true)
    }
    
    @IBAction private func _handleEditEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler.outingModel = outingModel
        controler._selectedOffer = outingModel?.offer
        controler.delegate = self
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        present(navController, animated: true)
    }
    
    @IBAction func _handleChangeOwnerShipEvent(_ sender: UIButton) {
        _changeOwnerActionSheet()
    }
    
    @IBAction private func backButtonAction() {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}

extension OutingDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
        if let cell = cell as? OutingHeaderDetailCell {
            cell.setupData(object)
        } else if let cell = cell as? OutingFeaturesCell {
            cell.setupData(object)
        } else if let cell = cell as? OutingTimeAndDiscCell {
            cell.setupData(object)
        } else if let cell = cell as? OutingWhosinCell {
            cell.setupData(object)
            cell.callback = {
                if self.isVCPresented {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else if let cell = cell as? OutingOfferTableCell {
            guard let offerModel = object.offer else { return }
            cell._customVenueInfo.isHidden = object.isOwner
            cell.setupData(offerModel, outingModel: object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
        if cell is OutingOfferTableCell {
            let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            controller.offerId = object.offer?.id ?? kEmptyString
            controller.venueModel = object.offer?.venue
            controller.timingModel = object.offer?.venue?.timing.toArrayDetached(ofType: TimingModel.self)
            controller.modalPresentationStyle = .overFullScreen
            controller.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            controller.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: controller)
        }
    }
    
}

extension OutingDetailVC: UpdateUsersDelegate {
    func updateUsers(_ data: OutingListModel) {
        outingModel = data
        _loadData()
    }
}
