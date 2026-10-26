/// 도트 한 칸(3pt)에 색 하나. 06-lofi.html 의 Grid 를 옮겼고, 같은 입력이면 시안과 같은 칸을 칠한다.
public struct DotGrid: Sendable {
    public static let dot = 3.0

    public let cols: Int
    public let rows: Int
    public private(set) var cells: [UInt32?]
    private var origin = (x: 0, y: 0)
    private var bounds: (x0: Int, y0: Int, x1: Int, y1: Int)

    init(cols: Int, rows: Int) {
        self.cols = cols
        self.rows = rows
        cells = Array(repeating: nil, count: cols * rows)
        bounds = (0, 0, cols, rows)
    }

    mutating func set(_ x: Int, _ y: Int, _ c: UInt32?) {
        guard let c else { return }
        let ax = x + origin.x, ay = y + origin.y
        guard ax >= bounds.x0, ay >= bounds.y0, ax < bounds.x1, ay < bounds.y1 else { return }
        cells[ay * cols + ax] = c
    }

    mutating func set(_ x: Double, _ y: Double, _ c: UInt32?) {
        set(Int(x.rounded(.down)), Int(y.rounded(.down)), c)
    }

    /// (x, y) 를 원점으로 w×h 안에만 그린다.
    mutating func within(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ draw: (inout DotGrid) -> Void) {
        let saved = (origin, bounds)
        origin = (origin.x + x, origin.y + y)
        bounds = (max(bounds.x0, origin.x), max(bounds.y0, origin.y), min(bounds.x1, origin.x + w), min(bounds.y1, origin.y + h))
        draw(&self)
        (origin, bounds) = saved
    }

    mutating func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ c: UInt32) {
        for j in jsRound(y)..<max(jsRound(y), jsRound(y + h)) {
            for i in jsRound(x)..<max(jsRound(x), jsRound(x + w)) { set(i, j, c) }
        }
    }

    mutating func rect(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: UInt32) {
        rect(Double(x), Double(y), Double(w), Double(h), c)
    }

    mutating func shape(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, inside: (Double, Double) -> Bool, color: (Int, Int) -> UInt32?) {
        for y in Int(y0.rounded(.down))...Int(y1.rounded(.up)) {
            for x in Int(x0.rounded(.down))...Int(x1.rounded(.up)) where inside(Double(x) + 0.5, Double(y) + 0.5) {
                set(x, y, color(x, y))
            }
        }
    }

    /// rows 는 문자열 격자, map 은 글자 → 색 이름. 아래 가운데를 (x, bottom) 에 맞춘다.
    mutating func sprite(_ x: Double, _ bottom: Int, _ rows: [String], _ map: [Character: String]) {
        let left = jsRound(x - Double(rows[0].count) / 2), top = bottom - rows.count
        for (j, row) in rows.enumerated() {
            for (i, ch) in row.enumerated() {
                if let name = map[ch] { set(left + i, top + j, LofiPalette.color(name)) }
            }
        }
    }

    mutating func sprite(_ x: Int, _ bottom: Int, _ rows: [String], _ map: [Character: String]) {
        sprite(Double(x), bottom, rows, map)
    }

    mutating func disc(_ cx: Double, _ cy: Double, _ r: Double, _ color: (Int, Int) -> UInt32?) {
        shape(cx - r, cy - r, cx + r, cy + r, inside: { x, y in jsHypot(x - cx, y - cy) <= r }, color: color)
    }

    mutating func disc(_ cx: Double, _ cy: Double, _ r: Double, _ c: UInt32) {
        disc(cx, cy, r) { _, _ in c }
    }

    /// 원 바깥 thickness 칸을 바깥으로 갈수록 성기게 찍는 빛 번짐
    mutating func ring(_ cx: Double, _ cy: Double, _ r: Double, _ thickness: Double, _ c: UInt32) {
        func dist(_ x: Double, _ y: Double) -> Double { jsHypot(x - cx, y - cy) }
        shape(cx - r - thickness, cy - r - thickness, cx + r + thickness, cy + r + thickness,
              inside: { x, y in dist(x, y) > r && dist(x, y) <= r + thickness },
              color: { x, y in (1 - (dist(Double(x) + 0.5, Double(y) + 0.5) - r) / (thickness + 0.5)) * 0.75 > bayer(x, y) ? c : nil })
    }

    /// 사람·고양이·소품은 따로 한 겹에 그려 바깥 한 칸에 윤곽선을 두르고 얹는다. 벽·창밖은 바로 그린다.
    mutating func ink(_ draw: (inout DotGrid) -> Void) {
        var layer = DotGrid(cols: cols, rows: rows)
        draw(&layer)
        let outline = LofiPalette.color("outline")
        func filled(_ i: Int, _ j: Int) -> Bool {
            i >= 0 && j >= 0 && i < cols && j < rows && layer.cells[j * cols + i] != nil
        }
        for j in 0..<rows {
            for i in 0..<cols {
                let edge = filled(i - 1, j) || filled(i + 1, j) || filled(i, j - 1) || filled(i, j + 1)
                set(i, j, layer.cells[j * cols + i] ?? (edge ? outline : nil))
            }
        }
    }
}

// 시안(JS)과 같은 칸에 찍으려고 JS 의 반올림·hypot 을 그대로 따른다.

/// Math.round: .5 는 +∞ 쪽으로 올린다. Swift rounded() 는 음수 .5 를 내려서 칸이 어긋난다.
func jsRound(_ x: Double) -> Int {
    let f = x.rounded(.down)
    return Int(x - f >= 0.5 ? f + 1 : f)
}

/// V8 Math.hypot 은 큰 값으로 나눠 제곱합을 구해서 libm hypot 과 마지막 자리가 다르다. 원 경계 칸이 갈린다.
func jsHypot(_ a: Double, _ b: Double) -> Double {
    let x = abs(a), y = abs(b), m = max(x, y)
    guard m > 0 else { return 0 }
    let nx = x / m, ny = y / m
    return (nx * nx + ny * ny).squareRoot() * m
}

private let bayerMatrix: [[Double]] = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

/// 4×4 디더링 문턱값
func bayer(_ x: Int, _ y: Int) -> Double {
    (bayerMatrix[((y % 4) + 4) % 4][((x % 4) + 4) % 4] + 0.5) / 16
}

/// f(0~1) 만큼 a 에서 b 로 넘어가는 자리. 띠 경계 30% 만 섞는다.
func blend(_ a: UInt32, _ b: UInt32, _ f: Double, _ x: Int, _ y: Int) -> UInt32 {
    min(1, max(0, (f - 0.5) / 0.3 + 0.5)) > bayer(x, y) ? b : a
}

extension LofiPalette {
    static func color(_ name: String) -> UInt32 {
        guard let c = colors[name] else { preconditionFailure("design.css 에 --lofi-\(name) 이 없다") }
        return c
    }
}
