import UIKit
import Hero

class StoryUserCell: UICollectionViewCell {
    
    @IBOutlet weak var _addStoryImage: UIImageView!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet weak var _viewImageBg: UIView!
    @IBOutlet weak var _removeIcon: UIButton!
    var userId: String = kEmptyString
    var _bucketId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 120 }
    
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self._nameLabel.textAlignment = .center
        self._imageView.layer.cornerRadius = self._imageView.frame.size.height / 2
        self._viewImageBg.layer.cornerRadius = self._viewImageBg.frame.size.height / 2
    }
    
    public func setupMyStory(model: String) {
        _viewImageBg.borderWidth = 0
        _addStoryImage.image = UIImage(named: "icon_itemAdd")
        _nameLabel.text = "Add Story"
        _imageView.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _addStoryImage.isHidden = false
    }
    
    public func setup(model: VenueDetailModel, _ isChat: Bool = false) {
        _addStoryImage.isHidden = true
        _nameLabel.text = model.name
        _imageView.loadWebImage(model.logo, name: model.name)
        _imageView.hero.id = model.id
        _imageView.hero.modifiers = HeroAnimationModifier.stories
        _viewImageBg.setupStoryRing(id: model.id)
    }
    
    public func storyContact(model: UserModel, bucketId: String = kEmptyString) {
        self._imageView.borderWidth = 1.5
        self._imageView.borderColor = .white
        self._removeIcon.isHidden = false
        _nameLabel.text = "\(model.firstName) \(model.lastName)" 
        _imageView.loadWebImage(model.image, name: model.firstName)
        _bucketId = bucketId
    }
    
    @IBAction func _handleRemoveEvent(_ sender: UIButton) {
        let alert = UIAlertController(title: "remove_contact".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: {action in
        }))
        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { action in
            DISPATCH_ASYNC_MAIN {
                self.removeBucket(bucketId: self._bucketId, userId: self.userId)
            }
        }))
        DISPATCH_ASYNC_MAIN {[weak self] in self?.parentViewController?.present(alert, animated: true) }
    }
    
    private func removeBucket(bucketId: String, userId: String) {
        WhosinServices.removeShareBucket(bucketId: bucketId, userId: userId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            self.parentViewController?.view.makeToast(data.message)
            self.parentViewController?.dismiss(animated: true)
        }
    }
    
}
