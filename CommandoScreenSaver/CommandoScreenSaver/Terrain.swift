import AppKit

struct TerrainFeature {
    enum Kind { case tree, bush, sandbag, rock, water }
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
        for _ in 0..<max(20, Int(size.height / 35)) {
            features.append(randomFeature(size: size, y: CGFloat.random(in: 0...max(1,size.height))))
        }
    }

    func resize(size: CGSize) {
        features.removeAll { $0.position.x > size.width + 80 }
    }

    func update(dt: TimeInterval, size: CGSize) {
        let dy = scrollSpeed * CGFloat(dt)
        spawnDistance += dy
        for i in features.indices { features[i].position.y -= dy }
        features.removeAll { $0.position.y < -80 }

        while spawnDistance >= 32 {
            spawnDistance -= 32
            if Bool.random() {
                features.append(randomFeature(size: size, y: size.height + 50))
            }
        }
    }

    private func randomFeature(size: CGSize, y: CGFloat) -> TerrainFeature {
        let roll = Int.random(in: 0..<10)
        let kind: TerrainFeature.Kind
        switch roll {
        case 0...3: kind = .tree
        case 4...5: kind = .bush
        case 6: kind = .sandbag
        case 7: kind = .rock
        default: kind = .water
        }
        return TerrainFeature(kind: kind,
                              position: CGPoint(x: CGFloat.random(in: 20...max(20,size.width-20)), y: y),
                              size: CGFloat.random(in: 12...25))
    }

    func draw(in c: CGContext, bounds: CGRect) {
        c.setFillColor(NSColor(calibratedRed: 0.49, green: 0.46, blue: 0.22, alpha: 1).cgColor)
        c.fill(bounds)

        // Dirt lanes
        c.setFillColor(NSColor(calibratedRed: 0.57, green: 0.50, blue: 0.27, alpha: 1).cgColor)
        c.fill(CGRect(x: bounds.width*0.25, y: 0, width: bounds.width*0.50, height: bounds.height))

        for f in features { draw(f, in: c) }
    }

    private func draw(_ f: TerrainFeature, in c: CGContext) {
        let x=f.position.x, y=f.position.y, s=f.size
        switch f.kind {
        case .tree:
            Pixel.fill(c,x:x-3,y:y-s,w:6,h:s,color:NSColor(calibratedRed:0.28,green:0.17,blue:0.08,alpha:1))
            Pixel.fill(c,x:x-s*0.55,y:y-s*0.1,w:s*1.1,h:s*0.75,color:NSColor(calibratedRed:0.10,green:0.31,blue:0.10,alpha:1))
            Pixel.fill(c,x:x-s*0.38,y:y+s*0.25,w:s*0.76,h:s*0.55,color:NSColor(calibratedRed:0.16,green:0.40,blue:0.12,alpha:1))
        case .bush:
            Pixel.fill(c,x:x-s*0.55,y:y-s*0.35,w:s*1.1,h:s*0.7,color:NSColor(calibratedRed:0.13,green:0.36,blue:0.10,alpha:1))
        case .sandbag:
            for i in -1...1 {
                Pixel.fill(c,x:x+CGFloat(i)*9-5,y:y-4,w:10,h:8,color:NSColor(calibratedRed:0.64,green:0.55,blue:0.30,alpha:1))
            }
        case .rock:
            Pixel.fill(c,x:x-s*0.45,y:y-s*0.3,w:s*0.9,h:s*0.6,color:NSColor(calibratedWhite:0.33,alpha:1))
        case .water:
            Pixel.fill(c,x:x-s,y:y-s*0.25,w:s*2,h:s*0.5,color:NSColor(calibratedRed:0.12,green:0.35,blue:0.49,alpha:1))
            Pixel.fill(c,x:x-s*0.6,y:y,w:s*0.7,h:3,color:NSColor(calibratedRed:0.48,green:0.69,blue:0.72,alpha:1))
        }
    }
}
