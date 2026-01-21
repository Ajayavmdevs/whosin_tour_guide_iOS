import UIKit
import ExpandableLabel

enum DragDirection {
    case Up
    case Down
}


var topViewInitialHeight : CGFloat = 300
let topViewFinalHeight: CGFloat = 0
var topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

class CommanProfileVC: NavigationBarViewController {
    var refreshControl = UIActivityIndicatorView()
    var isRefreshing = false

    @IBOutlet weak var _headerImageContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var _headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _editBtnView: UIView!
    @IBOutlet weak var stickyHeaderView: UIView!
    @IBOutlet weak var _bioLabel: ExpandableLabel!
    @IBOutlet weak var _followingCount: UILabel!
    @IBOutlet weak var _followersCount: UILabel!
    @IBOutlet weak var _userImageView: UIImageView!
    @IBOutlet weak var _userNameLabel: CustomLabel!
    @IBOutlet weak var _customGallaryView: CustomGallaryView!
    @IBOutlet private weak var _profileHeaderView: UIView!
    @IBOutlet private weak var _containerView: UIView!
//    @IBOutlet private weak var _scrollView: UIScrollView!
    @IBOutlet weak var _complementaryBtn: CustomButton!
    @IBOutlet weak var _actionBtn: CustomButton!
    @IBOutlet weak var _feedBtn: CustomButton!
    @IBOutlet weak var _friendBtn: CustomButton!
    @IBOutlet weak var _btnsStackView: UIStackView!
    @IBOutlet var actionBtns: [UIButton]!
    @IBOutlet private var _mutualimageViews: [UIImageView]!
    @IBOutlet private weak var _mutualStack: UIStackView!
    @IBOutlet private weak var _mutualText: UILabel!
    @IBOutlet weak var _btnsHeaderView: UIView!
    private var _currentVC: ProfileBaseMainVC?
    private var _user: UserDetailModel?
    
    var dragInitialY: CGFloat = 0
    var dragPreviousY: CGFloat = 0
    var dragDirection: DragDirection = .Up
    var isAnimatingHeader: Bool = false



    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupBtns()
        checkSession()
        setupRefreshControl()
        _editBtnView.isHidden = Preferences.isGuest
        if APPSESSION.userDetail?.isRingMember == true {
            if let firstButton = actionBtns.first {
                handleChangeTab(firstButton)
            }
        } else {
            handleChangeTab(actionBtns[2])
        }
        if APPSESSION.userDetail?.isRingMember == true {
            _requestGetCMProfile()
            _requestEventList()
        } else {
            getProfileData()
        }
        topViewInitialHeight = _profileHeaderView.frame.height
        topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changereloadNotificationUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleFollowStatusEvent), name: kReloadFollowStatus, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changeUserUpdateState, object: nil)
    }
    
    func setupRefreshControl() {
        refreshControl.hidesWhenStopped = true
        refreshControl.color = .white
        refreshControl.style = .medium
        view.addSubview(refreshControl)
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            refreshControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
        ])
    }
    
    func startRefreshing() {
        isRefreshing = true
        refreshControl.startAnimating()
        handlePushReload()
        self._currentVC?._refresh({ [weak self] isSuccess in
            DispatchQueue.main.async {
                self?.stopRefreshing()
            }
        })
    }

    func stopRefreshing() {
        DispatchQueue.main.async {
            self.isRefreshing = false
            self.refreshControl.stopAnimating()
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self._headerTopConstraint.constant = 15.0
                self.view.layoutIfNeeded()
            })
        }
    }

    
    private func _setupBtns() {
        _btnsStackView.removeArrangedSubview(_complementaryBtn)
        _btnsStackView.removeArrangedSubview(_actionBtn)
        _btnsStackView.removeArrangedSubview(_feedBtn)
        _btnsStackView.removeArrangedSubview(_friendBtn)

        _complementaryBtn.isHidden = true
        _actionBtn.isHidden = true
        _feedBtn.isHidden = true
        _friendBtn.isHidden = true
        if APPSESSION.userDetail?.isRingMember == true {
            _complementaryBtn.isHidden = false
            _actionBtn.isHidden = false
            _feedBtn.isHidden = false
            _friendBtn.isHidden = false
            
            _btnsStackView.addArrangedSubview(_complementaryBtn)
            _btnsStackView.addArrangedSubview(_actionBtn)
            _btnsStackView.addArrangedSubview(_friendBtn)
            _btnsStackView.addArrangedSubview(_feedBtn)
        } else {
            _feedBtn.isHidden = false
            _actionBtn.isHidden = false
            _btnsStackView.addArrangedSubview(_feedBtn)
            _btnsStackView.addArrangedSubview(_actionBtn)
        }
//        _friendBtn.isHidden = true
        _currentVC?.innerTableViewScrollDelegate = self
        addPanGestureToTopViewAndCollectionView()
    }
    
    override func setupUi() {
        if _user?.images.isEmpty == true {
            _customGallaryView.setupHeader([""])
        } else {
            _customGallaryView.setupHeader(_user?.images.toArray(ofType: String.self) ?? [""])
        }
//        setImagesViews()
        _userNameLabel.text = APPSESSION.userDetail?.fullName
        _userImageView.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _bioLabel.text = APPSESSION.userDetail?.bio
        _followersCount.text = "\(APPSESSION.userDetail?.follower ?? 0)"
        _followingCount.text = "\(APPSESSION.userDetail?.following ?? 0)"
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func add(asChildViewController viewController: UIViewController) {
        if let currentVC = _currentVC {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(viewController)
        _containerView.addSubview(viewController.view)
        
        viewController.view.frame = _containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
        
        _currentVC = viewController as? ProfileBaseMainVC
    }
    
    private func setImagesViews() {
        guard let userModel = _user else { return }
        let _mutualFriends = userModel.mutualFriends.toArrayDetached(ofType: UserDetailModel.self).filter{$0.isValid()}

        var followdbytxt: [String] = []
        for i in 0..<4 {
            if i < _mutualFriends.count {
                _mutualimageViews[i].loadWebImage(_mutualFriends[i].image, name: _mutualFriends[i].fullName)
                followdbytxt.append(_mutualFriends[i].firstName)
            } else {
                _mutualimageViews[i].isHidden = true
            }
        }
        
        if _mutualFriends.count > 4 {
            _mutualText.text = "followed_by".localized() + followdbytxt.joined(separator: ", ") + " and \(_mutualFriends.count - 4) others"
        } else {
            _mutualText.text = "followed_by".localized() + followdbytxt.joined(separator: ", ")
        }
        
        _mutualStack.isHidden = _mutualFriends.count == 0
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestGetCMProfile() {
        WhosinServices.getComplementaryProfile { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self._user = data.profile
            self.setupUi()
        }
    }
    
    func getProfileData() {
        APPSESSION.getProfile { success, error in
            if success {
                self._user = APPSESSION.userDetail
                self.setupUi()
            }
        }
    }
    
    private func  _generateDynamicLinks() {
        guard let user = APPSESSION.userDetail else {
            return
        }
        let shareMessage = "\(user.fullName) \n\n\(user.bio) \n\n\("https://explore.whosin.me/u/\(user.id)")"
        let items = [shareMessage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.setValue(kAppName, forKey: "subject")
        activityController.popoverPresentationController?.sourceView = view
        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
        present(activityController, animated: true, completion: nil)
    }
    
    private func _requestEventList() {
        WhosinServices.getEventList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            let eventCount = self.getAllEventsCount(eventList: data)
            let title = eventCount > 0 ? "my_actions".localized() + "(\(eventCount))" : "my_actions".localized()
            self._actionBtn.setTitle(title, for: .normal)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    @objc func handlePushReload() {
        if APPSESSION.userDetail?.isRingMember == true {
            _requestGetCMProfile()
            _requestEventList()
        }
        getProfileData()
    }
    
    @objc func _handleFollowStatusEvent() {
        getProfileData()
    }
    
    func addPanGestureToTopViewAndCollectionView() {
        let topViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(topViewMoved))
        stickyHeaderView.isUserInteractionEnabled = true
        stickyHeaderView.addGestureRecognizer(topViewPanGesture)
    }
    
    func getAllEventsCount(eventList: [PromoterEventsModel]) -> Int {
        let acceptedEventsCount = eventList.filter {
            $0.invite?.inviteStatus == "in" && $0.invite?.promoterStatus == "accepted"
        }.count

        let pendingEventsCount = eventList.filter {
            $0.invite?.inviteStatus == "in" && $0.invite?.promoterStatus == "pending" && !$0.isEventFull
        }.count

        let wishlistedEventsCount = eventList.filter { $0.isWishlisted }.count


        return acceptedEventsCount + pendingEventsCount + wishlistedEventsCount
        
    }
        
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func topViewMoved(_ gesture: UIPanGestureRecognizer) {
        
        var dragYDiff : CGFloat
        
        switch gesture.state {
            
        case .began:
            
            dragInitialY = gesture.location(in: self.view).y
            dragPreviousY = dragInitialY
            
        case .changed:
            
            let dragCurrentY = gesture.location(in: self.view).y
            dragYDiff = dragPreviousY - dragCurrentY
            if dragCurrentY > 200 && !isRefreshing {
                _headerTopConstraint.constant = refreshControl.frame.height + 30
                startRefreshing()
            }
            dragPreviousY = dragCurrentY
            dragDirection = dragYDiff < 0 ? .Down : .Up
            innerTableViewDidScroll(withDistance: dragYDiff)
            
        case .ended:
            
            innerTableViewScrollEnded(withScrollDirection: dragDirection)
            
        default: return
        
        }
    }
    
    @IBAction private func _handleEditEvent(_ sender: Any) {
        if APPSESSION.userDetail?.isRingMember == true {
            let vc = INIT_CONTROLLER_XIB(PromoterApplicationVC.self)
            vc.isEdit = true
            vc.isComlementry = true
            vc.detailModel = _user
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func handleChangeTab(_ sender: UIButton) {
        for button in actionBtns {
            button.backgroundColor = UIColor(hexString: "#232323")
        }
        sender.backgroundColor = ColorBrand.brandPink

        switch sender {
        case actionBtns[0]:
            let cmEventListVC = INIT_CONTROLLER_XIB(CMEventListVC.self)
            cmEventListVC.innerTableViewScrollDelegate = self
            add(asChildViewController: cmEventListVC)
            
        case actionBtns[1]:
            let myAction = INIT_CONTROLLER_XIB(MyActionVC.self)
            myAction.innerTableViewScrollDelegate = self
            add(asChildViewController: myAction)
            
        case actionBtns[2]:
            let contactVC = INIT_CONTROLLER_XIB(FeedVC.self)
            contactVC.innerTableViewScrollDelegate = self
            add(asChildViewController: contactVC)
            
        case actionBtns[3]:
            let contactVC = INIT_CONTROLLER_XIB(CMEventHistoryVC.self)
            contactVC.innerTableViewScrollDelegate = self
            add(asChildViewController: contactVC)

        default:
            break
        }
    }

    @IBAction private func _handleShareProfileEvent(_ sender: UIButton) {
        _generateDynamicLinks()
    }
    
    @IBAction private func _handleOpenFollowersListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.modalPresentationStyle = .fullScreen
        vc.isFollowerList = true
        vc.followId = APPSESSION.userDetail?.id ?? kEmptyString
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleOpenFollowingList(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.modalPresentationStyle = .fullScreen
        vc.isFollowerList = false
        vc.followId = APPSESSION.userDetail?.id ?? kEmptyString
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// --------------------------------------
// MARK: Delegate
// --------------------------------------

extension CommanProfileVC: InnerTableViewScrollDelegate {

    var currentHeaderHeight: CGFloat {
        return headerViewHeightConstraint.constant
    }

    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        let newHeight = headerViewHeightConstraint.constant - scrollDistance
        headerViewHeightConstraint.constant = max(topViewFinalHeight, min(max(0, newHeight), topViewInitialHeight))
    }

    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection) {
        guard !isAnimatingHeader else { return } // Prevent triggering animations multiple times

        let topViewHeight = headerViewHeightConstraint.constant

        if topViewHeight <= topViewFinalHeight + 20 {
            scrollToFinalView()
        } else if topViewHeight >= topViewInitialHeight - 20 {
            scrollToInitialView()
        } else {
            switch scrollDirection {
            case .Down:
                scrollToInitialView()
            case .Up:
                scrollToFinalView()
            }
        }
    }

    func scrollToInitialView() {
        guard !isAnimatingHeader, headerViewHeightConstraint.constant > 260 else { return }
        isAnimatingHeader = true

        let distanceToMove = abs(headerViewHeightConstraint.constant - topViewInitialHeight)
        let duration = max(0.1, distanceToMove / 700) // Adjusted for smoother scrolling duration

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.headerViewHeightConstraint.constant = topViewInitialHeight
            self.view.layoutIfNeeded() // Ensures layout changes are animated smoothly
        }, completion: { _ in
            self.isAnimatingHeader = false
        })
    }

    func scrollToFinalView() {
        guard !isAnimatingHeader, headerViewHeightConstraint.constant < 60 else { return }
        isAnimatingHeader = true

        let distanceToMove = abs(headerViewHeightConstraint.constant - topViewFinalHeight)
        let duration = max(0.1, distanceToMove / 700) // Adjusted for smoother scrolling duration

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.headerViewHeightConstraint.constant = topViewFinalHeight
            self.view.layoutIfNeeded() // Ensures layout changes are animated smoothly
        }, completion: { _ in
            self.isAnimatingHeader = false
        })
    }


}



extension CommanProfileVC: ReloadProfileDelegate {
    func didRequestReload() {
        APPSESSION.getProfile(isFromMenu: true) { isSuccess, error in
            self.setupUi()
        }
    }
}

// --------------------------------------
// MARK: Profile BaseViewcontroller
// --------------------------------------


protocol InnerTableViewScrollDelegate: class {
    var currentHeaderHeight: CGFloat { get }
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: DragDirection)
}

class ProfileBaseMainVC: BaseViewController {
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    
    //MARK:- Stored Properties for Scroll Delegate
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero

    func didScroll(_ scrollView: UIScrollView) {
        
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        
        let topViewCurrentHeightConst = innerTableViewScrollDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            
            if delta > 0,
                topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound,
                scrollView.contentOffset.y > 0 {
                dragDirection = .Up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            if delta < 0,
                scrollView.contentOffset.y < 0 {
                dragDirection = .Down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
    
    func didEndDecelerating(_ scrollView: UIScrollView) {
                
        if scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    func didEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            innerTableViewScrollDelegate?.innerTableViewScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    func _refresh(_ callback: @escaping (Bool) -> Void) {}
}
