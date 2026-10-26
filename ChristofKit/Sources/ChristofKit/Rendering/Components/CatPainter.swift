/// 치즈 고양이. 상태(창밖 보기, 잠, 걷기, 쓰다듬기, 어깨 위)마다 자세와 자리가 다르다.
enum CatPainter {
    static func draw(_ g: inout DotGrid, _ s: DotScene, _ spot: CatSpot) {
        g.sprite(spot.x, spot.bottom, spot.pose.rows, Sprites.colors(lightOn: s.lightOn))
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
struct CatPose {
    let rows: [String]

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
    ])
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
    ])
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
    ])
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
    ])
    /// 감은 눈, 꼬리를 앞으로 감았다.
    static let curled = CatPose(rows: [
        ".c..c.........",
        ".cccc..ccccc..",
        "cccccccccTcccR",
        "cTcTccccccTccR",
        "cccccccTccTccR",
        "ccTTTTTTTcccR.",
        ".ccccccccccc..",
    ])
}
