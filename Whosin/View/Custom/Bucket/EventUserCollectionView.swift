import UIKit
import SnapKit
import SkeletonView

class EventUserCollectionView: UIView {
    
    var didAddCallback: (() -> Void)?
    var didOpenShheetCallback: (() -> Void)?
    
    @IBOutlet private weak var _contentView: UIView!
    @IBOutlet private weak var _collectionView: UICollectionView!
    @IBOutlet private weak var _usersLabel: UILabel!
    
    private let kCellIdentifier = String(describing: EventUserAvatarCollectionCell.self)
    private var _userList: [EventUsersModel] = []
    private var _type: EventUserCollectionType = .admin
    private var _isAllowAdd = false
    private var _isAllowToViewDetail = true

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _isAdmin: Bool {
        _type == .admin || _type == .adminOnly
    }
    
    private func _setupUi() {
        Bundle.main.loadNibNamed("EventUserCollectionView", owner: self, options: nil)
        addSubview(_contentView)
        _contentView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        _collectionView.register(UINib(nibName: kCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellIdentifier)
        _collectionView.dataSource = self
        _collectionView.delegate = self
        _collectionView.showsHorizontalScrollIndicator = false
        
        let layout = AvatarCollectionViewFlowLayout()
        layout.cellPadding = -16
        _collectionView.collectionViewLayout = layout
    }
    
    private func _updateDescription(additionalGuest: Int = 0) {
        guard !_isAdmin else {
            if _type == .adminOnly { _usersLabel.isHidden = true; return }
            
            var contacts: [String] = []
            _userList.forEach { user in
                if let name = user.user?.profile?.firstName { contacts.append(name) }
            }
            _usersLabel.text = contacts.isEmpty ? kEmptyString : contacts.joined(separator: ", ")
            return
        }
        
        var contacts: [String] = []
        _userList.forEach { user in
            if contacts.count < 2 { if let name = user.user?.profile?.firstName { contacts.append(name) } }
        }
        
        var users = _userList.isEmpty ? "Friends" : "\(_userList.count) friends"
        if !contacts.isEmpty {
            if _userList.count > 2 {
                if additionalGuest == .zero {
                    users = "\(contacts.joined(separator: ", ")) and \(_userList.count - contacts.count) friends"
                } else {
                    let guestSuffix = additionalGuest > 1 ? "additional guests" : "additional guest"
                    users = "\(contacts.joined(separator: ", ")), \(_userList.count - contacts.count) friends and \(additionalGuest) \(guestSuffix)"
                }
            } else if contacts.count == 1 {
                users = contacts.first ?? kEmptyString
            } else {
                if additionalGuest == .zero {
                    users = "\(contacts.first ?? kEmptyString) and \(contacts.last ?? kEmptyString)"
                } else {
                    let guestSuffix = additionalGuest > 1 ? "additional guests" : "additional guest"
                    users = "\(contacts.first ?? kEmptyString), \(contacts.last ?? kEmptyString) and \(additionalGuest) \(guestSuffix)"
                }
            }
        }
        
        if _type == .in {
            _usersLabel.text = "\(users) are attending"
        } else if _type == .pending {
            _usersLabel.text = "Waiting for \(users)"
        } else if _type == .out {
            _usersLabel.text = "\(users) not attending"
        } else if _type == .invite {
            _usersLabel.text = users
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(users: [EventUsersModel], type: EventUserCollectionType, additionalGuest: Int = 0, isAllowAdd: Bool = false, isAllowToViewDetail: Bool = true) {
        _userList = users
        _type = type
        _isAllowAdd = isAllowAdd
        _isAllowToViewDetail = isAllowToViewDetail
        
        _updateDescription(additionalGuest: additionalGuest)
        
        if isAllowAdd { _userList.append(EventUsersModel()) }
        _collectionView.reloadData()
    }
}

extension EventUserCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <UICollectionViewDataSource>
    // --------------------------------------
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _userList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier, for: indexPath) as! EventUserAvatarCollectionCell
        let eventUser = _userList[indexPath.row]
        let image = eventUser.user?.profile?.photo ?? kEmptyString
        let color: UIColor? = _isAdmin ? eventUser.userColor : nil
        let isAdd = _isAllowAdd && (_userList.count == indexPath.row + 1)
        cell.setup(image: image, color: color, isAdmin: _isAdmin, isAdd: isAdd)
        return cell
    }
    
    // --------------------------------------
    // MARK: <UICollectionViewDelegate>
    // --------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard _isAllowAdd, _userList.count == indexPath.row + 1 else {
            guard !_isAdmin, _isAllowToViewDetail else { return }
            
            var users = _userList
            if _isAllowAdd { users.removeLast() }
            let controller = INIT_CONTROLLER_XIB(FriendListVC.self)
            controller.userList = users
            parentViewController?.presentAsPanModal(controller: controller)
            return
        }
        didAddCallback?()
    }
}


private class AvatarCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var cellPadding: CGFloat = 0.0
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func prepare() {
        super.prepare()
        
        // Get collection view frame
        let collectionViewFrame = self.collectionView!.frame
        let cellDimension = min(collectionViewFrame.width, collectionViewFrame.height)

        // Make sure the last item is clipped to indicate the horizontal scrolling
        let maximumNumberOfItems = (collectionViewFrame.width / (cellDimension + self.cellPadding))
        let remainingSpace = maximumNumberOfItems.truncatingRemainder(dividingBy: 1.0) * (cellDimension + self.cellPadding)
        var sectionLeftRightPadding: CGFloat = 0.0
        
        // we need to check if remaining space is more than cell dimention which means that there is already a clipped item
        // And calculate section padding by showing 0.3 percent of the cell diemention
        if remainingSpace >= cellDimension {
            sectionLeftRightPadding = remainingSpace - cellDimension + (0.3 * cellDimension)
        }

        // Set layout attributes
        self.scrollDirection = UICollectionView.ScrollDirection.horizontal
        self.itemSize = CGSize(width: cellDimension, height: cellDimension)
        self.minimumLineSpacing = self.cellPadding
        self.sectionInset = UIEdgeInsets.init(top: 0, left: sectionLeftRightPadding, bottom: 0, right: sectionLeftRightPadding)
    }
}
