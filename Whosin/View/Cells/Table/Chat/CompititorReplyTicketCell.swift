import UIKit
import Lightbox
import PlayerKit
import ObjectMapper
import CountdownLabel

class CompititorReplyTicketCell: UITableViewCell {
    
    @IBOutlet weak var _replyTextMsg: UILabel!
    @IBOutlet weak var _msgTime: UILabel!
    @IBOutlet weak var _senderName: UILabel!
    @IBOutlet weak var _durationTime: UILabel!
    @IBOutlet weak var _durationSlider: UISlider!
    @IBOutlet weak var _playButton: UIButton!
    @IBOutlet weak var _imgView: UIImageView!
    @IBOutlet weak var _audioView: UIView!
    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _descriptionText: CustomLabel!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _startingAtPrice: UILabel!
    @IBOutlet private weak var _gallaryView: TicketListGallaryView!
    @IBOutlet weak var _badgePrice: UILabel!
    @IBOutlet weak var _discountView: UIView!
    @IBOutlet weak var _discountText: UILabel!
    private var _ticketModel: TicketModel?

    
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
        disableSelectEffect()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayerEvent(_:)), name: kAudioPlayerEventNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _imgView.isUserInteractionEnabled = true
        _imgView.addGestureRecognizer(tapGesture)
    }

    @objc func imageTapped(sender: UITapGestureRecognizer) {
        // Handle the tap event here
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _imgView.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended{
            images.append(LightboxImage(imageURL: URL(string: messageModel?.msg ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        parentBaseController?.present(controller, animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        messageModel = _msg
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = _msg.authorName
        _msgTime.text = date
        if message?.type == MessageType.text.rawValue {
            _replyTextMsg.text = _msg.msg
            _audioView.isHidden = true
            _imgView.isHidden = true
            _replyTextMsg.isHidden = false
        } else if message?.type == MessageType.audio.rawValue {
            _audioView.isHidden = false
            _imgView.isHidden = true
            _replyTextMsg.isHidden = true
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
        } else if message?.type == MessageType.image.rawValue {
            _audioView.isHidden = true
            _imgView.isHidden = false
            _replyTextMsg.isHidden = true
            _imgView.loadWebImage(_msg.msg)
        }
        guard let model = Mapper<TicketModel>().map(JSONString: _msg.replyTo?.data ?? "") else { return }
        _ticketModel = model
        _discountText.text = "\(model.discount)%"
        _discountView.isHidden = model.discount == 0
        _titleText.text = model.title
        _descriptionText.text = model.city
        _startingAtPrice.attributedText = "\("from".localized()) \(Utils.getCurrentCurrencySymbol()) \(model.startingAmount)".withCurrencyFont(18)
        _gallaryView.setupHeader(model.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0)}))
        _badgePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.startingAmount)".withCurrencyFont(18)


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

    @objc func handleAudioPlayerEvent(_ notification: Notification) {
//        guard let audioPlayer = audioPlayer else { return }
        if audioPlayer.playing {
            resetPlayer()
        }
    }
    
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

    @IBAction func _handleEventDetail(_ sender: Any) {        
        guard let model = Mapper<TicketModel>().map(JSONString: messageModel?.replyTo?.data ?? "") else { return }
        let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        vc.ticketID = model._id
        vc.hidesBottomBarWhenPushed = true
        parentBaseController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// --------------------------------------
// MARK: PlayerDelegate
// --------------------------------------

extension CompititorReplyTicketCell: PlayerDelegate {
    
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
