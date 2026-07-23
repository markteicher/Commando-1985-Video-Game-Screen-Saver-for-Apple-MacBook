import AppKit

enum ProjectileType { case playerBullet, enemyBullet, grenade }

struct Projectile {
    var position: CGPoint
    var velocity: CGVector
    let type: ProjectileType
    var age: TimeInterval = 0

    mutating func update(dt: TimeInterval) {
        age += dt
        position.x += velocity.dx * CGFloat(dt)
        position.y += velocity.dy * CGFloat(dt)
        if type == .grenade { velocity.dy -= 315 * CGFloat(dt) }
    }

    func draw(in c: CGContext) {
        switch type {
        case .playerBullet:
            Pixel.fill(c, x: position.x-2, y: position.y-4, w: 4, h: 8, color: .white)
        case .enemyBullet:
            Pixel.fill(c, x: position.x-2, y: position.y-2, w: 4, h: 4,
                       color: NSColor(calibratedRed: 1, green: 0.72, blue: 0.12, alpha: 1))
        case .grenade:
            Pixel.fill(c, x: position.x-4, y: position.y-4, w: 8, h: 8,
                       color: NSColor(calibratedRed: 0.12, green: 0.25, blue: 0.12, alpha: 1))
        }
    }
}
