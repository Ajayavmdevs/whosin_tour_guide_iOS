import UIKit
import PlayerKit
import CocoaLumberjack

class OwnAudioChatCell: UITableViewCell {

    @IBOutlet weak var _audioDuration: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _durationSlider: UISlider!
    @IBOutlet weak var _playButton: UIButton!
    @IBOutlet private weak var _statusImage: UIImageView!
    @IBOutlet weak var _replyByName: CustomLabel!
    
    private var messageModel: MessageModel?
    private lazy var audioPlayer: AppMediaPlayer = { AppMediaPlayer() }()
    private var duration: String = "-- : --"
    
    private var durations: [String: Any]?
    private var isPlayingBeforeSkipping = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        resetPlayer()
        if audioPlayer.playing {
            audioPlayer.pause()
        }
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
        setAudioPlayer()
        audioPlayer.delegate = self
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _timeLabel.text = date
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayerEvent(_:)), name: kAudioPlayerEventNotification, object: nil)
        
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _statusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _statusImage.tintColor = .white
        }
        else if _msg.receivers.contains(Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString :APPSESSION.userDetail?.id ?? "") {
            _statusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _statusImage.tintColor = .white
        }
        else {
            _statusImage.image = #imageLiteral(resourceName: "icon_sending")
            _statusImage.tintColor = .white
            _timeLabel.text = "sending...".localized()
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

extension OwnAudioChatCell: PlayerDelegate {
    
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
