import UIKit
import MessageUI
import MapKit
import MediaBrowser
import CoreMedia
import CollectionViewPagingLayout

class BucketHeaderTableCell: UITableViewCell {
    
    @IBOutlet weak var _collectionHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var _bannerCollectionView: UICollectionView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _editButton: UIButton!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _galaryContainerView: UIView!
    @IBOutlet private weak var _galaryImageCount: UILabel!
    @IBOutlet private weak var _galaryCountView: UIView!
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet weak var _viewHeight: NSLayoutConstraint!
    
    private var imageArray: [String] = []
    private var _gallaryArrayList = [Media]()
    private let _imagePicker = UIImagePickerController()
    private let kCellIdentifierStory = String(describing: SharedUsersCollectionCell.self)
    private var _bucketDetail: BucketDetailModel?
    
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
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        disableSelectEffect()
        _collectionView.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        imageArray.removeAll()
        let layout = CollectionViewPagingLayout()
        layout.numberOfVisibleItems = 5
        layout.scrollDirection = .horizontal
        _bannerCollectionView.delegate = self
        _bannerCollectionView.dataSource = self
        _bannerCollectionView.collectionViewLayout = layout
        _bannerCollectionView.isPagingEnabled = true
        _bannerCollectionView.register(UINib(nibName: "BannerImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BannerImageCollectionCell")
        _bannerCollectionView.reloadData()

    }
    
    private func _loadData() {
        guard let _bucketDetail = _bucketDetail else { return }
        
        imageArray.removeAll()
        self._gallaryImageSetup()
        _editButton.isHidden = _bucketDetail.userId != APPSESSION.userDetail?.id
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        if !_bucketDetail.sharedWith.isEmpty {
            _bucketDetail.sharedWith.forEach { contact in
                if !contact.firstName.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierStory,
                        kCellTagKey: contact.id,
                        kCellObjectDataKey: contact,
                        kCellClassKey: SharedUsersCollectionCell.self,
                        kCellHeightKey: SharedUsersCollectionCell.height
                    ])
                }
            }
        }
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierStory,
            kCellTagKey: kCellIdentifierStory,
            kCellObjectDataKey: "Add",
            kCellClassKey: SharedUsersCollectionCell.self,
            kCellHeightKey: SharedUsersCollectionCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: SharedUsersCollectionCell.self, kCellHeightKey: SharedUsersCollectionCell.height]]
    }
    
    private func _gallaryImageSetup() {
        imageArray.removeAll()
        _bucketDetail?.galleries.forEach { image in
            imageArray.append(image)
        }
        if !imageArray.isEmpty {
            configureImageViews(imageViews: _imageViews, galaryImages: imageArray)
            
            _gallaryArrayList.removeAll()
            imageArray.forEach { image in
                if let media = Utils.webMediaPhoto(url: image, caption: nil) {
                    _gallaryArrayList.append(media)
                    if let firstImage = imageArray.first {
                        _coverImage.loadWebImage(firstImage)
                    }
                    _viewHeight.constant = 305
                }
            }
        } else {
            _viewHeight.constant = 0
            _galaryContainerView.isHidden = true
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


    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func _openActivity(id: String, name: String) {

    }
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestUploadProfileImage(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        WhosinServices.uploadProfileImage(image: image) { [weak self] model, error in
            guard let self = self else { return }
            guard let photoUrl = model?.data else { return }
            self._requestAddImageInBucket(photoUrl.url)
        }
    }
    
    private func _requestAddImageInBucket(_ image: String) {
        WhosinServices.addGalaryImageBucket(bucketId: self._bucketDetail?.id ?? "", image: image) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.makeToast(container?.message)
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleAddGalaryImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.allowsEditing = true
            parentViewController?.present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func _handleOpenGallaryEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let browser = MediaBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        browser.modalPresentationStyle = .pageSheet
        parentViewController?.present(browser, animated: true)
    }
    
    @IBAction private func _handleEditEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(CreateBucketBottomSheet.self)
        presentedViewController.isFromEdit = true
        presentedViewController.bucketDetail = _bucketDetail
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
//    @objc func handleOpenUser(_ notification: Notification) {
//        if let data = notification.userInfo as? [String: Any] {
//            let model = data["contact"] as? UserDetailModel
//            let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
//            vc.modalPresentationStyle = .overFullScreen
////            vc.name = "\(model?.firstName ?? kEmptyString) \(model?.lastName ?? kEmptyString)"
////            vc.profileImage = model?.image ?? ""
//            vc.contactId = model?.id ?? ""
//            parentViewController?.present(vc, animated: true, completion: nil)
//        }
//    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: BucketDetailModel) {
        self._bucketDetail = model
        _gallaryImageSetup()
        _loadData()
    }
    
}

extension BucketHeaderTableCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension BucketHeaderTableCell: MediaBrowserDelegate {
    
    func thumbnail(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return _gallaryArrayList[index]
    }
    
    func numberOfMedia(in mediaBrowser: MediaBrowser) -> Int {
        _gallaryArrayList.count
    }
    
    func media(for mediaBrowser: MediaBrowser, at index: Int) -> Media {
        return _gallaryArrayList[index]
    }
    
    func gridCellSize() -> CGSize {
        return CGSize(width: (self.frame.width - kCollectionDefaultMargin)/4 , height: (self.frame.width - kCollectionDefaultMargin)/4)
    }
}

extension BucketHeaderTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object)
        }
        else {
            cell.setupData(UserDetailModel(), isLastIndex: true)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let index = indexPath.row
        if index == _bucketDetail?.sharedWith.count {
            let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            presentedViewController.bucketId = self._bucketDetail?.id ?? ""
            presentedViewController._bucketDetail = self._bucketDetail
            presentedViewController.modalPresentationStyle = .overFullScreen
            parentViewController?.navigationController?.present(presentedViewController, animated: true) 
            _collectionView.reload()
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}


extension BucketHeaderTableCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self._requestUploadProfileImage(image)
            }
        }
    }
}

extension BucketHeaderTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == _bannerCollectionView {
            return 10000
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerImageCollectionCell", for: indexPath) as! BannerImageCollectionCell
        if collectionView == _bannerCollectionView {
            if imageArray.isEmpty { return cell }
            let index = indexPath.row % imageArray.count
            cell.setupData(imageArray[index])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == _bannerCollectionView {
            let browser = MediaBrowser(delegate: self)
            browser.startOnGrid = true
            browser.enableGrid = true
            browser.modalPresentationStyle = .popover
            browser.preferredContentSize = CGSize(width: kScreenWidth, height: 200)
            parentViewController?.present(browser, animated: true)
        }
    }
}
