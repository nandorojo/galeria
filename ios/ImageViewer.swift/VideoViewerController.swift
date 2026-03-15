import UIKit
import AVKit
import AVFoundation

/// A view controller that plays a video fullscreen inside the image viewer page controller.
/// Mirrors the structure of `ImageViewerController` but uses AVPlayerViewController for playback.
class VideoViewerController: UIViewController {

    // MARK: - Public properties

    var index: Int
    let videoURL: URL
    let placeholder: UIImage?

    /// The thumbnail/poster image view used for shared element transitions.
    /// Sits behind the player and is visible before playback starts.
    private(set) var thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - Private properties

    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?

    // MARK: - Init

    init(index: Int, videoURL: URL, placeholder: UIImage?) {
        self.index = index
        self.videoURL = videoURL
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .clear
        self.view = view

        // Thumbnail sits behind everything — used for transition matching
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(thumbnailImageView)
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: view.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show poster / placeholder right away
        if let placeholder = placeholder {
            thumbnailImageView.image = placeholder
        }

        setupPlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pause()
    }

    // MARK: - Player setup

    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.player = avPlayer

        let pvc = AVPlayerViewController()
        pvc.player = avPlayer
        pvc.showsPlaybackControls = true
        // Use a transparent background so our black background view shows through
        pvc.view.backgroundColor = .clear

        addChild(pvc)

        pvc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pvc.view)
        NSLayoutConstraint.activate([
            pvc.view.topAnchor.constraint(equalTo: view.topAnchor),
            pvc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pvc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pvc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        pvc.didMove(toParent: self)
        self.playerViewController = pvc

        // Loop playback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }

    // MARK: - Playback control

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
    }
}
