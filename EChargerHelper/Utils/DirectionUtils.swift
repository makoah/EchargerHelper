import Foundation
import CoreLocation

struct DirectionUtils {
    
    static func calculateDistance(from userLocation: CLLocationCoordinate2D, to chargerLocation: ChargerLocation) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let chargerCLLocation = CLLocation(latitude: chargerLocation.latitude, longitude: chargerLocation.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: chargerCLLocation)
        return distanceInMeters / 1000.0 // Convert to kilometers
    }
    
    static func isChargerAhead(charger: Charger, for direction: TravelDirection, from userLocation: CLLocationCoordinate2D) -> Bool {
        let chargerLat = charger.location.latitude
        let userLat = userLocation.latitude
        
        switch direction {
        case .rotterdamToSantaPola:
            // Traveling south, so chargers ahead should have lower latitude
            return chargerLat <= userLat
        case .santaPolaToRotterdam:
            // Traveling north, so chargers ahead should have higher latitude  
            return chargerLat >= userLat
        }
    }
    
    static func estimateCurrentPosition(for direction: TravelDirection, range: RemainingRange) -> CLLocationCoordinate2D {
        // Rough coordinates for Rotterdam and Santa Pola
        let rotterdamCoord = CLLocationCoordinate2D(latitude: 51.9225, longitude: 4.4792)
        let santaPolaCoord = CLLocationCoordinate2D(latitude: 38.1929, longitude: -0.5519)
        
        // Total distance approximately 1600km
        let totalDistanceKm = 1600.0
        let remainingRangeKm = Double(range.rawValue)
        
        // Estimate position based on range remaining
        let progressRatio: Double
        
        switch direction {
        case .rotterdamToSantaPola:
            // If heading south with X km range left, estimate how far we've traveled
            let estimatedTraveledKm = totalDistanceKm - (remainingRangeKm * 4) // Assume 4x range for full trip planning
            progressRatio = max(0, min(1, estimatedTraveledKm / totalDistanceKm))
            
            let latDiff = santaPolaCoord.latitude - rotterdamCoord.latitude
            let lonDiff = santaPolaCoord.longitude - rotterdamCoord.longitude
            
            return CLLocationCoordinate2D(
                latitude: rotterdamCoord.latitude + (latDiff * progressRatio),
                longitude: rotterdamCoord.longitude + (lonDiff * progressRatio)
            )
            
        case .santaPolaToRotterdam:
            // If heading north with X km range left
            let estimatedTraveledKm = totalDistanceKm - (remainingRangeKm * 4)
            progressRatio = max(0, min(1, estimatedTraveledKm / totalDistanceKm))
            
            let latDiff = rotterdamCoord.latitude - santaPolaCoord.latitude
            let lonDiff = rotterdamCoord.longitude - santaPolaCoord.longitude
            
            return CLLocationCoordinate2D(
                latitude: santaPolaCoord.latitude + (latDiff * progressRatio),
                longitude: santaPolaCoord.longitude + (lonDiff * progressRatio)
            )
        }
    }
    
    static func getHighwaySegment(for location: CLLocationCoordinate2D) -> String {
        let lat = location.latitude
        
        // Rough highway segments based on latitude
        switch lat {
        case 51.0...:
            return "A2/A4 (Netherlands)"
        case 50.0..<51.0:
            return "A1/A26 (Belgium/Northern France)"
        case 48.0..<50.0:
            return "A4/A6 (Central France)"
        case 45.0..<48.0:
            return "A7 (Southern France)"
        case 42.0..<45.0:
            return "AP-7 (Northern Spain)"
        case 38.0..<42.0:
            return "AP-7 (Eastern Spain)"
        default:
            return "Unknown highway segment"
        }
    }
    
    static func isAccessibleFromDirection(charger: Charger, direction: TravelDirection) -> Bool {
        let chargerDirection = charger.highwayAccess.direction
        
        switch chargerDirection {
        case .both:
            return true
        case .rotterdamToSantaPola:
            return direction == .rotterdamToSantaPola
        case .santaPolaToRotterdam:
            return direction == .santaPolaToRotterdam
        }
    }
    
    static func calculateTimeToCharger(distance: Double, averageSpeed: Double = 100.0) -> TimeInterval {
        return (distance / averageSpeed) * 3600 // Convert hours to seconds
    }
    
    static func formatDistance(_ distance: Double) -> String {
        if distance < 1.0 {
            return String(format: "%.0f m", distance * 1000)
        } else {
            return String(format: "%.1f km", distance)
        }
    }
    
    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}