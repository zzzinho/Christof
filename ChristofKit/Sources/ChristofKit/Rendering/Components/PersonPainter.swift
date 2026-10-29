/// 책상 앞(카메라 쪽)에 앉아 창을 바라보는 여성의 뒷모습. 허리 아래는 위젯 아래 끝에서 잘린다.
enum PersonPainter {
    struct Sprite {
        let rows: [String]
        /// 옷이 시작하는 줄
        let body: Int
        /// 목에 건 헤드폰과 그 아랫줄
        let neck: [String]
        let neckBottom: Int
        /// 머리가 길어지면 내려오는 자리: 시작 줄, 칸 범위, 최대 줄 수
        let fall: (start: Int, cols: [ClosedRange<Int>], rows: Int)
    }

    static let sprite = Sprite(
        rows: [
            "................",
            "................",
            ".....hhhhhH.....",
            "....nnnnnnnn....",
            "...khhhhhhhhk...",
            "..khhhhhhhhhHk..",
            "..khhhhhhhhhHk..",
            ".KKhhhhhhhhhHKK.",
            ".KKhhhhhhhhhHKK.",
            ".KKhhhhhhhhhHKK.",
            "...hhhhhhhhhH...",
            "....hhhhhhhH....",
            ".....hhhhhh.....",
            "......sssS......",
            "...dddddddddd...",
            ".ooddddddddddoo.",
            "ooooddddddddooor",
            "oooooddddddoooor",
            "ooooooddddooooor",
            "oooooooooooooorr",
            "oooooodooooooorr",
            "oooooodooooooorr",
            "oooooodooooooorr",
            "oooooodooooooorr",
            "oooooodooooooorr",
            "oooooodooooooorr",
        ],
        body: 14,
        neck: ["..KK........KK..", "..KK........KK.."],
        neckBottom: 16,
        fall: (13, [4...11], 10))

    static func draw(_ g: inout DotGrid, _ L: RoomLayout, _ s: DotScene) {
        let p = sprite, top = L.personTop, left = jsRound(Double(L.personX) - Double(p.rows[0].count) / 2)
        let lit = Sprites.colors(lightOn: s.lightOn)
        // 헤드폰을 벗으면 머리띠 정수리(n)만 머리색이고 머리띠 옆(k)·귀덮개(K)는 비운다.
        // 머리띠 옆까지 머리색으로 채우면 관자놀이가 귀 자리보다 넓어져 양쪽이 튀어나와 보인다.
        let colors = s.headwear == .headphones ? lit : lit.merging(["n": "hair-brown"]) { $1 }.filter { $0.key != "k" && $0.key != "K" }
        for (j, row) in p.rows.enumerated() {
            for (i, ch) in row.enumerated() {
                // 불을 끈 낮에는 옷의 테두리 빛(r) 자리도 기본 색이다.
                let cloth: Character = s.lightOn || ch != "r" ? ch : "o"
                let name = j >= p.body && "odrj".contains(ch) ? s.outfit.color(cloth, i, j - p.body, row) : colors[ch]
                if let name { g.set(left + i, top + j, LofiPalette.color(name)) }
            }
        }
        if s.headwear == .neck { g.sprite(L.personX, top + p.neckBottom, p.neck, lit) }
        // 늘어진 머리. 양 끝 칸을 한 줄 짧게 해 끝을 둥글게 하고, 가장 오른쪽 칸은 테두리 빛이다.
        let length = jsRound(s.hair * Double(p.fall.rows)), right = p.fall.cols.map(\.upperBound).max() ?? 0
        let hair = LofiPalette.color(lit["h"]!), rim = LofiPalette.color(lit["H"]!)
        for cols in p.fall.cols {
            for i in cols {
                let edge = i == cols.lowerBound || i == cols.upperBound
                for j in 0..<max(0, length - (edge ? 1 : 0)) { g.set(left + i, top + p.fall.start + j, i == right ? rim : hair) }
            }
        }
        for look in s.looks.person { look.draw(&g, L.personX, top, s) }
    }
}
