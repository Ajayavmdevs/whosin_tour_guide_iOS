//
//  ImageSelectBottomSheet.swift
//  Whosin
//
//  Created by Samir Makadia on 17/10/24.
//

import UIKit
import AVFoundation

class ImageSelectBottomSheet: ChildViewController {

    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: ImageSelectCell.self)
    private let _imagePicker = UIImagePickerController()
    public var galleryImages: [String] = []
    public var venueId: String = kEmptyString
    public var callback: ((_ images: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       _setupCollectionView()
    }
    
    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 3,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0),
                              spacing: CGSize(width: 5, height: 5),
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        if venueId.isEmpty {
            _loadData()
        } else {
            _requestGetVenueMedia(venueId)
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestGetVenueMedia(_ venueId: String) {
        showHUD()
        WhosinServices.getVenueMedia(id: venueId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.galleryImages = data
            self._loadData()
        }
    }
    
    private func _requestUploadImageOrVideo(_ image: UIImage? = nil, videoUrl: URL? = nil) {
        showHUD()
        if let image = image {
            WhosinServices.uploadFile(fileUrl: getImageUrl(image: image)) { [weak self] model, error in
                guard let self = self else { return }
                self.hideHUD(error: error)
                guard let photoUrl = model?.data else { return }
                dismiss(animated: true) {
                    self.callback?(photoUrl)
                }
            }
        } else if let videoUrl = videoUrl {
            getVideo(videoUrl) { localUrl in
                WhosinServices.uploadFile(fileUrl: localUrl ?? videoUrl) { [weak self] model, error in
                    guard let self = self else { return }
                    self.hideHUD(error: error)
                    guard let videoUrl = model?.data else { return }
                    dismiss(animated: true) {
                        self.callback?(videoUrl)
                    }
                }
            }
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
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        galleryImages.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: ImageSelectCell.self,
                kCellHeightKey: ImageSelectCell.height
            ])
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: ImageSelectCell.self), kCellNibNameKey: String(describing: ImageSelectCell.self), kCellClassKey: ImageSelectCell.self, kCellHeightKey: ImageSelectCell.height]]
    }
    
    @IBAction func _handleAddImagesEvent(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            _imagePicker.delegate = self
            _imagePicker.sourceType = .savedPhotosAlbum
            _imagePicker.mediaTypes = ["public.image", "public.movie"]
            _imagePicker.allowsEditing = true
            present(_imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }

}

extension ImageSelectBottomSheet: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ImageSelectCell, let object = cellDict?[kCellObjectDataKey] as? String {
            if object.hasSuffix(".mp4") {
                cell._image.image = Utils.generateThumbnail(for: object)
                cell._playIcon.isHidden = false
            } else {
                cell.setupData(object)
                cell._playIcon.isHidden = true
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
        dismiss(animated: true) {
            self.callback?(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 3
        let padding: CGFloat = 5 * (numberOfColumns + 1)
        let availableWidth = kScreenWidth - padding
        let cellWidth = availableWidth / numberOfColumns
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}

// --------------------------------------
// MARK: ImagePickerController Delegate, NavigationController Delegate
// --------------------------------------

extension ImageSelectBottomSheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        _imagePicker.dismiss(animated: true) {
            if let mediaType = info[.mediaType] as? String {
                if mediaType == "public.image" {
                    if let image = info[.editedImage] as? UIImage {
                        self._requestUploadImageOrVideo(image)
                    }
                } else if mediaType == "public.movie" {
                    if let videoURL = info[.mediaURL] as? URL {
                        let asset = AVURLAsset(url: videoURL)
                        let durationInSeconds = CMTimeGetSeconds(asset.duration) * 1000
                        print("Video duration: \(durationInSeconds) seconds")
                        self._requestUploadImageOrVideo(videoUrl: videoURL)
                    }
                }
            }
        }
    }
}
