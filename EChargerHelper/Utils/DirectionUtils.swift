import Foundation
import CoreLocation

struct DirectionUtils {
    
    // MARK: - Coordinate Validation
    
    /// Validates that coordinates are within valid Earth bounds
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180 &&
               coordinate.latitude.isFinite && coordinate.longitude.isFinite
    }
    
    /// Validates that coordinates are within the Rotterdam-Santa Pola route bounds
    static func isWithinRouteBounds(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard isValidCoordinate(coordinate) else { return false }
        
        // Route bounds: approximately from Rotterdam (52.09°N, 4.31°E) to Santa Pola (38.19°N, -0.55°W)
        let minLatitude = 38.0  // South of Santa Pola
        let maxLatitude = 53.0  // North of Rotterdam
        let minLongitude = -1.0 // West of Santa Pola
        let maxLongitude = 5.0  // East of Rotterdam
        
        return coordinate.latitude >= minLatitude &&
               coordinate.latitude <= maxLatitude &&
               coordinate.longitude >= minLongitude &&
               coordinate.longitude <= maxLongitude
    }
    
    static func calculateDistance(from userLocation: CLLocationCoordinate2D, to chargerLocation: ChargerLocation) -> Double {
        // Validate coordinates before processing
        guard isValidCoordinate(userLocation) else {
            print("⚠️ Invalid user location coordinates: \(userLocation)")
            return Double.greatestFiniteMagnitude
        }
        
        let chargerCoordinate = CLLocationCoordinate2D(latitude: chargerLocation.latitude, longitude: chargerLocation.longitude)
        guard isValidCoordinate(chargerCoordinate) else {
            print("⚠️ Invalid charger coordinates: \(chargerCoordinate)")
            return Double.greatestFiniteMagnitude
        }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let chargerCLLocation = CLLocation(latitude: chargerLocation.latitude, longitude: chargerLocation.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: chargerCLLocation)
        return distanceInMeters / 1000.0 // Convert to kilometers
    }
    
    static func calculateDistance(from userLocation: CLLocationCoordinate2D, to chargerCoordinate: CLLocationCoordinate2D) -> Double {
        // Validate coordinates before processing
        guard isValidCoordinate(userLocation) else {
            return Double.greatestFiniteMagnitude
        }
        
        guard isValidCoordinate(chargerCoordinate) else {
            return Double.greatestFiniteMagnitude
        }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let chargerCLLocation = CLLocation(latitude: chargerCoordinate.latitude, longitude: chargerCoordinate.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: chargerCLLocation)
        return distanceInMeters / 1000.0 // Convert to kilometers
    }
    
    static func isChargerAhead(charger: Charger, for direction: TravelDirection, from userLocation: CLLocationCoordinate2D) -> Bool {
        // Validate coordinates before processing
        guard isValidCoordinate(userLocation) else {
            return false
        }
        
        let chargerCoordinate = CLLocationCoordinate2D(latitude: charger.location.latitude, longitude: charger.location.longitude)
        guard isValidCoordinate(chargerCoordinate) else {
            return false
        }
        
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
        
        // Validate reference coordinates
        guard isValidCoordinate(rotterdamCoord) && isValidCoordinate(santaPolaCoord) else {
            // Return a safe default coordinate in case of validation failure
            return CLLocationCoordinate2D(latitude: 45.0, longitude: 2.0) // Approximate center of route
        }
        
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
            
            let estimatedCoordinate = CLLocationCoordinate2D(
                latitude: rotterdamCoord.latitude + (latDiff * progressRatio),
                longitude: rotterdamCoord.longitude + (lonDiff * progressRatio)
            )
            
            // Validate estimated coordinate before returning
            return isValidCoordinate(estimatedCoordinate) ? estimatedCoordinate : rotterdamCoord
            
        case .santaPolaToRotterdam:
            // If heading north with X km range left
            let estimatedTraveledKm = totalDistanceKm - (remainingRangeKm * 4)
            progressRatio = max(0, min(1, estimatedTraveledKm / totalDistanceKm))
            
            let latDiff = rotterdamCoord.latitude - santaPolaCoord.latitude
            let lonDiff = rotterdamCoord.longitude - santaPolaCoord.longitude
            
            let estimatedCoordinate = CLLocationCoordinate2D(
                latitude: santaPolaCoord.latitude + (latDiff * progressRatio),
                longitude: santaPolaCoord.longitude + (lonDiff * progressRatio)
            )
            
            // Validate estimated coordinate before returning
            return isValidCoordinate(estimatedCoordinate) ? estimatedCoordinate : santaPolaCoord
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