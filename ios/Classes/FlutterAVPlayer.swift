import AVKit
import Flutter
import Foundation
import MediaPlayer

class FlutterAVPlayer: NSObject, FlutterPlatformView,
    AVPictureInPictureControllerDelegate
{
    private var _flutterAVPlayerViewController: AVPlayerViewController
    var pipController: AVPictureInPictureController!
    var playerLayer: AVPlayerLayer!

    init(
        frame: CGRect,
        viewIdentifier: CLongLong,
        arguments: [String: Any],
        binaryMessenger: FlutterBinaryMessenger
    ) {
        _flutterAVPlayerViewController = AVPlayerViewController()
        _flutterAVPlayerViewController.viewDidLoad()

        if let urlString = arguments["url"] {
            let item = AVPlayerItem(url: URL(string: urlString as! String)!)
            _flutterAVPlayerViewController.player = AVPlayer(playerItem: item)
        } else if let filePath = arguments["file"] {
            let appDelegate =
                UIApplication.shared.delegate as! FlutterAppDelegate
            let vc =
                appDelegate.window.rootViewController as! FlutterViewController
            let lookUpKey = vc.lookupKey(forAsset: filePath as! String)
            if let path = Bundle.main.path(forResource: lookUpKey, ofType: nil)
            {
                let item = AVPlayerItem(url: URL(fileURLWithPath: path))
                _flutterAVPlayerViewController.player = AVPlayer(
                    playerItem: item)
            } else {
                let item = AVPlayerItem(
                    url: URL(fileURLWithPath: filePath as! String))
                _flutterAVPlayerViewController.player = AVPlayer(
                    playerItem: item)

            }
        }

       do {
           let audioSession = AVAudioSession.sharedInstance()
           try audioSession.setCategory(.playback)
           try audioSession.setMode(.moviePlayback)
           try audioSession.setActive(true)
       } catch let e {
           print(e.localizedDescription)
       }

       playerLayer = AVPlayerLayer(player: _flutterAVPlayerViewController.player)

       pipController = AVPictureInPictureController(
           playerLayer: playerLayer)

       if #available(iOS 14.2, *) {
           if pipController != nil {
               pipController
                   .canStartPictureInPictureAutomaticallyFromInline = true
           }
       }

        _flutterAVPlayerViewController.player!.play()
    }

    func view() -> UIView {
        return _flutterAVPlayerViewController.view
    }
}
