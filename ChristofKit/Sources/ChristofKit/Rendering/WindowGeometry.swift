import CoreGraphics

/// 창문 크기에서 창틀·유리·창턱 자리를 정한다. 창틀, 레이어 합성, 창틀 위 장식이 같은 값을 쓴다.
struct WindowGeometry {
    /// 창틀 두께. 짧은 변에 비례한다.
    let frame: CGFloat
    let mullion: CGFloat
    let glass: CGRect
    /// 창턱 윗면. 장식과 쌓인 눈이 놓인다.
    let sillTop: CGRect
    /// 창턱 앞면. 캡션 자리.
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
