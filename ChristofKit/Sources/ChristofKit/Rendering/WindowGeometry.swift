import CoreGraphics

struct WindowGeometry {
    let frame: CGFloat
    let mullion: CGFloat
    let glass: CGRect
    let sillTop: CGRect
    let sillFace: CGRect

    var glassCornerRadius: CGFloat { frame * 0.3 }

    init(size: CGSize) {
        frame = min(size.width, size.height) * 0.055
        mullion = frame * 0.5
        let sillHeight = frame * 2.7
        let sillY = size.height - sillHeight
        glass = CGRect(x: frame, y: frame, width: size.width - frame * 2, height: sillY - frame)
        sillTop = CGRect(x: 0, y: sillY, width: size.width, height: sillHeight * 0.24)
        sillFace = CGRect(x: 0, y: sillTop.maxY, width: size.width, height: size.height - sillTop.maxY)
    }
}

extension CGRect {
    init(center: CGPoint, radius: CGFloat) {
        self.init(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    }
}
