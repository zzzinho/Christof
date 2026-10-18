import Foundation

/// 시간각·적위·관측지 위도(라디안)를 고도·방위각(도, 방위각은 북 0 시계 방향)으로 바꾼다. 해·달이 함께 쓴다.
func horizontalCoordinates(hourAngle: Double, declination: Double, latitude: Double) -> (altitude: Double, azimuth: Double) {
    let altitude = asin(sin(latitude) * sin(declination) + cos(latitude) * cos(declination) * cos(hourAngle))
    // atan2 는 남쪽 기준이라 180° 돌린다.
    let azimuth = atan2(sin(hourAngle), cos(hourAngle) * sin(latitude) - tan(declination) * cos(latitude))
    return (altitude * 180 / .pi, (azimuth * 180 / .pi + 180).truncatingRemainder(dividingBy: 360))
}
