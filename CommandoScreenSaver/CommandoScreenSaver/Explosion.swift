import AppKit

struct Explosion {
    let position: CGPoint
    let maximumRadius: CGFloat
    var age: TimeInterval = 0
    var isFinished: Bool { age > 0.48 }

    mutating func update(dt: TimeInterval) { age += dt }

    func draw(in c: CGContext) {
        let t = min(1, age / 0.48)
        let r = max(4, maximumRadius * CGFloat(t))
        c.setFillColor(NSColor(calibratedRed: 1, green: 0.72, blue: 0.12, alpha: max(0, 1-t)).cgColor)
        c.fill(CGRect(x: position.x-r, y: position.y-r, width: r*2, height: r*2))
        let inner = r * 0.48
        c.setFillColor(NSColor(calibratedRed: 1, green: 0.95, blue: 0.62, alpha: max(0, 1-t)).cgColor)
        c.fill(CGRect(x: position.x-inner, y: position.y-inner, width: inner*2, height: inner*2))
    }
}
