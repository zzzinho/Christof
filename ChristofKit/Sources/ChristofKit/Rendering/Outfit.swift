/// 사람 스프라이트의 옷 칸(o 기본, d 그늘, r 테두리 빛, j 바지·치마)을 칠하는 색. 시안의 OUTFITS 다.
struct Outfit {
    let base: String
    let shade: String
    var rim = "hoodie-rim"
    var skirt = "curtain-dark"

    static let mustard = Outfit(base: "knit-mustard", shade: "knit-mustard-dark", rim: "knit-mustard-rim")

    func color(_ ch: Character) -> String? {
        switch ch {
        case "o": base
        case "d": shade
        case "r": rim
        case "j": skirt
        default: nil
        }
    }
}
