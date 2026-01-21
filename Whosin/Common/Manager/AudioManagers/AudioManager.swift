import Foundation
import AVKit


final class AudioRecorderManager {

    class var shared: AudioRecorderManager {
        struct Static {
            static let instance = AudioRecorderManager()
        }
        return Static.instance
    }

    private init() { }
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession = AVAudioSession.sharedInstance()
    lazy var applicationDocumentsDirectory: URL? = {
        let url = urls(for: .documentDirectory)
        return url
    }()
    public var fileName = "recording.m4a"
 
    @discardableResult func checkAudioRecordPermission(showAlert: Bool = false, afterGrantAction: ResultClosure? = nil) -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            afterGrantAction?(true)
            return true
        case AVAudioSession.RecordPermission.denied:
            if showAlert {
                showSettingPermissionAlert(afterGrantAction: afterGrantAction)
            }
            return false
        case AVAudioSession.RecordPermission.undetermined:
            recordingSession.requestRecordPermission { granted in
                if granted { afterGrantAction?(granted) }
            }
        @unknown default:
            debugPrint("failed to record!", "@unknown default")
        }
        return false
    }
    
    func startRecording() {
        fileName = "\(Utils.randomString(length: 10))\(Date().timeIntervalSince1970).m4a"
        guard let audioFilename = applicationDocumentsDirectory?.appendingPathComponent(fileName) else { return }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            if let audioRecorder = audioRecorder {
                audioRecorder.record()
            }
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool = true) {
        if let audioRecorder = audioRecorder {
            audioRecorder.stop()
        }
        audioRecorder = nil
    }
    
    private func showSettingPermissionAlert(afterGrantAction: ResultClosure?) {
        let alertController = UIAlertController(title: "need_microphone_permissions".localized(), message: "microphone_permission_description".localized(), preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "settings".localized(), style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    debugPrint("Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .default, handler: { (a) in
            afterGrantAction?(false)
        })
        alertController.addAction(cancelAction)
        UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func isRecording() -> Bool {
        return audioRecorder?.isRecording ?? false
    }
}
