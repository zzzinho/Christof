import CoreGraphics

/// 위젯 크기별 창문 모양. 캡션에 담는 정보량과 기준 비율을 정한다.
public enum WindowStyle: Sendable, CaseIterable {
    /// systemSmall. 캡션은 시각과 기온만.
    case compact
    /// systemMedium. 캡션에 지역과 진행 중인 이벤트 이름을 더한다.
    case regular
    /// systemLarge. regular 와 같은 정보를 더 크게.
    case expanded

    /// 미리보기·스냅샷 기준 크기(pt). iPhone 위젯 크기를 따르며 실제 크기는 기기마다 조금 다르다.
    public var referenceSize: CGSize {
        switch self {
        case .compact: CGSize(width: 170, height: 170)
        case .regular: CGSize(width: 364, height: 170)
        case .expanded: CGSize(width: 364, height: 382)
        }
    }

    var showsDetails: Bool { self != .compact }
}
