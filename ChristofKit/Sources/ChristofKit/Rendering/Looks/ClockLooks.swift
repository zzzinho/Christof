/// 시계 모양은 문자판 색(face)을 바꾸거나 둘레에 더한다. draw 는 시계와 한 겹이라 윤곽선을 함께 두르고,
/// bare 는 줄·다리처럼 가늘어 윤곽선 없이 시계 위에 그린다.
protocol ClockLook: Sendable {
    var face: String? { get }
    func draw(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene)
    func bare(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene)
}

extension ClockLook {
    var face: String? { nil }
    func draw(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {}
    func bare(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {}
}

/// 달빛 문자판
struct ClockFace: ClockLook {
    let face: String?
}

/// 시계 아래 매듭 노리개
struct Norigae: ClockLook {
    func draw(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {
        let red = LofiPalette.color("pouch")
        g.rect(cx, cy + 7, 1, 2, red)
        g.rect(cx - 1, cy + 9, 3, 3, red)
        g.set(cx, cy + 10, LofiPalette.color("pouch-gold"))
        for dx in [-1, 0, 1] { g.rect(cx + dx, cy + 12, 1, 4 - abs(dx), red) }
    }
}

/// 시계 둘레 반짝이
struct Sparkles: ClockLook {
    func draw(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {
        let core = LofiPalette.color("lamp-light"), ray = LofiPalette.color("star")
        for (dx, dy) in [(-9, -5), (9, -3), (8, 8)] {
            g.set(cx + dx, cy + dy, core)
            for (ax, ay) in [(1, 0), (-1, 0), (0, 1), (0, -1)] { g.set(cx + dx + ax, cy + dy + ay, ray) }
        }
    }
}

/// 시계 아래 작은 연등
struct ClockLantern: ClockLook {
    func draw(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {
        let lantern = LanternString.lantern
        g.sprite(cx, cy + 9 + lantern.count, lantern, ["p": "lotus-lantern", "P": s.lightOn ? "lamp-light" : "lotus-lantern", "l": "plant"])
    }

    func bare(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {
        g.rect(cx, cy + 7, 1, 2, LofiPalette.color("wire"))
    }
}

/// 시계에 매달린 거미
struct Spider: ClockLook {
    func bare(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {
        g.rect(cx + 4, cy + 6, 1, 5, LofiPalette.color("star-dim"))
        g.sprite(cx + 4, cy + 14, ["W.W.W", ".WWW.", "W.W.W"], ["W": "outline"])
    }
}

/// 시계 위 호랑가시 잎과 열매
struct Holly: ClockLook {
    func draw(_ g: inout DotGrid, _ cx: Int, _ cy: Int, _ s: DotScene) {
        g.sprite(cx, cy - 5, ["LL.LL", ".LrL."], ["L": "summer-2", "r": "santa"])
    }
}
