// 시안의 SPRITES·SPRITE_COLORS 를 옮겼다. 불빛(스탠드·트리)이 오른쪽에 있어 오른쪽 가장자리에 따뜻한 테두리 빛이 진다.

enum Sprites {
    static let colors: [Character: String] = [
        "h": "hair-brown", "H": "hair-brown-rim", "k": "headphone-band", "K": "headphone-accent", "s": "skin", "S": "hoodie-rim", "e": "outline",
        "c": "cheese", "R": "cheese-rim", "T": "cheese-dark",
        "L": "lamp", "b": "lamp-body", "Y": "lamp-light", "m": "mug-dark", "M": "mug", "t": "steam",
        "1": "book-1", "2": "book-2", "3": "book-3", "l": "plant", "p": "pot",
    ]
    /// 불을 끈 낮에는 테두리 빛 자리를 바탕색으로 칠한다.
    static let unlitColors = colors.merging(["H": "hair-brown", "S": "skin", "R": "cheese", "Y": "lamp"]) { $1 }

    static func colors(lightOn: Bool) -> [Character: String] {
        lightOn ? colors : unlitColors
    }

    static let lamp = [
        "...LLLL...",
        "..LLLLLLb.",
        ".LLLLLLLb.",
        "..YYYY..b.",
        ".........b",
        ".........b",
        "........b.",
        ".......b..",
        "......b...",
        ".....b....",
        "....b.....",
        "..bbbbbb..",
    ]
    static let mug = [".t.t...", "t.t....", ".t.t...", ".......", "mmmmm..", "mMMMmmm", "mMMMm.m", "mMMMmmm", ".mmm..."]
    static let books = [".11111111.", "2222222222", ".33333333.", "1111111111"]
    static let plant = [".l.l.", "lLlLl", ".lLl.", "ppppp", ".ppp."]
    /// 김은 성긴 점이라 그릇 줄만 윤곽선을 두른다.
    static let rice = [".t.t.", ".www.", "BBBBB", ".BBB."]
}
