import ScreenSaver
import AppKit

@objc(CommandoScreenSaverView)
final class CommandoScreenSaverView: ScreenSaverView {
    private var game: GameScene!
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 60.0
        game = GameScene(size: frame.size)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0 / 60.0
        game = GameScene(size: bounds.size)
    }
    override func startAnimation() { super.startAnimation(); game.reset(size: bounds.size) }
    override func animateOneFrame() { game.resize(to: bounds.size); game.update(dt: animationTimeInterval); needsDisplay = true }
    override func draw(_ rect: NSRect) {
        guard let c = NSGraphicsContext.current?.cgContext else { return }
        game.draw(in: c, bounds: bounds)
    }
    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
