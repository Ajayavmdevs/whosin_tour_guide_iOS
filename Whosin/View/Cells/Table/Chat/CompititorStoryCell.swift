import UIKit
import Lightbox
import ObjectMapper
import AVKit

class CompititorStoryCell: UITableViewCell {
    
    @IBOutlet weak var _sentBtnView: UIVisualEffectView!
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet private weak var _stroyImage: UIImageView!
    @IBOutlet private weak var _senderName: UILabel!
    @IBOutlet weak var _venueLogo: UIImageView!
    @IBOutlet weak var _venueTitle: UILabel!
    @IBOutlet weak var _storyUnavailable: UILabel!
    @IBOutlet weak var _storyView: UIView!
    
    private var _msgModel: MessageModel?
    private var _venueModel: VenueDetailModel?
    private var _story: VenueDetailModel?
    
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
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._imageBgTap))
        self._storyView.addGestureRecognizer(gesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    func setup(_ message: MessageModel?) {
        _msgModel = message
        guard let _msg = message else { return }
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = message?.authorName
        _sentTime.text = date
        
        guard let model = Mapper<VenueDetailModel>().map(JSONString: _msg.msg), let story = model.storie.first else { return }
        _story = model
        let timdate = Utils.stringToDate(story.expiryDate, format: kStanderdDate) ?? Date()
        let hoursExceed = Calendar.current.dateComponents([.hour], from: timdate, to: Date())
        if hoursExceed.hour ?? 0 > 24 {
            _storyUnavailable.isHidden = false
            _storyView.isHidden = true
            _sentBtnView.isHidden = true
        } else {
            if Utils.stringIsNullOrEmpty(model.id) && Utils.stringIsNullOrEmpty(story.expiryDate) {
                _storyUnavailable.isHidden = false
                _storyView.isHidden = true
                _sentBtnView.isHidden = true
            } else {
                _storyUnavailable.isHidden = true
                _storyView.isHidden = false
                _sentBtnView.isHidden = false
                if story.mediaType == "video" {
                    _stroyImage.image = generateThumbnail(for: story.mediaUrl)
                } else {
                    _stroyImage.loadWebImage(story.mediaUrl)
                }
                _venueLogo.loadWebImage(model.logo)
                _venueTitle.text = model.name
                _venueModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: model.id)
            }
        }
    }
    
    func generateThumbnail(for videoURL: String) -> UIImage? {
        guard let url = URL(string: videoURL) else { return UIImage() }
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
            return thumbnailImage
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    @objc func _imageBgTap(sender : UITapGestureRecognizer) {
        guard let venue = _story else { return }
        if Utils.stringIsNullOrEmpty(venue.id) { return }
        let randomStr = Utils.randomString(length: 20)
        let _logoHeroId = venue.id + "_story_" + randomStr
        _storyView.hero.id = _logoHeroId
        _storyView.hero.modifiers = HeroAnimationModifier.stories
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = [venue]
        controller.currentIndex = 0
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = _logoHeroId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        parentViewController?.present(controller, animated: true)
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self._msgModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
}
