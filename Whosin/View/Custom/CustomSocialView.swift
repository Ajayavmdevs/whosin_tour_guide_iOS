import UIKit
import SnapKit

class CustomSocialView: UIView {
    
    @IBOutlet weak var _collectionHight: NSLayoutConstraint!
    @IBOutlet weak var _customCollectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: SocialCollectionViewCell.self)
    private var socialList: [SocialAccountsModel] = []
    public var updateDataCallback: ((_ model: [SocialAccountsModel]) -> Void)?
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupCollectionView()
    }
    
    
    private func _setupCollectionView() {
        _customCollectionView.setup(cellPrototypes: _prototype,
                                    hasHeaderSection: false,
                                    enableRefresh: false,
                                    columns: 1,
                                    rows: 1,
                                    scrollDirection: .vertical,
                                    emptyDataText: kEmptyString,
                                    emptyDataIconImage: nil,
                                    delegate: self)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !socialList.isEmpty {
            socialList.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: SocialCollectionViewCell.self,
                    kCellHeightKey: SocialCollectionViewCell.height
                ])
            }
        }
        
        _collectionHight.constant = CGFloat(cellData.count * 80)
        _customCollectionView.layoutIfNeeded()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SocialCollectionViewCell.self, kCellHeightKey: SocialCollectionViewCell.height]]
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomSocialView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    
    public func setupData(_ model: [SocialAccountsModel]) {
        socialList = model
        _loadData()
    }
    
    func showActionSheet( completion: @escaping (String?) -> Void) {
        let actionSheet = UIAlertController(title: "select_platform".localized(), message: nil, preferredStyle: .actionSheet)
        
        let platforms: [SocialPlatforms] = [.instagram, .tiktok, .facebook, .google, .youtube, .snapchat, .website, .whatsapp, .email, .whosin]
        for platform in platforms {
            let action = UIAlertAction(title: platform.rawValue.capitalizedSentence, style: .default) { _ in
                completion(platform.rawValue)
            }
            actionSheet.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { _ in
            completion(nil)
        }
        actionSheet.addAction(cancelAction)
        
        parentViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction private func _handleAddmoreEvent(_ sender: UIButton) {
        showActionSheet { plateform in
            var model = SocialAccountsModel()
            model.platform = plateform ?? kEmptyString
            if !Utils.stringIsNullOrEmpty(plateform) {
                self.socialList.append(model)
                self._loadData()
                self.updateDataCallback?(self.socialList)
            }
        }
    }
    
}

extension CustomSocialView: CustomCollectionViewDelegate, SocialCollectionViewCellDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SocialCollectionViewCell, let object = cellDict?[kCellObjectDataKey] as? SocialAccountsModel else  { return }
        cell.setupData(object.platform, text: object.account, icon: "\(object.platform)", platform: SocialPlatforms(rawValue: object.platform) ?? .instagram, titleText: object.title)
        cell.delegate = self
        cell.indexPath = indexPath
//        cell.deleteBtn.tag = indexPath.row
//        cell.deleteBtn.addTarget(self, action: #selector(_deleteEvent(_ :)), for: .touchUpInside)
        cell.callback = { [weak self] text, platform, titleText in
            guard let self = self else { return }
            guard indexPath.row < self.socialList.count else { return }
            self.socialList[indexPath.row].platform = platform.rawValue
            self.socialList[indexPath.row].account = text ?? kEmptyString
            self.socialList[indexPath.row].title = titleText ?? kEmptyString
            self.updateDataCallback?(self.socialList)
        }
    }
    
    func didTapDeleteButton(at indexPath: IndexPath) {
        self.parentBaseController?.showCustomAlert(title: kAppName, message: "are_you_sure_remove".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
            self.socialList.remove(at: indexPath.row)
            self.updateDataCallback?(self.socialList)
        }, noHandler:  { UIAlertAction in
        })
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 28, height: 80)
    }
    
//    @objc private func _deleteEvent(_ sender: UIButton) {
//        let alertController = UIAlertController(title: kAppName, message: "Are you sure you want to remove?", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        
//        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
//            self.socialList.remove(at: sender.tag)
//            self.updateDataCallback?(self.socialList)
//        }
//        
//        alertController.addAction(confirmAction)
//        parentViewController?.present(alertController, animated: true, completion: nil)
//
//    }
}



