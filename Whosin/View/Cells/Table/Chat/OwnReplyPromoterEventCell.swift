import UIKit
import Lightbox
import PlayerKit
import ObjectMapper
import CountdownLabel

class OwnReplyPromoterEventCell: UITableViewCell {

    @IBOutlet weak var _audioView: UIView!
    @IBOutlet weak var _replyMessage: AttributedLabel!
    @IBOutlet weak var _eventImage: UIImageView!
    @IBOutlet weak var _dateLabel: CustomLabel!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueAddress: CustomLabel!
    @IBOutlet weak var _startTime: CustomLabel!
    @IBOutlet weak var _endTime: CustomLabel!
    @IBOutlet weak var _countdownLabel: CountdownLabel!
    @IBOutlet weak var _eventExpiredLabel: CustomLabel!
    @IBOutlet weak var _confirmationText: CustomLabel!
    @IBOutlet weak var _confirmationView: UIView!
    @IBOutlet weak var _msgTime: UILabel!
    @IBOutlet weak var _msgStatusImage: UIImageView!
    @IBOutlet weak var _replyByName: CustomLabel!
    @IBOutlet weak var _imgView: UIImageView!
    private var messageModel: MessageModel?
    @IBOutlet weak var _imageHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _audioDuration: UILabel!
    @IBOutlet weak var _durationSlider: UISlider!
    @IBOutlet weak var _playButton: UIButton!
    
    private lazy var audioPlayer: AppMediaPlayer = { AppMediaPlayer() }()
    private var duration: String = "-- : --"
    
    private var durations: [String: Any]?
    private var isPlayingBeforeSkipping = false

    private var _imageUrl: String = kEmptyString

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func prepareForReuse() {
        resetPlayer()
        if audioPlayer.playing {
            audioPlayer.pause()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _imgView.isUserInteractionEnabled = true
        _imgView.addGestureRecognizer(tapGesture)

    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _imgView.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended{
            images.append(LightboxImage(imageURL: URL(string: _imageUrl)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        parentBaseController?.present(controller, animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        messageModel = _msg
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _msgTime.text = date
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _msgStatusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _msgStatusImage.tintColor = .white
        }
        else if _msg.receivers.contains(Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString : APPSESSION.userDetail?.id ?? kEmptyString) {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _msgStatusImage.tintColor = .white
        }
        else {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_sending")
            _msgStatusImage.tintColor = .white
            _msgTime.text = "sending...".localized()
        }
        if message?.type == MessageType.image.rawValue {
            _imgView.isHidden = false
            _replyMessage.isHidden = true
            _audioView.isHidden = true
            _imageHightConstraint.constant = 200
            _imageUrl = message?.msg ?? kEmptyString
            _imgView.loadWebImage(message?.msg ?? kEmptyString)
        } else if message?.type == MessageType.text.rawValue {
            _imageHightConstraint.constant = 200
            _imgView.isHidden = true
            _replyMessage.isHidden = false
            _audioView.isHidden = true
            _replyMessage.text = message?.msg
        } else if message?.type == MessageType.audio.rawValue {
            _imageHightConstraint.constant = 200
            _imgView.isHidden = true
            _replyMessage.isHidden = true
            _audioView.isHidden = false
            setAudioPlayer()
            audioPlayer.delegate = self
            NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayerEvent(_:)), name: kAudioPlayerEventNotification, object: nil)

        }
        guard let jsonString = message?.replyTo?.data else { return }
        guard let model = Mapper<PromoterEventsModel>().map(JSONString: jsonString) else { return }
        
        _eventImage.loadWebImage(model.customVenue?.image ?? kEmptyString)
        _venueName.text = model.customVenue?.name
        _venueAddress.text = model.customVenue?.address
        _venueImage.loadWebImage(model.venueType == "venue" ? (model.customVenue?.slogo ?? kEmptyString) : model.customVenue?.image ?? kEmptyString, name: model.customVenue?.name ?? kEmptyString)
        let eventdt = Utils.stringToDate(model.date, format: kFormatDate)
        _dateLabel.text  = Utils.dateToString(eventdt, format: kFormatDateMonthShort)

        _startTime.text = "\(model.startTime)"
        _endTime.text = "\(model.endTime)"
        

        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByName.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
        }
    }

    func setAudioPlayer() {
        audioPlayer.playing ? audioPlayer.pause() : audioPlayer.pause()
        var _audioUrl = messageModel?.msg
        if let _audioName = _audioUrl?.toURL?.lastPathComponent {
            let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(_audioName)
            if Utils.isFileExist(atPath: fileUrl.path) {
                _audioUrl = fileUrl.absoluteString
            }
        }
        audioPlayer.setUrl(_audioUrl)
    }
    
    func resetPlayer() {
        _playButton.isSelected = false
        _durationSlider.setValue(0.0, animated: true)
        _audioDuration.text = duration
        setAudioPlayer()
    }

    func setDuration(_ duration: String) {
        self.duration = duration
        _audioDuration.text = duration
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleOpenEventDetail(_ sender: Any) {
        guard let model = Mapper<PromoterEventsModel>().map(JSONString: messageModel?.replyTo?.data ?? "") else { return }
    }
    
    @IBAction private func _handlePlayEvent(_ sender: UIButton) {
        if audioPlayer.playing {
            audioPlayer.pause()
        } else {
            NotificationCenter.default.post(name: kAudioPlayerEventNotification, object: nil)
            audioPlayer.play()
        }
        _playButton.isSelected = !_playButton.isSelected
    }
    
    @objc func handleAudioPlayerEvent(_ notification: Notification) {
        if audioPlayer.playing {
            resetPlayer()
            audioPlayer.pause()
        }
    }
    
    @IBAction func _handleSliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        let currentTime = TimeInterval(value) * audioPlayer.duration
        audioPlayer.pause()
        audioPlayer.seek(to: currentTime)
    }

    
    @IBAction func _handleSliderTouchUp(_ sender: UISlider) {
        if isPlayingBeforeSkipping {
            audioPlayer.play()
        }
    }
    
    @IBAction func _handleSliderTouchDown(_ sender: UISlider) {
        isPlayingBeforeSkipping = audioPlayer.playing
    }

}

// --------------------------------------
// MARK: PlayerDelegate
// --------------------------------------

extension OwnReplyPromoterEventCell: PlayerDelegate {
    
    func resetPlayerView() {
        resetPlayer()
    }
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        print("previousState===>", previousState)
        guard audioPlayer.isValid else { return }
        setDuration(Utils.getStringInMinuteAndSecond(durationInSecond: Int(player.duration)))
    }

    func playerDidUpdatePlaying(player: Player) {
         guard player.duration > 0 else{ return }
        print("Duretion : ", player.duration)
        
    }

    func playerDidUpdateTime(player: Player) {
        print("playerDidUpdateTime \(player.time)")
        guard player.duration > 0 else { return }
        guard audioPlayer.playing else { return }
        
        let progress = player.time / player.duration
        _audioDuration.text = Utils.getStringInMinuteAndSecond(durationInSecond: Int(player.time))
        _durationSlider.setValue(Float(progress), animated: true)
        
        if player.time >= player.duration {
            audioPlayer.reset()
            resetPlayer()
        }
    }



    func playerDidUpdateBufferedTime(player: Player) {
        print(player)
    }
}
