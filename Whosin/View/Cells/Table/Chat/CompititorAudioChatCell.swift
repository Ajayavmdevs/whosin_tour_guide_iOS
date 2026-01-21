import UIKit
import PlayerKit

class CompititorAudioChatCell: UITableViewCell {

    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _durationTime: UILabel!
    @IBOutlet weak var _durationSlider: UISlider!
    @IBOutlet weak var _senderNameLabel: UILabel!
    @IBOutlet weak var _playButton: UIButton!
    private var messageModel: MessageModel?
    private lazy var audioPlayer: AppMediaPlayer = { AppMediaPlayer() }()
    private var player: Player? = nil
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayerEvent(_:)), name: kAudioPlayerEventNotification, object: nil)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        _senderNameLabel.isUserInteractionEnabled = true
        _senderNameLabel.addGestureRecognizer(tapGesture2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func getLocalPath() -> String {
        var _audioUrl = messageModel?.msg
        if let _audioName = _audioUrl?.toURL?.lastPathComponent {
            let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(_audioName)
            if Utils.isFileExist(atPath: fileUrl.path) {
                return fileUrl.absoluteString
            }
        }
        return kEmptyString
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setup(_ message: MessageModel?) {
        messageModel = message
        setAudioPlayer()
        audioPlayer.delegate = self
        
        let localPath = getLocalPath()
        if(localPath.isEmpty) {
            if let url = URL(string: message?.msg ?? kEmptyString) {
                Utils.downloadAudioFile(from: url) { fileUrl, error in
                    if error != nil { return }
                    guard let localPath = fileUrl?.absoluteString else { return }
                    self.messageModel?.msg = localPath
                }
            }
        } else {
            messageModel?.msg = localPath
        }
        
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _timeLabel.text = date
        _senderNameLabel.text = message?.authorName
        
        if let _duration = message?.audioDuration {
            if _duration.isEmpty {
                Utils.getAudioDuration(filePath: messageModel?.msg ?? kEmptyString) { data in
                    guard let duration = data else { return }
                    self.messageModel?.audioDuration = Utils.getStringInMinuteAndSecond(durationInSecond: Int(duration))
                    self._durationTime.text = self.messageModel?.audioDuration
                }
            }
            _durationTime.text = _duration
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
        _durationTime.text = messageModel?.audioDuration
        setAudioPlayer()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handlePlayEvent(_ sender: UIButton) {
//        if audioPlayer == nil {
//            audioPlayer = AppMediaPlayer()
//            audioPlayer?.delegate = self
//            audioPlayer?.setUrl(messageModel?.msg)
//        }
//        
//        
//        guard let audioPlayer = audioPlayer else { return }
        if audioPlayer.playing {
            audioPlayer.pause()
        } else {
            NotificationCenter.default.post(name: kAudioPlayerEventNotification, object: nil)
            audioPlayer.play()
        }
        _playButton.isSelected = !_playButton.isSelected
    }
    
    @objc func handleAudioPlayerEvent(_ notification: Notification) {
//        guard let audioPlayer = audioPlayer else { return }
        if audioPlayer.playing {
            resetPlayer()
        }
    }
    
    @objc func userTapped(sender: UITapGestureRecognizer) {
    }
    
    @IBAction func _handleSliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        let currentTime = TimeInterval(value) * (audioPlayer.duration)
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

extension CompititorAudioChatCell: PlayerDelegate {
    
    func resetPlayerView() {
    }
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
    }

    func playerDidUpdatePlaying(player: Player) {
         guard player.duration > 0 else{ return }
    }

    func playerDidUpdateTime(player: Player) {
        print("playerDidUpdateTime \(player.time)")
        self.player = player
        guard player.duration > 0 else { return }
        guard audioPlayer.playing else { return }
        let progress = player.time / player.duration
        _durationTime.text = Utils.getStringInMinuteAndSecond(durationInSecond: Int(player.time))
        _durationSlider.setValue(Float(progress), animated: true)
        if player.time >= player.duration {
            audioPlayer.reset()
            resetPlayer()
        }
    }

    func playerDidUpdateBufferedTime(player: Player) {
        
    }
}
