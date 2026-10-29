/// 치즈 고양이. 상태(창밖 보기, 잠, 걷기, 쓰다듬기, 어깨 위)마다 자세와 자리가 다르다.
enum CatPainter {
    static func draw(_ g: inout DotGrid, _ s: DotScene, _ spot: CatSpot) {
        g.sprite(spot.x, spot.bottom, spot.pose.rows, Sprites.colors(lightOn: s.lightOn))
        // 그릇은 고양이 다음에 그려 숙인 입을 가린다.
        if let bowl = spot.bowl { g.sprite(bowl.x, bowl.y, [".fff.", "BBBBB"], ["f": "autumn-2", "B": "beanie"]) }
        for look in s.looks.cat { look.draw(&g, spot, s) }
        if let arm = spot.arm { drawArm(&g, arm.from, arm.to, sleeve: s.outfit.base) }
    }

    /// 사람 어깨에서 고양이로 뻗는 팔. 두 칸 두께 소매, 끝 네 칸은 손.
    static func drawArm(_ g: inout DotGrid, _ a: (x: Int, y: Int), _ b: (x: Int, y: Int), sleeve: String) {
        let (dx, dy) = (Double(b.x - a.x), Double(b.y - a.y))
        let steps = Int((jsHypot(dx, dy) * 2).rounded(.up))
        let skin = LofiPalette.color("skin"), cloth = LofiPalette.color(sleeve)
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let x = jsRound(Double(a.x) + dx * t), y = jsRound(Double(a.y) + dy * t)
            let c = t > 0.75 ? skin : cloth
            g.set(x, y, c)
            g.set(x, y + 1, c)
        }
    }
}

/// T 는 줄무늬. 다섯 자세 모두 머리 폭(테두리 포함 6~7칸)과 몸집을 맞춘다. side, walk 는 오른쪽(사람·불빛 쪽)을 본다.
/// head: 머리 위 가운데 칸(귀 사이), scarf: 목도리, scarfBottom: 목도리 아랫줄이 닿는 고양이 줄, wings: 할로윈 날개 뿌리(등 한가운데).
/// front 는 쓰는 상태가 없어 날개 자리가 없다.
struct CatPose {
    let rows: [String]
    let head: (x: Double, y: Int)
    let scarf: [String]
    let scarfBottom: Int
    var wings: (x: Int, y: Int)?

    static let back = CatPose(rows: [
        ".c....c....",
        ".cc..cc....",
        ".cTcTccR...",
        ".ccccccR...",
        "..ccccR....",
        "..ccccc....",
        ".cTTcccR...",
        "cccccccR...",
        "cTTTcccR...",
        "ccccccccR..",
        "cTTcccccRc.",
        ".ccccccccc.",
    ], head: (3.5, 2), scarf: ["..SSSSS....", "..S........", "..S........", ".S........."], scarfBottom: 9, wings: (3, 7))
    static let front = CatPose(rows: [
        ".c.....c..",
        ".cc...cc..",
        ".cTcTcTcR.",
        ".cecccecR.",
        ".cccccccR.",
        "..cccccR..",
        "..cTcTcR..",
        ".cccccccR.",
        ".cccccccR.",
        "ccccccccRc",
        "cccccccccc",
    ], head: (4, 2), scarf: ["..SSSSS...", "......S...", "......S..."], scarfBottom: 8)
    static let side = CatPose(rows: [
        ".......c..c.",
        "......ccccc.",
        "......ccTecR",
        "......cccccR",
        ".......cccR.",
        ".....cTccR..",
        "....cTcccR..",
        "...cTccccR..",
        "..cTcccccR..",
        "..ccccccccR.",
        "c.ccccccccR.",
        "ccccccccccR.",
    ], head: (8.5, 1), scarf: ["......SSSS..", "......S....."], scarfBottom: 5, wings: (3, 8))
    static let walk = CatPose(rows: [
        "c..........c..c.",
        "c.........ccccc.",
        "c.........cTcecR",
        ".c........cccccR",
        ".cccTccTccccccR.",
        "..cTccTccTcccR..",
        "..ccccccccccR...",
        "..cccccccccR....",
        "..cc.c...cc.R...",
        "..c..c...c..c...",
    ], head: (12.5, 1), scarf: ["..........SSS...", "...........S...."], scarfBottom: 4, wings: (5, 4))
    /// 웅크려 어깨뼈가 솟고, 목을 앞아래로 뻗어 밥그릇에 머리를 박았다.
    static let eat = CatPose(rows: [
        ".................",
        "........ccR......",
        "....cTccTccR.....",
        "..cTccTccTcR.c..c",
        ".cccccccccccccccR",
        ".ccccccccccccTceR",
        "c.ccccccccc.ccccR",
        "c.cccc...cc...ccc",
        "cccccc...cc......",
    ], head: (14.5, 4), scarf: ["...........SS....", "...........S....."], scarfBottom: 6, wings: (6, 2))
    /// 감은 눈, 꼬리를 앞으로 감았다.
    static let curled = CatPose(rows: [
        ".c..c.........",
        ".cccc..ccccc..",
        "cccccccccTcccR",
        "cTcTccccccTccR",
        "cccccccTccTccR",
        "ccTTTTTTTcccR.",
        ".ccccccccccc..",
    ], head: (2.5, 1), scarf: [".SSSS.........", "..S..........."], scarfBottom: 5, wings: (8, 1))
}
