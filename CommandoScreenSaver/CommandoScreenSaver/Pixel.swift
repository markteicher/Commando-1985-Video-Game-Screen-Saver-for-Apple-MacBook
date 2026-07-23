import AppKit

enum Pixel {
    static func fill(_ c: CGContext, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: NSColor) {
        c.setFillColor(color.cgColor)
        c.fill(CGRect(x: x.rounded(), y: y.rounded(), width: w.rounded(), height: h.rounded()))
    }
}
