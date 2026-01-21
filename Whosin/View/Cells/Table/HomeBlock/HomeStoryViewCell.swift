import UIKit
import GSPlayer
import Hero
import AVKit
import StripeCore

class HomeStoryViewCell: UITableViewCell {
    
    @IBOutlet private weak var _storyCollectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifierStory = String(describing: StoryUserCell.self)
    private var venueDetailModel: [VenueDetailModel] = []
    private let _imagePicker = UIImagePickerController()
    var params: [String: Any] = [:]
    private var displayedStories: [VenueDetailModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: kReloadStoryyNotification, object: nil)
    }
    
    class var height: CGFloat {
        140
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _loadData()
    }

    private func setupUi() {
        _storyCollectionView.setup(cellPrototypes: _storyPrototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 5,
                                   rows: 1,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _storyCollectionView.showsVerticalScrollIndicator = false
        _storyCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _requestUploadProfileImage(_ image: UIImage? = nil, videoUrl: URL? = nil) {
        parentBaseController?.showHUD()
        if let image = image {
            WhosinServices.uploadFile(fileUrl: getImageUrl(image: image)) { [weak self] model, error in
                guard let self = self else { return }
                guard let photoUrl = model?.data else { return }
                self.params["mediaUrl"] = photoUrl
                self.params["mediaType"] = "photo"
                self.params["duration"] = kEmptyString
                self.params["thumbnail"] = kEmptyString
                self._requestAddStory()
            }
        } else if let videoUrl = videoUrl {
            getVideo(videoUrl) { localUrl in
                WhosinServices.uploadFile(fileUrl: localUrl ?? videoUrl) { [weak self] model, error in
                    guard let self = self else { return }
                    guard let videoUrl = model?.data else { return }
                    self.params["mediaUrl"] = videoUrl
                    self.params["mediaType"] = "video"
                    self._requestAddStory()
                }
            }
        }
    }
    
    private func _requestAddStory() {
        WhosinServices.requestAddStory(params: params) { [weak self] model, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = model?.data else { return }
            self.parentBaseController?.showToast(model?.message ?? "")
        }
    }
    
    private func _loadData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let viewedStories = Utils.getViewedStories()

            // Work on a copy
//            let sortedModel = self.venueDetailModel.sorted { (story1, story2) -> Bool in
//                let isViewed1 = viewedStories.contains(story1.id)
//                let isViewed2 = viewedStories.contains(story2.id)
//
//                if isViewed1 == isViewed2 {
//                    if isViewed1 {
//                        let index1 = viewedStories.firstIndex(of: story1.id) ?? 0
//                        let index2 = viewedStories.firstIndex(of: story2.id) ?? 0
//                        return index1 > index2
//                    } else {
//                        let date1 = story1.storie.first?.createdAt.toDate(format: kFormatDateStandard) ?? .distantPast
//                        let date2 = story2.storie.first?.createdAt.toDate(format: kFormatDateStandard) ?? .distantPast
//                        return date1 < date2
//                    }
//                }
//
//                return !isViewed1 && isViewed2
//            }

            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()

            venueDetailModel.forEach { story in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifierStory,
                    kCellTagKey: story.id,
                    kCellDifferenceContentKey: story.id,
                    kCellDifferenceIdentifierKey: story.id,
                    kCellObjectDataKey: story,
                    kCellClassKey: StoryUserCell.self,
                    kCellHeightKey: StoryUserCell.height,
                    kCellClickEffectKey: true
                ])
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            self.displayedStories = venueDetailModel
            DispatchQueue.main.async {
                self._storyCollectionView.loadData(cellSectionData)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func setupData(_ data: [VenueDetailModel]) {
        venueDetailModel = data
        _loadData()
    }
    
    @objc func handleReload() {
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: String(describing: StoryUserCell.self), kCellClassKey: StoryUserCell.self, kCellHeightKey: StoryUserCell.height]]
    }
    
    private func _viewStoryAt(index: Int, heroId: String) {
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = self.displayedStories
        controller.currentIndex = index
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = heroId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        parentViewController?.present(controller, animated: true)
    }
    
    private func imagePickerTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.mediaTypes = ["public.image", "public.movie"]
            _imagePicker.allowsEditing = true
            self.parentViewController?.present(_imagePicker, animated: true, completion: nil)
        }
    }

    private func getImageUrl(image: UIImage) -> URL {
        let imageName = Utils.dateToString(Date(), format: kFormatDateImageName) + ".jpg"
        Utils.saveFileToLocal(image, fileName: imageName)
        let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(imageName)
        return fileUrl
    }
    
    private func getVideo(_ video: URL, completion: @escaping (URL?) -> Void) {
        let videourlName = Utils.dateToString(Date(), format: kFormatDateImageName) + ".mp4"
        Utils.saveFileFromURL(video, fileName: videourlName) { localVideoUrl in
            completion(localVideoUrl)
        }
    }
    
}

extension HomeStoryViewCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? StoryUserCell,
              let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        cell.setup(model: object)
//        cell.prepareForReuse()
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? StoryUserCell,
              let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        guard let storyModel = object.storie.first else {return}
        if storyModel.mediaType == "image" {
            cell._viewImageBg.removeGradientBorders()
            cell._viewImageBg.addRoundedRectGradientStrokeAnimation(strokeWidth: 4, duration: 1)
            DISPATCH_ASYNC_MAIN_AFTER(0.7) {
                self._viewStoryAt(index: indexPath.row , heroId: object.id)
            }
        } else {
            guard let url = URL(string: storyModel.mediaUrl) else { return }
            if let configuration = try? VideoCacheManager.cachedConfiguration(for: url)  {
                self._viewStoryAt(index: indexPath.row , heroId: object.id)
                return
            }
            
            VideoPreloadManager.shared.preloadByteCount = 1024 * 1024 * 2
            VideoPreloadManager.shared.set(waiting: [url])
            cell._viewImageBg.removeGradientBorders()
            cell._viewImageBg.addRoundedRectGradientStrokeAnimation(strokeWidth: 4, duration: 10)
            VideoPreloadManager.shared.didFinish = { error in
                VideoPreloadManager.shared.didFinish = nil
                let newList = object.getVideoUrls()
                VideoPreloadManager.shared.set(waiting: newList)
                self._viewStoryAt(index: indexPath.row, heroId: object.id)
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 90, height: StoryUserCell.height)
    }
    
}

extension HomeStoryViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let mediaType = info[.mediaType] as? String {
                if mediaType == "public.image" {
                    if let image = info[.editedImage] as? UIImage {
                        self._requestUploadProfileImage(image)
                    }
                } else if mediaType == "public.movie" {
                    if let videoURL = info[.mediaURL] as? URL {
                        let asset = AVURLAsset(url: videoURL)
                        let durationInSeconds = CMTimeGetSeconds(asset.duration) * 1000
                        print("Video duration: \(durationInSeconds) seconds")
                        self.params["duration"] = String(format: "%.4f", durationInSeconds)
                        self.params["thumbnail"] = kEmptyString
                        self._requestUploadProfileImage(videoUrl: videoURL)
                    }
                }
            }
        }
    }
    
    func getThumbnailImage(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating video thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

}

