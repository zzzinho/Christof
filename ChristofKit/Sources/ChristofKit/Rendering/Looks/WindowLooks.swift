import Foundation

/// 창문 모양은 그리는 깊이로 나눈다: sky(해·달 앞, 번개·도시 뒤), ground(도시·가로수 앞), glass(날씨 앞, 유리 위), frame(창틀 위).
/// sky·ground·glass 는 유리 기준 칸이고 창 윤곽선 한 겹 안에 들어간다.
protocol WindowLook: Sendable {
    func sky(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene)
    func ground(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene)
    func glass(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene)
    func frame(_ g: inout DotGrid, _ L: RoomLayout, _ s: DotScene)
}

extension WindowLook {
    func sky(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {}
    func ground(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {}
    func glass(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {}
    func frame(_ g: inout DotGrid, _ L: RoomLayout, _ s: DotScene) {}
}

/// 하늘에 뜬 방패연과 연줄 두 가닥
struct Kite: WindowLook {
    func sky(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        let x = jsRound(Double(w) * 0.72), y = jsRound(Double(h) * 0.16)
        g.sprite(x, y + 5, ["PPPPP", "WWWWW", "WW.WW", "WWWWW", "WWWWW"], ["P": "pouch", "W": "hanbok-collar"])
        let string = LofiPalette.color("pouch-knot")
        for k in 0..<5 {
            for dx in [-2, 2] { g.set(x + dx - k / 2, y + 5 + k, string) }
        }
    }
}

/// 첫 해 둘레의 따뜻한 빛
struct SunGlow: WindowLook {
    func sky(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let (cx, cy, r) = SunEffect.circle(s, w, h) else { return }
        g.ring(cx, cy, r + 2, 3, LofiPalette.color("moon-glow-1"))
        g.ring(cx, cy, r, 2, LofiPalette.color("sun-low"))
    }
}

/// 보름달 둘레의 따뜻한 빛 두 겹
struct MoonHalo: WindowLook {
    func sky(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        guard let (cx, cy, r) = MoonEffect.circle(s, w, h) else { return }
        g.ring(cx, cy, r + 2, 3, LofiPalette.color("moon-glow-2"))
        g.ring(cx, cy, r, 2, LofiPalette.color("moon-glow-1"))
    }
}

/// 멀리 달집 태우는 불
struct Daljip: WindowLook {
    func ground(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        let x = jsRound(Double(w) * 0.62)
        g.ring(Double(x) + 0.5, Double(h - 3), 0, 5, LofiPalette.color("moon-glow-1"))
        g.sprite(x, h, ["..Y..", ".YYY.", ".YOY.", "YOOOY", "OOOOO", "bbbbb"], ["Y": "lamp-light", "O": "lamp", "b": "branch"])
    }
}

/// 창 왼쪽 위로 들어온 감나무 가지
struct PersimmonBranch: WindowLook {
    func ground(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        let end = jsRound(Double(w) * 0.35)
        func y(_ x: Int) -> Int { 1 + jsRound(Double(x) * 0.25) }
        let branch = LofiPalette.color("branch"), leaf = LofiPalette.color("plant-dark"), fruit = LofiPalette.color("autumn-1")
        for x in 0..<end { g.set(x, y(x), branch) }
        for t in [0.3, 0.6, 0.9] {
            let x = jsRound(Double(end) * t)
            g.set(x + 1, y(x) - 1, leaf)
            g.rect(x - 1, y(x) + 1, 2, 2, fruit)
        }
    }
}

/// 하늘의 박쥐. 밤하늘에 묻히지 않게 윤곽선 색으로 칠한다.
struct Bats: WindowLook {
    func sky(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        for (fx, fy) in [(0.2, 0.22), (0.5, 0.12), (0.72, 0.3)] {
            g.sprite(jsRound(Double(w) * fx), jsRound(Double(h) * fy) + 3, ["WW.WW", ".WWW.", "..W.."], ["W": "outline"])
        }
    }
}

/// 유리 모서리와 아래쪽에 낀 성에
struct Frost: WindowLook {
    func glass(_ g: inout DotGrid, _ w: Int, _ h: Int, _ s: DotScene) {
        let frost = LofiPalette.color("frost")
        for y in 0..<h {
            for x in 0..<w {
                let (fx, fy, rx, ry) = (Double(x), Double(y), Double(w - 1 - x), Double(h - 1 - y))
                let corner = min(jsHypot(fx, fy), jsHypot(rx, fy), jsHypot(fx, ry), jsHypot(rx, ry))
                if max(1 - corner / 7, 1 - ry / 3) * 0.85 > bayer(x, y) { g.set(x, y, frost) }
            }
        }
    }
}

/// 창 위에 건 연등 줄. 해가 진 뒤에는 연등 속이 밝다. 줄은 가는 선이라 윤곽선 없이, 연등만 윤곽선을 두른다.
struct LanternString: WindowLook {
    /// 연꽃등: 끝이 뾰족한 꽃잎 두 겹, 아래에 연잎. 둥근 제등(일본)과 구분되게 꽃잎 끝을 살린다.
    static let lantern = [".p.p.p.", "ppPpPpp", "pPPPPPp", ".pPPPp.", "lllllll", ".l.l.l."]
    /// 오색 연등: 분홍 연꽃등을 앞세워 노랑·초록·빨강·파랑을 돌린다.
    static let colors = ["lotus-lantern", "bulb-2", "bulb-3", "bulb-1", "bulb-4"]

    func frame(_ g: inout DotGrid, _ L: RoomLayout, _ s: DotScene) {
        let (left, right, y) = (L.x0, L.x1, L.y0 - 1)
        let span = Double(right - left)
        func sag(_ x: Int) -> Int { y + jsRound(sin(Double(x - left) / span * Double.pi) * 3) }
        let n = max(3, jsRound(span / (32 / DotGrid.dot)))
        func at(_ i: Int) -> Int { jsRound(Double(left) + span * (Double(i) + 0.5) / Double(n)) }
        g.ink { t in
            for i in 0..<n {
                let bx = at(i), shade = Self.colors[i % Self.colors.count]
                t.sprite(bx, sag(bx) + 2 + Self.lantern.count, Self.lantern, ["p": shade, "P": s.lightOn ? "lamp-light" : shade, "l": "plant"])
            }
        }
        let wire = LofiPalette.color("wire")
        for x in left...right { g.set(x, sag(x), wire) }
        for i in 0..<n { g.set(at(i), sag(at(i)) + 1, wire) }
    }
}
