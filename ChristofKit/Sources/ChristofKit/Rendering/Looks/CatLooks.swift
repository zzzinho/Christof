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
    static let persimmon = CatItem(rows: [".l.", "ooo", "ooo"], colors: ["l": "plant-dark", "o": "autumn-1"])
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

/// 등 양쪽에 펼친 박쥐 날개. 머리 줄 아래부터 몸 바깥으로 뻗는다.
struct BatWings: CatLook {
    func draw(_ g: inout DotGrid, _ spot: CatSpot, _ s: DotScene) {
        let left = spot.left, width = spot.pose.rows[0].count, y = spot.head.y
        let wing = LofiPalette.color("hoodie-dark")
        for (dx, dy) in [(1, 4), (2, 3), (3, 2), (4, 2), (1, 5), (2, 4), (3, 3), (2, 5), (1, 6)] {
            g.set(left - dx, y + dy, wing)
            g.set(left + width - 3 + dx, y + dy, wing)
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
