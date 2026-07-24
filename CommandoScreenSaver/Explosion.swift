import AppKit

struct Explosion {
    let position: CGPoint
    let maximumRadius: CGFloat
    var age: TimeInterval = 0

    var isFinished: Bool {
        age > 0.48
    }

    mutating func update(dt: TimeInterval) {
        age += dt
    }

    func draw(in c: CGContext) {
        let progress = min(1.0, age / 0.48)
        let radius = max(4, maximumRadius * CGFloat(progress))
        let alpha = max(0.0, 1.0 - progress)

        c.setFillColor(
            NSColor(calibratedRed: 1.0, green: 0.70, blue: 0.08, alpha: alpha).cgColor
        )
        c.fill(CGRect(
            x: position.x - radius,
            y: position.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        let inner = radius * 0.45
        c.setFillColor(
            NSColor(calibratedRed: 1.0, green: 0.95, blue: 0.62, alpha: alpha).cgColor
        )
        c.fill(CGRect(
            x: position.x - inner,
            y: position.y - inner,
            width: inner * 2,
            height: inner * 2
        ))
    }
}
