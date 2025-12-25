import UIKit
import Flutter
import AVFoundation
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // 1. Audio Player Components
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    // Channel Name must match Dart & Android
    let CHANNEL = "com.islamic_app/radio"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let radioChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        // 2. Setup Audio Session (Crucial for Background Playback)
        setupAudioSession()
        
        // 3. Setup Remote Command Center (Lock Screen Buttons)
        setupRemoteTransportControls()
        
        // 4. Handle Flutter Calls
        radioChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            let args = call.arguments as? [String: Any]
            
            switch call.method {
            case "play":
                if let url = args?["url"] as? String,
                   let title = args?["title"] as? String,
                   let desc = args?["desc"] as? String {
                    self.playAudio(url: url, title: title, desc: desc)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                }
                
            case "pause":
                self.player?.pause()
                self.updateNowPlaying(isPaused: true)
                result(nil)
                
            case "resume":
                self.player?.play()
                self.updateNowPlaying(isPaused: false)
                result(nil)
                
            case "stop":
                self.player?.pause()
                self.player = nil
                self.updateNowPlaying(isPaused: true) // Or clear info
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Audio Logic
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }
    }
    
    private func playAudio(url: String, title: String, desc: String) {
        guard let mediaUrl = URL(string: url) else { return }
        
        playerItem = AVPlayerItem(url: mediaUrl)
        player = AVPlayer(playerItem: playerItem)
        
        player?.play()
        
        // Update Metadata immediately
        setupNowPlayingInfo(title: title, desc: desc)
    }
    
    // MARK: - Lock Screen Info (MPNowPlayingInfoCenter)
    
    var currentTitle = ""
    var currentDesc = ""
    
    private func setupNowPlayingInfo(title: String, desc: String) {
        currentTitle = title
        currentDesc = desc
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = desc
        
        // Set a placeholder image if you have one in Assets.xcassets named "AppIcon"
        if let image = UIImage(named: "AppIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        
        // This is important for "Live" streams or duration
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlaying(isPaused: Bool) {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPaused ? 0.0 : 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Lock Screen Controls (Play/Pause Buttons)
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player?.rate == 0.0 {
                self.player?.play()
                self.updateNowPlaying(isPaused: false)
                return .success
            }
            return .commandFailed
        }
        
        // Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player?.rate == 1.0 {
                self.player?.pause()
                self.updateNowPlaying(isPaused: true)
                return .success
            }
            return .commandFailed
        }
        
        // Stop Command
        commandCenter.stopCommand.addTarget { [unowned self] event in
            self.player?.pause()
            self.player = nil
            return .success
        }
    }
}