/// 구성 요소 자리. 격자 크기마다 따로 계산한다. 시안의 layout() 이다.
struct RoomLayout {
    let W: Int
    let H: Int
    let deskTop: Int
    let sill: Int
    let x0: Int
    let x1: Int
    let y0: Int
    let tree: Bool
    let treeX: Int
    let lampX: Int
    let personX: Int
    let personTop: Int
    let clock: (x: Int, y: Int)
    let cat: (x: Int, y: Int)
    /// 창 유리 [x, y, w, h]
    let view: (x: Int, y: Int, w: Int, h: Int)
    /// 벽을 데우는 불빛 중심
    let light: (x: Double, y: Double)

    init(cols W: Int, rows H: Int, tree: Bool) {
        let wide = W > H
        self.W = W
        self.H = H
        self.tree = tree
        deskTop = H - 7
        sill = deskTop - 2
        x0 = jsRound(Double(W) * (wide ? 0.06 : 0.04))
        x1 = x0 + jsRound(Double(W) * (wide ? 0.5 : 0.6))
        y0 = jsRound(Double(H) * 0.1)
        treeX = W - 9
        lampX = jsRound(Double(W) * (wide ? 0.92 : 0.95))
        personX = jsRound(Double(W) * (wide ? (tree ? 0.72 : 0.74) : (tree ? 0.6 : 0.72)))
        personTop = H - PersonPainter.sprite.rows.count
        clock = (x1 + 7, y0 + 4)
        cat = (x0 + 9, sill)
        view = (x0 + 2, y0 + 2, x1 - x0 - 4, sill - y0 - 2)
        light = tree ? (Double(treeX), Double(H - 20)) : (Double(lampX - 2), Double(deskTop - 9))
    }

    /// 고양이 상태마다 자리. front 면 사람 앞에 그린다.
    /// item 은 곁에 두는 이벤트 물건 자리 [가운데, 바닥]이다. 어깨 위 고양이는 곁에 바닥이 없어 창턱 고양이 자리에 둔다.
    func catSpot(_ state: DotScene.CatState) -> CatSpot {
        switch state {
        case .window: CatSpot(pose: .back, x: cat.x, bottom: sill, item: (cat.x + 8, sill))
        case .sleep: CatSpot(pose: .curled, x: x0 + 10, bottom: sill, item: (x0 + 20, sill))
        case .walk: CatSpot(pose: .walk, x: x0 + 12, bottom: sill, item: (x0 + 23, sill))
        case .pet:
            CatSpot(pose: .side, x: personX - 15, bottom: deskTop + 1, item: (personX - 24, deskTop + 1), front: true,
                    arm: ((personX - 6, personTop + 15), (personX - 12, deskTop - 10)))
        case .shoulder: CatSpot(pose: .curled, x: personX + 1, bottom: personTop + 18, item: (cat.x, sill), front: true)
        }
    }
}

struct CatSpot {
    let pose: CatPose
    let x: Int
    let bottom: Int
    let item: (x: Int, y: Int)
    var front = false
    /// 쓰다듬는 팔 [어깨, 손끝]
    var arm: (from: (x: Int, y: Int), to: (x: Int, y: Int))?

    var left: Int { jsRound(Double(x) - Double(pose.rows[0].count) / 2) }
    var head: (x: Double, y: Int) { (Double(left) + pose.head.x, bottom - pose.rows.count + pose.head.y) }
}
