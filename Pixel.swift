import AppKit

enum Pixel {
    static func fill(
        _ context: CGContext,
        x: CGFloat,
        y: CGFloat,
        w: CGFloat,
        h: CGFloat,
        color: NSColor
    ) {
        context.setFillColor(color.cgColor)
        context.fill(
            CGRect(
                x: x.rounded(),
                y: y.rounded(),
                width: max(1, w.rounded()),
                height: max(1, h.rounded())
            )
        )
    }
}
