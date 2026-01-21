import UIKit
import Lightbox
import ObjectMapper
import AVKit

class OwnStoryCell: UITableViewCell {
    
    @IBOutlet weak var _sentBtnView: UIVisualEffectView!
    @IBOutlet weak var _sentTime: UILabel!
    @IBOutlet weak var _storyImage: UIImageView!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet weak var _venueLogo: UIImageView!
    @IBOutlet weak var _venueTitle: UILabel!
    @IBOutlet weak var _storyView: UIView!
    @IBOutlet weak var _storyUnavailble: UILabel!
    private var messageModel: MessageModel?
    private var venueId: String = kEmptyString
    private var _story: VenueDetailModel?
    @IBOutlet weak var _replyByName: CustomLabel!
    
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
        guard let _msg = message else { return }
        messageModel = _msg
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .white
        }
        else if _msg.receivers.contains(Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString : APPSESSION.userDetail?.id ?? kEmptyString) {
            _statusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _statusImage.tintColor = .white
        }
        else {
            _statusImage.image = #imageLiteral(resourceName: "icon_sending")
            _statusImage.tintColor = .white
            _sentTime.text = "sending...".localized()
        }
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _sentTime.text = date
        
        guard let model = Mapper<VenueDetailModel>().map(JSONString: _msg.msg), let story = model.storie.first else { return }
        _story = model
        
        let timdate = Utils.stringToDate(story.expiryDate, format: kStanderdDate) ?? Date()
        let hoursExceed = Calendar.current.dateComponents([.hour], from: timdate, to: Date())
        if hoursExceed.hour ?? 0 > 24 {
            _storyUnavailble.isHidden = false
            _storyView.isHidden = true
            _sentBtnView.isHidden = true
        } else {
            if Utils.stringIsNullOrEmpty(model.id) && Utils.stringIsNullOrEmpty(story.expiryDate) {
                _storyUnavailble.isHidden = false
                _storyView.isHidden = true
                _sentBtnView.isHidden = true
            } else {
                _storyUnavailble.isHidden = true
                _storyView.isHidden = false
                
                if story.mediaType == "video" {
                    _storyImage.image = generateThumbnail(for: story.mediaUrl )
                }else {
                    _storyImage.loadWebImage(story.mediaUrl)
                }
                _venueLogo.loadWebImage(model.logo)
                _venueTitle.text = model.name
                venueId = model.id
            }
        }
        
        
        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByName.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
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
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
    
}
