import AVKit
import UIKit

/// Playback belongs to the gallery. The caller provides the thumbnail image.
class VideoViewerController: UIViewController, GalleryPage {
    let index: Int
    let transitionImageView = UIImageView()
    var zoomScrollView: UIScrollView? { nil }

    private let player: AVPlayer
    private let playerController = AVPlayerViewController()
    private var active = false
    private var resumeOnActivation: Bool?
    private var readyObservation: NSKeyValueObservation?
    private var backgroundObserver: NSObjectProtocol?

    init(index: Int, url: URL, placeholder: UIImage?) {
        self.index = index
        self.player = AVPlayer(url: url)
        super.init(nibName: nil, bundle: nil)
        transitionImageView.image = placeholder
        transitionImageView.contentMode = .scaleAspectFit
        transitionImageView.clipsToBounds = true
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.player.pause() }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(transitionImageView)
        playerController.player = player
        playerController.showsPlaybackControls = true
        playerController.allowsPictureInPicturePlayback = false
        playerController.videoGravity = .resizeAspect
        addChild(playerController)
        playerController.view.backgroundColor = .clear
        view.insertSubview(playerController.view, belowSubview: transitionImageView)
        playerController.didMove(toParent: self)
        readyObservation = playerController.observe(\.isReadyForDisplay, options: [.initial, .new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.revealPlayer() }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerController.view.frame = view.bounds
        let videoSize = player.currentItem?.presentationSize ?? .zero
        let size = videoSize == .zero ? transitionImageView.image?.size : videoSize
        if let size, size.width > 0, size.height > 0 {
            transitionImageView.frame = AVMakeRect(aspectRatio: size, insideRect: view.bounds)
        } else {
            transitionImageView.frame = view.bounds
        }
    }

    func setActive(_ active: Bool, autoPlayVideo: Bool) {
        guard self.active != active else { return }
        self.active = active
        loadViewIfNeeded()
        if active {
            revealPlayer()
            if resumeOnActivation ?? autoPlayVideo { player.play() }
            resumeOnActivation = nil
        } else {
            resumeOnActivation = player.rate > 0
            player.pause()
        }
    }

    private func revealPlayer() {
        guard active, playerController.isReadyForDisplay else { return }
        view.setNeedsLayout()
        view.bringSubviewToFront(playerController.view)
    }

    deinit {
        player.pause()
        if let backgroundObserver { NotificationCenter.default.removeObserver(backgroundObserver) }
    }
}
