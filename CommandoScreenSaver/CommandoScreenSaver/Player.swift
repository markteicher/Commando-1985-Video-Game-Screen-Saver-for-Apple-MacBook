import AppKit
struct Player {
    var position: CGPoint
    func draw(in c: CGContext) {
        c.saveGState(); c.translateBy(x: position.x, y: position.y)
        Pixel.fill(c,x:-7,y:-14,w:5,h:9,color:.darkGray); Pixel.fill(c,x:2,y:-14,w:5,h:9,color:.darkGray)
        Pixel.fill(c,x:-10,y:-5,w:20,h:16,color:NSColor(calibratedRed:0.12,green:0.34,blue:0.64,alpha:1))
        Pixel.fill(c,x:-5,y:11,w:10,h:8,color:NSColor(calibratedRed:0.86,green:0.66,blue:0.44,alpha:1))
        Pixel.fill(c,x:-7,y:16,w:14,h:5,color:NSColor(calibratedRed:0.12,green:0.25,blue:0.15,alpha:1))
        Pixel.fill(c,x:8,y:7,w:3,h:20,color:.darkGray); c.restoreGState()
    }
}
