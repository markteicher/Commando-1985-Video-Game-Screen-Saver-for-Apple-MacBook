import AppKit
import ScreenSaver

@objc(CommandoScreenSaverView)
final class CommandoScreenSaverView: ScreenSaverView {
    private var game: GameScene

    override init?(frame: NSRect, isPreview: Bool) {
        self.game = GameScene(size: frame.size)
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 60.0
    }

    required init?(coder: NSCoder) {
        self.game = GameScene(size: .zero)
        super.init(coder: coder)
        self.game.resize(to: bounds.size)
        animationTimeInterval = 1.0 / 60.0
    }

    override func startAnimation() {
        super.startAnimation()
        game.reset(size: bounds.size)
    }

    override func animateOneFrame() {
        game.resize(to: bounds.size)
        game.update(dt: animationTimeInterval)
        needsDisplay = true
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        game.draw(in: context, bounds: bounds)
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
