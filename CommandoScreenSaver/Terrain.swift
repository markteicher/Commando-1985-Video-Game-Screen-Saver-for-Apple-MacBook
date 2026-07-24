import AppKit

private struct TerrainFeature {
    enum Kind {
        case tree
        case bush
        case sandbag
        case rock
        case water
    }

    var kind: Kind
    var position: CGPoint
    var size: CGFloat
}

final class Terrain {
    private var features: [TerrainFeature] = []
    private var spawnDistance: CGFloat = 0
    private let scrollSpeed: CGFloat = 72

    func reset(size: CGSize) {
        features.removeAll()
        spawnDistance = 0

        guard size.width > 1, size.height > 1 else { return }

        let count = max(24, Int(size.height / 28))
        for _ in 0..<count {
            features.append(
                randomFeature(
                    size: size,
                    y: CGFloat.random(in: 0...size.height)
                )
            )
        }
    }

    func resize(size: CGSize) {
        features.removeAll { $0.position.x > size.width + 80 }
    }

    func update(dt: TimeInterval, size: CGSize) {
        let dy = scrollSpeed * CGFloat(dt)
        spawnDistance += dy

        for index in features.indices {
            features[index].position.y -= dy
        }

        features.removeAll { $0.position.y < -80 }

        while spawnDistance >= 32 {
            spawnDistance -= 32

            if Bool.random(), size.width > 40 {
                features.append(
                    randomFeature(size: size, y: size.height + 55)
                )
            }
        }
    }

    private func randomFeature(size: CGSize, y: CGFloat) -> TerrainFeature {
        let kinds: [TerrainFeature.Kind] = [
            .tree, .tree, .tree, .bush, .bush, .sandbag, .rock, .water
        ]

        let minX: CGFloat = 20
        let maxX = max(minX, size.width - 20)

        return TerrainFeature(
            kind: kinds.randomElement() ?? .tree,
            position: CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: y
            ),
            size: CGFloat.random(in: 13...25)
        )
    }

    func draw(in c: CGContext, bounds: CGRect) {
        c.setFillColor(
            NSColor(calibratedRed: 0.48, green: 0.45, blue: 0.21, alpha: 1).cgColor
        )
        c.fill(bounds)

        c.setFillColor(
            NSColor(calibratedRed: 0.57, green: 0.50, blue: 0.27, alpha: 1).cgColor
        )
        c.fill(
            CGRect(
                x: bounds.width * 0.25,
                y: 0,
                width: bounds.width * 0.50,
                height: bounds.height
            )
        )

        for feature in features {
            draw(feature, in: c)
        }
    }

    private func draw(_ f: TerrainFeature, in c: CGContext) {
        let x = f.position.x
        let y = f.position.y
        let s = f.size

        switch f.kind {
        case .tree:
            Pixel.fill(
                c, x: x - 3, y: y - s, w: 6, h: s,
                color: NSColor(calibratedRed: 0.28, green: 0.17, blue: 0.08, alpha: 1)
            )
            Pixel.fill(
                c, x: x - s * 0.55, y: y - s * 0.10, w: s * 1.10, h: s * 0.75,
                color: NSColor(calibratedRed: 0.10, green: 0.31, blue: 0.10, alpha: 1)
            )
            Pixel.fill(
                c, x: x - s * 0.38, y: y + s * 0.25, w: s * 0.76, h: s * 0.55,
                color: NSColor(calibratedRed: 0.16, green: 0.40, blue: 0.12, alpha: 1)
            )

        case .bush:
            Pixel.fill(
                c, x: x - s * 0.55, y: y - s * 0.35, w: s * 1.10, h: s * 0.70,
                color: NSColor(calibratedRed: 0.13, green: 0.36, blue: 0.10, alpha: 1)
            )

        case .sandbag:
            for i in -1...1 {
                Pixel.fill(
                    c, x: x + CGFloat(i) * 9 - 5, y: y - 4, w: 10, h: 8,
                    color: NSColor(calibratedRed: 0.64, green: 0.55, blue: 0.30, alpha: 1)
                )
            }

        case .rock:
            Pixel.fill(
                c, x: x - s * 0.45, y: y - s * 0.30, w: s * 0.90, h: s * 0.60,
                color: NSColor(calibratedWhite: 0.33, alpha: 1)
            )

        case .water:
            Pixel.fill(
                c, x: x - s, y: y - s * 0.25, w: s * 2, h: s * 0.50,
                color: NSColor(calibratedRed: 0.12, green: 0.35, blue: 0.49, alpha: 1)
            )
        }
    }
}
