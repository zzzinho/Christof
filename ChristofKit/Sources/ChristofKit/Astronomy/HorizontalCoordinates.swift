import Foundation

func horizontalCoordinates(hourAngle: Double, declination: Double, latitude: Double) -> (altitude: Double, azimuth: Double) {
    let altitude = asin(sin(latitude) * sin(declination) + cos(latitude) * cos(declination) * cos(hourAngle))
    // atan2 는 남쪽 기준이라 180° 돌린다.
    let azimuth = atan2(sin(hourAngle), cos(hourAngle) * sin(latitude) - tan(declination) * cos(latitude))
    return (altitude * 180 / .pi, (azimuth * 180 / .pi + 180).truncatingRemainder(dividingBy: 360))
}
