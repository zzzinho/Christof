/// 고양이 모양은 머리 위 칸(head)이나 곁의 물건 자리(spot.item)에 둔다.
protocol CatLook: Sendable {
    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene)
}

/// 고양이 곁에 두는 물건
struct CatItem: CatLook {
    let rows: [String]
    let colors: [Character: String]

    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene) {
        g.sprite(spot.item.x, spot.item.y, rows, colors)
    }

    static let pouch = CatItem(rows: ["..p..", ".PPP.", "PpgpP", "PpppP", ".PPP."], colors: ["P": "pouch", "p": "pouch-light", "g": "pouch-gold"])
    static let walnut = CatItem(rows: ["nNn", "NnN"], colors: ["n": "wood-light", "N": "branch"])
    /// 추석 선물: 조각보로 싸고 위를 매듭지은 보자기
    static let bojagi = CatItem(rows: ["k.k", ".k.", "ABC", "CAB"], colors: ["k": "hanbok", "A": "hanbok", "B": "hanbok-jade", "C": "pouch-gold"])
}

/// 머리 위 가운데 칸에 아래 끝을 맞춘 모양. dy 만큼 내려 머리에 씌운다.
struct CatHeadItem: CatLook {
    let rows: [String]
    let colors: [Character: String]
    var dy = 0

    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene) {
        let head = spot.head
        g.sprite(head.x, head.y + dy, rows, colors)
    }

    static let beanie = CatHeadItem(rows: ["..w..", ".BBB.", "BBBBB"], colors: ["w": "santa-trim", "B": "beanie"], dy: 1)
    static let lotus = CatHeadItem(rows: [".P.", "PpP"], colors: ["P": "spring-1", "p": "spring-2"])
}

/// 등 가운데에 단 악마 날개 한 쌍. 날개는 뿌리(pose.wings)에서 위 바깥으로 뻗는다.
/// 옆모습은 머리와 겹치지 않게 두 날개 모두 꼬리 쪽으로 뻗고, 먼 날개는 앞으로 비켜 그늘색으로 먼저 그린다.
struct DevilWings: CatLook {
    /// 왼쪽 날개. 오른쪽 아래 칸이 뿌리다. B 뼈대, m 막(아래 끝이 톱니).
    static let wing = ["B......", "mB.....", "mmBB...", "mmmmBB.", "m.m.m.B"]

    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene) {
        let top = spot.bottom - spot.pose.rows.count, w = Self.wing[0].count, h = Self.wing.count
        for (x, y, dir, far) in spot.pose.wings {
            for (j, row) in Self.wing.enumerated() {
                for (i, ch) in row.enumerated() where ch != "." {
                    g.set(spot.left + x + dir * (w - 1 - i), top + y - (h - 1) + j, LofiPalette.color(far || ch == "B" ? "santa-dark" : "santa"))
                }
            }
        }
    }
}

/// 목도리. 자세마다 따로 그려 두었다. color 가 없으면 요일 색이다.
struct CatScarf: CatLook {
    var color: String?

    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene) {
        let pose = spot.pose
        g.sprite(spot.x, spot.bottom - pose.rows.count + pose.scarfBottom, pose.scarf, ["S": color ?? Self.weekdayColors[s.weekday]])
    }

    static let santa = CatScarf(color: "santa")
    static let winter = CatScarf()
    /// 0 = 일요일. 일요일은 달력의 빨간 날, 토요일은 파란 날
    static let weekdayColors = ["santa", "hanbok-collar", "spring-1", "hanbok-jade", "summer-2", "hoodie", "pouch-knot"]
}
