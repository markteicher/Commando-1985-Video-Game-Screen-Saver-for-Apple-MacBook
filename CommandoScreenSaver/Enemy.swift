import AppKit

struct Enemy {
    var position: CGPoint
    private var phase: Double
    private var speed: CGFloat

    init(position: CGPoint) {
        self.position = position
        self.phase = Double.random(in: 0...(Double.pi * 2.0))
        self.speed = CGFloat.random(in: 58...92)
    }

    mutating func update(dt: TimeInterval, playerPosition: CGPoint) {
        phase += dt * 2.1
        position.y -= CGFloat(dt) * speed
        position.x += CGFloat(sin(phase)) * CGFloat(dt) * 32
        position.x += (playerPosition.x - position.x) * CGFloat(dt) * 0.045
    }

    func draw(in c: CGContext) {
        c.saveGState()
        c.translateBy(x: position.x, y: position.y)

        Pixel.fill(c, x: -7, y: -13, w: 5, h: 8, color: .darkGray)
        Pixel.fill(c, x: 2, y: -13, w: 5, h: 8, color: .darkGray)

        Pixel.fill(
            c, x: -9, y: -5, w: 18, h: 15,
            color: NSColor(calibratedRed: 0.42, green: 0.39, blue: 0.17, alpha: 1)
        )

        Pixel.fill(
            c, x: -5, y: 10, w: 10, h: 8,
            color: NSColor(calibratedRed: 0.78, green: 0.57, blue: 0.36, alpha: 1)
        )

        Pixel.fill(
            c, x: -6, y: 15, w: 12, h: 5,
            color: NSColor(calibratedRed: 0.20, green: 0.24, blue: 0.09, alpha: 1)
        )

        c.restoreGState()
    }
}
