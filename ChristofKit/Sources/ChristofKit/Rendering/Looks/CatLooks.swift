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

/// 등 한가운데서 양쪽으로 펼친 작은 악마 날개. 자세마다 왼쪽 날개 뿌리 칸(pose.wings)이 있고, 오른쪽 날개는 바로 옆 칸에서 뒤집어 그린다.
struct DevilWings: CatLook {
    /// 왼쪽 날개. 오른쪽 아래 칸이 뿌리다. B 뼈대, m 막(아래 끝이 톱니).
    static let wing = ["B...", "mB..", "mmB.", "m.mB"]

    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene) {
        guard let (x, y) = spot.pose.wings else { return }
        let top = spot.bottom - spot.pose.rows.count, w = Self.wing[0].count, h = Self.wing.count
        for (j, row) in Self.wing.enumerated() {
            for (i, ch) in row.enumerated() where ch != "." {
                let c = LofiPalette.color(ch == "B" ? "santa-dark" : "santa"), yy = top + y - (h - 1) + j
                g.set(spot.left + x - (w - 1 - i), yy, c)
                g.set(spot.left + x + 1 + (w - 1 - i), yy, c)
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
