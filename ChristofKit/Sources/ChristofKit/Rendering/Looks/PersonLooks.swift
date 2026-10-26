/// 사람 위에 겹쳐 그리는 모양(모자·머리 장식). x 는 사람 가운데, top 은 사람 맨 윗줄이다.
protocol PersonLook: Sendable {
    func draw(_ g: inout DotGrid, _ x: Int, _ top: Int, _ s: DotScene)
}

/// 사람 맨 윗줄에서 bottom 줄에 아래 끝을 맞춘 스프라이트. 모자는 폭 16 이라 사람과 왼쪽 끝이 같다.
struct PersonSprite: PersonLook {
    let rows: [String]
    let colors: [Character: String]
    var dx = 0
    let bottom: Int

    func draw(_ g: inout DotGrid, _ x: Int, _ top: Int, _ s: DotScene) {
        g.sprite(x + dx, top + bottom, rows, colors)
    }

    static let santaHat = PersonSprite(rows: [
        ".............ww.",
        "...........RRww.",
        "........RRRRR...",
        "......RRRRRRR...",
        ".....RRRRRRRRR..",
        "....RRRRRRRRRR..",
        "..wwwwwwwwwwwww.",
        "..wwwwwwwwwwwww.",
    ], colors: ["R": "santa", "w": "santa-trim"], bottom: 5)
    static let witchHat = PersonSprite(rows: [
        "..........WW....",
        ".........WWW....",
        "........WWWW....",
        ".......WWWWWW...",
        "......WWWWWWW...",
        "......WbbbbbW...",
        "WWWWWWWWWWWWWWWW",
    ], colors: ["W": "witch", "b": "pumpkin"], bottom: 5)
    static let beanie = PersonSprite(rows: [
        ".......ww.......",
        "......wwww......",
        ".....BBBBBB.....",
        "....BBBBBBBB....",
        "...BBBBBBBBBB...",
        "..bbbbbbbbbbbb..",
    ], colors: ["w": "santa-trim", "B": "beanie", "b": "beanie-dark"], bottom: 5)
    static let scarf = PersonSprite(rows: [
        ".....ffffff.....",
        "...ffffffffff...",
        "..........ff....",
        "..........ff....",
    ], colors: ["f": "scarf"], bottom: 17)
    // 머리핀은 오른쪽 옆머리(헤드폰 띠 아래)에 꽂는다.
    static let moonPin = PersonSprite(rows: ["MM", "M.", "MM"], colors: ["M": "moon"], dx: 3, bottom: 7)
    static let lotusPin = PersonSprite(rows: ["P.P", "PpP"], colors: ["P": "spring-1", "p": "spring-2"], dx: 3, bottom: 7)
    static let ribbonPin = PersonSprite(rows: ["P.P", "PgP", "P.P"], colors: ["P": "pouch", "g": "pouch-gold"], dx: 3, bottom: 7)
}

/// 늘어진 머리 끝에 맨 붉은 리본. 금박 매듭 아래로 두 가닥이 늘어진다.
struct Daenggi: PersonLook {
    func draw(_ g: inout DotGrid, _ x: Int, _ top: Int, _ s: DotScene) {
        let fall = PersonPainter.sprite.fall
        let end = top + fall.start + jsRound(s.hair * Double(fall.rows))
        g.sprite(x, end + 3, ["PP.PP", ".PgP.", ".P.P.", ".P.P."], ["P": "pouch", "g": "pouch-gold"])
    }
}
