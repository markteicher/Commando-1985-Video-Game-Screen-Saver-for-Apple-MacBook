import AppKit

final class GameScene {
    private var size: CGSize
    private var player: Player
    private var enemies: [Enemy] = []
    private var projectiles: [Projectile] = []
    private var explosions: [Explosion] = []
    private var terrain = Terrain()

    private var enemyTimer: TimeInterval = 0
    private var fireTimer: TimeInterval = 0
    private var grenadeTimer: TimeInterval = 0
    private var elapsed: TimeInterval = 0
    private var score = 0

    init(size: CGSize) {
        self.size = size
        self.player = Player(
            position: CGPoint(
                x: size.width * 0.5,
                y: size.height * 0.20
            )
        )
        terrain.reset(size: size)
    }

    func reset(size: CGSize) {
        self.size = size
        enemies.removeAll()
        projectiles.removeAll()
        explosions.removeAll()

        enemyTimer = 0
        fireTimer = 0
        grenadeTimer = 0
        elapsed = 0
        score = 0

        player.position = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.20
        )

        terrain.reset(size: size)
    }

    func resize(to newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }

        if newSize != size {
            size = newSize
            terrain.resize(size: newSize)
        }
    }

    func update(dt: TimeInterval) {
        guard size.width > 1, size.height > 1 else { return }

        elapsed += dt
        terrain.update(dt: dt, size: size)

        updatePlayer(dt)
        spawnEnemies(dt)
        updateEnemies(dt)
        updateProjectiles(dt)
        resolveCollisions()
        updateExplosions(dt)
    }

    private func updatePlayer(_ dt: TimeInterval) {
        let center = size.width * 0.5
        let range = min(size.width * 0.28, 250)

        player.position.x = center + CGFloat(sin(elapsed * 0.72)) * range
        player.position.y = size.height * 0.20 + CGFloat(sin(elapsed * 1.35)) * 15

        fireTimer += dt
        if fireTimer >= 0.14 {
            fireTimer = 0
            projectiles.append(
                Projectile(
                    position: CGPoint(
                        x: player.position.x,
                        y: player.position.y + 20
                    ),
                    velocity: CGVector(dx: 0, dy: 520),
                    type: .playerBullet
                )
            )
        }

        grenadeTimer += dt
        if grenadeTimer >= 3.1 {
            grenadeTimer = 0
            projectiles.append(
                Projectile(
                    position: CGPoint(
                        x: player.position.x,
                        y: player.position.y + 10
                    ),
                    velocity: CGVector(
                        dx: CGFloat.random(in: -55...55),
                        dy: 290
                    ),
                    type: .grenade
                )
            )
        }
    }

    private func spawnEnemies(_ dt: TimeInterval) {
        enemyTimer += dt
        guard enemyTimer >= 0.55 else { return }

        enemyTimer = 0

        let margin: CGFloat = 36
        let right = max(margin, size.width - margin)

        enemies.append(
            Enemy(
                position: CGPoint(
                    x: CGFloat.random(in: margin...right),
                    y: size.height + 28
                )
            )
        )
    }

    private func updateEnemies(_ dt: TimeInterval) {
        for index in enemies.indices {
            enemies[index].update(
                dt: dt,
                playerPosition: player.position
            )

            if Double.random(in: 0...1) < dt * 0.48 {
                let dx = player.position.x - enemies[index].position.x
                let dy = player.position.y - enemies[index].position.y
                let length = max(1, sqrt(dx * dx + dy * dy))
                let speed: CGFloat = 215

                projectiles.append(
                    Projectile(
                        position: enemies[index].position,
                        velocity: CGVector(
                            dx: dx / length * speed,
                            dy: dy / length * speed
                        ),
                        type: .enemyBullet
                    )
                )
            }
        }

        enemies.removeAll {
            $0.position.y < -60 ||
            $0.position.x < -80 ||
            $0.position.x > size.width + 80
        }
    }

    private func updateProjectiles(_ dt: TimeInterval) {
        for index in projectiles.indices {
            projectiles[index].update(dt: dt)
        }

        let grenadePoints = projectiles
            .filter { $0.type == .grenade && $0.age >= 0.9 }
            .map { $0.position }

        for point in grenadePoints {
            explosions.append(
                Explosion(
                    position: point,
                    maximumRadius: 48
                )
            )
        }

        projectiles.removeAll {
            ($0.type == .grenade && $0.age >= 0.9) ||
            $0.position.y > size.height + 100 ||
            $0.position.y < -100 ||
            $0.position.x < -100 ||
            $0.position.x > size.width + 100
        }
    }

    private func resolveCollisions() {
        var enemyHits = Set<Int>()
        var projectileHits = Set<Int>()

        for projectileIndex in projectiles.indices
        where projectiles[projectileIndex].type == .playerBullet {

            for enemyIndex in enemies.indices
            where !enemyHits.contains(enemyIndex) {

                let dx =
                    projectiles[projectileIndex].position.x -
                    enemies[enemyIndex].position.x

                let dy =
                    projectiles[projectileIndex].position.y -
                    enemies[enemyIndex].position.y

                if sqrt(dx * dx + dy * dy) < 16 {
                    enemyHits.insert(enemyIndex)
                    projectileHits.insert(projectileIndex)

                    explosions.append(
                        Explosion(
                            position: enemies[enemyIndex].position,
                            maximumRadius: 26
                        )
                    )

                    score += 100
                    break
                }
            }
        }

        for explosion in explosions where explosion.age < 0.15 {
            for enemyIndex in enemies.indices
            where !enemyHits.contains(enemyIndex) {

                let dx =
                    explosion.position.x -
                    enemies[enemyIndex].position.x

                let dy =
                    explosion.position.y -
                    enemies[enemyIndex].position.y

                if sqrt(dx * dx + dy * dy) < explosion.maximumRadius {
                    enemyHits.insert(enemyIndex)
                    score += 100
                }
            }
        }

        for index in enemyHits.sorted(by: >) {
            if index < enemies.count {
                enemies.remove(at: index)
            }
        }

        for index in projectileHits.sorted(by: >) {
            if index < projectiles.count {
                projectiles.remove(at: index)
            }
        }

        projectiles.removeAll { projectile in
            guard projectile.type == .enemyBullet else {
                return false
            }

            let dx = projectile.position.x - player.position.x
            let dy = projectile.position.y - player.position.y
            let hit = sqrt(dx * dx + dy * dy) < 13

            if hit {
                explosions.append(
                    Explosion(
                        position: player.position,
                        maximumRadius: 34
                    )
                )
            }

            return hit
        }
    }

    private func updateExplosions(_ dt: TimeInterval) {
        for index in explosions.indices {
            explosions[index].update(dt: dt)
        }

        explosions.removeAll { $0.isFinished }
    }

    func draw(in context: CGContext, bounds: CGRect) {
        context.saveGState()
        context.setShouldAntialias(false)

        terrain.draw(in: context, bounds: bounds)

        for enemy in enemies {
            enemy.draw(in: context)
        }

        for projectile in projectiles {
            projectile.draw(in: context)
        }

        player.draw(in: context)

        for explosion in explosions {
            explosion.draw(in: context)
        }

        drawHUD(in: context)
        context.restoreGState()
    }

    private func drawHUD(in context: CGContext) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(
            cgContext: context,
            flipped: false
        )

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(
                ofSize: 15,
                weight: .bold
            ),
            .foregroundColor: NSColor.white
        ]

        let text = String(
            format: "1UP  %06d       HIGH SCORE  100000",
            score
        )

        text.draw(
            at: CGPoint(
                x: 18,
                y: max(8, size.height - 27)
            ),
            withAttributes: attributes
        )

        NSGraphicsContext.restoreGraphicsState()
    }
}
