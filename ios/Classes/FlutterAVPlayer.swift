import AVKit
import Flutter
import Foundation
import MediaPlayer

class FlutterAVPlayer: NSObject, FlutterPlatformView,
    AVPictureInPictureControllerDelegate
{
    private var _flutterAVPlayerViewController: AVPlayerViewController
    var pipController: AVPictureInPictureController!
    var pipPossibleObservation: NSKeyValueObservation?
    var pictureInPictureController: AVPictureInPictureController!
    var playerLayer: AVPlayerLayer!

    init(
        frame: CGRect,
        viewIdentifier: CLongLong,
        arguments: [String: Any],
        binaryMessenger: FlutterBinaryMessenger
    ) {
        _flutterAVPlayerViewController = AVPlayerViewController()
        _flutterAVPlayerViewController.viewDidLoad()

        let player = AVPlayer()
        _flutterAVPlayerViewController.player = player

        if let urlString = arguments["url"] {
            let item = AVPlayerItem(url: URL(string: urlString as! String)!)
            player.replaceCurrentItem(with: item)
        } else if let filePath = arguments["file"] {
            let appDelegate =
                UIApplication.shared.delegate as! FlutterAppDelegate
            let vc =
                appDelegate.window.rootViewController as! FlutterViewController
            let lookUpKey = vc.lookupKey(forAsset: filePath as! String)
            if let path = Bundle.main.path(forResource: lookUpKey, ofType: nil) {
                let item = AVPlayerItem(url: URL(fileURLWithPath: path))
                player.replaceCurrentItem(with: item)
            } else {
                let item = AVPlayerItem(
                    url: URL(fileURLWithPath: filePath as! String))
                player.replaceCurrentItem(with: item)
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

        playerLayer = AVPlayerLayer(player: player)

        pictureInPictureController = AVPictureInPictureController(
            playerLayer: playerLayer)

        if #available(iOS 14.2, *) {
            if pictureInPictureController != nil {
                pictureInPictureController
                    .canStartPictureInPictureAutomaticallyFromInline = true
            }
        }

        player.play()
    }

    func view() -> UIView {
        return _flutterAVPlayerViewController.view
    }
}
