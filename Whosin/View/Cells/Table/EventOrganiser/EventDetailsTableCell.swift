import UIKit
import ExpandableLabel
import MessageUI
import MapKit
import MediaBrowser
import CoreMedia


class EventDetailsTableCell: UITableViewCell {
    
    @IBOutlet private weak var _followButton: CustomActivityButton!
    @IBOutlet private weak var _bgView: GradientView!
    @IBOutlet private weak var _venueDesc: UILabel!
    @IBOutlet private weak var _venueTitle: UILabel!
    @IBOutlet private weak var _logoImageView: UIImageView!
    @IBOutlet private weak var _galaryContainerView: UIView!
    @IBOutlet private weak var _galaryImageCount: UILabel!
    @IBOutlet private weak var _galaryCountView: UIView!
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _description: UILabel!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _safeHeight: NSLayoutConstraint!
    private var _organizaitonModel: OrganizaitionDetailModel?
    private var imageArray: [String] = []
    private var _galaryArrayList = [Media]()
    private var _isFollowing: Bool = false
    var completion: (() -> Void)?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestFollowUnfollow() {
        _followButton.setTitle(kEmptyString)
        _followButton.showActivity()
        guard let _organizaitonModel = _organizaitonModel else { return }
        WhosinServices.followEventOrg(id: _organizaitonModel.id) { [weak self] container, error in
            guard let self = self else { return }
            if let message = container?.message {
                _organizaitonModel.isFollowing = !_organizaitonModel.isFollowing
                self._followButton.hideActivity()
                self._followButton.setTitle(_organizaitonModel.isFollowing ? "following".localized() : "Follow")
                self.parentBaseController?.showSuccessMessage(!_organizaitonModel.isFollowing ? "oh_snap".localized() : "thank_you".localized(), subtitle: !self._isFollowing ? "You have unfollowed \(_organizaitonModel.name)" : "For following \(_organizaitonModel.name)")
            }
            
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        disableSelectEffect()
        imageArray.removeAll()
        let img = UIImage(named: "icon_backArrow")?.withRenderingMode(.alwaysTemplate)
        _backButton.setImage(img, for: .normal)
        _backButton.tintColor = .white
        if let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height {
            _safeHeight.constant = statusBarHeight
        } else {
            _safeHeight.constant = 20
        }
    }
    
    private func _loadData() {
        _venueDesc.text = _organizaitonModel?.website
        _venueTitle.text = _organizaitonModel?.name
        _logoImageView.loadWebImage(_organizaitonModel?.logo ?? "")
        _followUnfollowToggle()
        _galaryImageSetup()
    }
    
    private func _followUnfollowToggle() {
        guard let isFollowing = self._organizaitonModel?.isFollowing else { return }
        _followButton.setTitle( isFollowing ? "following".localized() : "Follow")
        _isFollowing = !isFollowing
    }
    
    private func _galaryImageSetup() {
        imageArray.removeAll()
        _organizaitonModel?.galleries.forEach { image in
            imageArray.append(image.image)
        }
        if !Utils.stringIsNullOrEmpty(_organizaitonModel?.cover) { imageArray.insert(_organizaitonModel?.cover ?? "", at: 0) }
        if !imageArray.isEmpty {
            configureImageViews(imageViews: _imageViews, galaryImages: imageArray)
            imageArray.forEach { image in
                if let media = Utils.webMediaPhoto(url: image, caption: nil) {
                    _galaryArrayList.append(media)
                }
            }
        } else {
            _galaryContainerView.isHidden = true
        }
        
        _coverImage.loadWebImage(_organizaitonModel?.cover ?? "") {
            do {
                self._bgView.startColor = try self._coverImage.image?.averageColor() ?? ColorBrand.brandPink
            } catch {
                
            }
        }
    }
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func configureImageViews(imageViews: [UIImageView], galaryImages: [String?]) {
        let totalImageViews = imageViews.count
        for i in 0..<totalImageViews {
            if i < galaryImages.count {
                imageViews[i].isHidden = false
                imageViews[i].loadWebImage(galaryImages[i] ?? "") {
                    do {
                        imageViews[i].borderColor = try imageViews[i].image?.averageColor() ?? ColorBrand.brandImageBorder
                        imageViews[i].borderWidth = 1
                    } catch {}
                }
            } else {
                imageViews[i].isHidden = true
            }
        }
        
        if galaryImages.count > totalImageViews {
            let remainingCount = galaryImages.count - totalImageViews
            _galaryCountView.isHidden = false
            _galaryImageCount.text = "+\(remainingCount)"
        } else {
            _galaryCountView.isHidden = true
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: OrganizaitionDetailModel, completion: (() -> Void)?) {
        self.completion = completion
        _organizaitonModel = data
        _description.text = data.desc
        
        _loadData()
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func backButtonAction() {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        completion?()
    }
    
    @IBAction private func _handleOpenGalary(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let browser = MediaBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        parentViewController?.present(browser, animated: true)
    }
    
    @IBAction private func _hanndleFollowEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        guard let id = _organizaitonModel?.id else { return }
        _requestFollowUnfollow()
    }
}

extension EventDetailsTableCell:  ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        (self.superview as? CustomTableView)?.update()
    }
}

extension EventDetailsTableCell: MediaBrowserDelegate {
    
    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return _galaryArrayList[index]
    }
    
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int {
        _galaryArrayList.count
    }
    
    func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return _galaryArrayList[index]
    }
    
    func gridCellSize() -> CGSize {
        return CGSize(width: (self.frame.width - kCollectionDefaultMargin)/4 , height: (self.frame.width - kCollectionDefaultMargin)/4)
    }
}
