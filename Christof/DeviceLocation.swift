import CoreLocation

@MainActor
enum DeviceLocation {
    // CLServiceSession 은 macOS 에 없어 두 플랫폼 모두 CLLocationManager 로 권한을 묻는다. 물음이 떠 있는 동안 살아 있어야 해서 붙잡아 둔다.
    private static let manager = CLLocationManager()

    /// 위치 한 번. 권한을 거절했거나 위치 서비스가 오류를 내면 nil 이다.
    static func current() async -> CLLocation? {
        manager.requestWhenInUseAuthorization()
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if let location = update.location { return location }
                if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted { return nil }
            }
        } catch {}
        return nil
    }
}
