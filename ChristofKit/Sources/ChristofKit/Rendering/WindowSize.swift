import CoreGraphics

public enum WindowSize: Sendable, CaseIterable {
    case compact
    case regular
    case expanded

    /// iPhone 위젯 크기를 따르며 실제 크기는 기기마다 조금 다르다.
    public var referenceSize: CGSize {
        switch self {
        case .compact: CGSize(width: 170, height: 170)
        case .regular: CGSize(width: 364, height: 170)
        case .expanded: CGSize(width: 364, height: 382)
        }
    }

    var showsRegion: Bool { self != .compact }
}
