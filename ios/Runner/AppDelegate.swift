import UIKit
import Flutter
import AVFoundation
import MediaPlayer
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // 1. Audio Player Components
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    // 2. Flutter Channel (needs to be accessible from control center handlers)
    var radioChannel: FlutterMethodChannel?
    
    // Channel Name must match Dart & Android
    let CHANNEL = "com.islamic_app/radio"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 🗺️ Initialize Google Maps
        GMSServices.provideAPIKey("AIzaSyCZ4hpeRm89E-8lLsOPmNvLoIoNpX1PeZs")
        
        // 1. Setup Flutter Controller & Channel
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        radioChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        // 2. Setup Audio Session (Crucial for Background Playback)
        setupAudioSession()
        setupAudioObservers()
        
        // 3. Setup Remote Command Center (Lock Screen Buttons)
        setupRemoteTransportControls()
        
        // 4. Handle Flutter Calls
        radioChannel!.setMethodCallHandler({ [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
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
                self.updateNowPlaying(isPaused: true)
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
            // Configure audio session for background playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ [AppDelegate] Audio Session Active")
        } catch {
            print("❌ [AppDelegate] Failed to set audio session: \(error)")
        }
    }
    
    private func setupAudioObservers() {
        // Handle interruptions (e.g. Phone Calls)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        
        // Handle route changes (e.g. unplugging headphones)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began (e.g. Phone call incoming) -> Pause
            print("⚠️ [AppDelegate] Interruption Began")
            player?.pause()
            updateNowPlaying(isPaused: true)
            
        case .ended:
            // Interruption ended -> Resume if options say so
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    print("▶️ [AppDelegate] Interruption Ended - Resuming")
                    player?.play()
                    updateNowPlaying(isPaused: false)
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // If headphones are unplugged, pause music
        if reason == .oldDeviceUnavailable {
            if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs {
                    if output.portType == .headphones || output.portType == .bluetoothA2DP {
                        print("⏸️ [AppDelegate] Headphones unplugged - Pausing")
                        player?.pause()
                        updateNowPlaying(isPaused: true)
                        return
                    }
                }
            }
        }
    }
    
    private func playAudio(url: String, title: String, desc: String) {
        guard let mediaUrl = URL(string: url) else {
            print("❌ [AppDelegate] Invalid URL: \(url)")
            return
        }
        
        // Reset player item
        let asset = AVAsset(url: mediaUrl)
        playerItem = AVPlayerItem(asset: asset)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        player?.automaticallyWaitsToMinimizeStalling = true
        player?.play()
        
        // Log
        print("▶️ [AppDelegate] Playing: \(title)")
        
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
        
        // Set a placeholder image if available
        if let image = UIImage(named: "AppIcon") ?? UIImage(named: "LaunchImage") {
             nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true // Since it's radio mostly
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
        
        // Clear previous targets to avoid duplication if re-initialized
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        
        // Play Command
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.player?.play()
            self.updateNowPlaying(isPaused: false)
            
            // 🔔 Notify Flutter about Play
            DispatchQueue.main.async {
                self.radioChannel?.invokeMethod("onPlay", arguments: nil)
            }
            
            return .success
        }
        
        // Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.player?.pause()
            self.updateNowPlaying(isPaused: true)
            
            // 🔔 Notify Flutter about Pause
            DispatchQueue.main.async {
                self.radioChannel?.invokeMethod("onPause", arguments: nil)
            }
            
            return .success
        }
        
        // Toggle Play/Pause (Headphones button)
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if self.player?.rate == 0.0 {
                self.player?.play()
                self.updateNowPlaying(isPaused: false)
                
                // 🔔 Notify Flutter about Play
                DispatchQueue.main.async {
                    self.radioChannel?.invokeMethod("onPlay", arguments: nil)
                }
            } else {
                self.player?.pause()
                self.updateNowPlaying(isPaused: true)
                
                // 🔔 Notify Flutter about Pause
                DispatchQueue.main.async {
                    self.radioChannel?.invokeMethod("onPause", arguments: nil)
                }
            }
            return .success
        }
        
        // Stop Command
        commandCenter.stopCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.player?.pause()
            self.player = nil // Properly release
            self.updateNowPlaying(isPaused: true)
            
            // 🔔 Notify Flutter about Stop
            DispatchQueue.main.async {
                self.radioChannel?.invokeMethod("onStop", arguments: nil)
            }
            
            return .success
        }
    }
}