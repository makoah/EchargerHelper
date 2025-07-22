import Foundation
import CoreLocation

struct DistanceUtils {
    
    static func calculateOptimalChargers(
        chargers: [Charger], 
        userDirection: TravelDirection, 
        userRange: RemainingRange,
        userLocation: CLLocationCoordinate2D? = nil
    ) -> [ChargerResult] {
        
        let estimatedLocation = userLocation ?? DirectionUtils.estimateCurrentPosition(for: userDirection, range: userRange)
        
        let results = chargers.compactMap { charger -> ChargerResult? in
            // Check if charger is accessible from travel direction
            guard DirectionUtils.isAccessibleFromDirection(charger: charger, direction: userDirection) else {
                return nil
            }
            
            // Check if charger is ahead in travel direction
            guard DirectionUtils.isChargerAhead(charger: charger, for: userDirection, from: estimatedLocation) else {
                return nil
            }
            
            let distance = DirectionUtils.calculateDistance(from: estimatedLocation, to: charger.location)
            let timeToCharger = DirectionUtils.calculateTimeToCharger(distance: distance)
            
            // Check if charger is within safe range
            let safetyBuffer = 0.8 // Use 80% of remaining range for safety
            let maxReachableDistance = Double(userRange.rawValue) * safetyBuffer
            
            guard distance <= maxReachableDistance else {
                return nil
            }
            
            return ChargerResult(
                charger: charger,
                distance: distance,
                timeToCharger: timeToCharger,
                isReachable: true,
                estimatedArrivalRange: calculateArrivalRange(userRange: userRange, distance: distance),
                priority: calculatePriority(charger: charger, distance: distance, userRange: userRange)
            )
        }
        
        // Sort by priority (higher is better), then by distance
        return results.sorted { result1, result2 in
            if result1.priority != result2.priority {
                return result1.priority > result2.priority
            }
            return result1.distance < result2.distance
        }
    }
    
    static func filterByAvailability(chargers: [ChargerResult], includeUnknown: Bool = true) -> [ChargerResult] {
        return chargers.filter { result in
            switch result.charger.availability {
            case .available:
                return true
            case .unknown:
                return includeUnknown
            case .occupied, .outOfOrder:
                return false
            }
        }
    }
    
    static func filterByPowerRating(chargers: [ChargerResult], minimumPower: Int = 150) -> [ChargerResult] {
        return chargers.filter { $0.charger.powerRating >= minimumPower }
    }
    
    static func filterByAmenities(chargers: [ChargerResult], requiresFastFood: Bool = false) -> [ChargerResult] {
        if !requiresFastFood {
            return chargers
        }
        return chargers.filter { $0.charger.amenities.hasFastFood }
    }
    
    private static func calculateArrivalRange(userRange: RemainingRange, distance: Double) -> Int {
        let consumptionRate = 0.2 // kWh per km (approximate for EQB)
        let batteryCapacity = 66.5 // kWh for EQB
        let currentSoC = Double(userRange.rawValue) / 300.0 // Estimate SoC based on range
        
        let energyNeeded = distance * consumptionRate
        let energyRemaining = (currentSoC * batteryCapacity) - energyNeeded
        let rangeRemaining = (energyRemaining / batteryCapacity) * 300.0
        
        return max(0, Int(rangeRemaining))
    }
    
    private static func calculatePriority(charger: Charger, distance: Double, userRange: RemainingRange) -> Int {
        var priority = 100
        
        // Prefer closer chargers when range is low
        if userRange.rawValue <= 40 {
            priority += Int(50 - distance) // Closer is better when low on range
        }
        
        // Bonus for higher power rating
        if charger.powerRating >= 300 {
            priority += 20
        } else if charger.powerRating >= 200 {
            priority += 10
        }
        
        // Bonus for available chargers
        switch charger.availability {
        case .available:
            priority += 30
        case .unknown:
            priority += 10
        case .occupied:
            priority -= 20
        case .outOfOrder:
            priority -= 50
        }
        
        // Bonus for amenities
        if charger.amenities.hasFastFood {
            priority += 15
        }
        
        if charger.amenities.hasRestrooms {
            priority += 5
        }
        
        // Bonus for good user ratings
        if let rating = charger.userRating {
            priority += Int(rating * 10)
        }
        
        // Penalty for requiring highway crossing
        if charger.highwayAccess.requiresCrossing {
            priority -= 25
        }
        
        // Penalty for being far from highway
        if charger.highwayAccess.distanceFromHighway > 1000 {
            priority -= 15
        }
        
        return max(0, priority)
    }
    
    static func groupByHighwaySegment(chargers: [ChargerResult]) -> [String: [ChargerResult]] {
        return Dictionary(grouping: chargers) { result in
            DirectionUtils.getHighwaySegment(for: CLLocationCoordinate2D(
                latitude: result.charger.location.latitude,
                longitude: result.charger.location.longitude
            ))
        }
    }
    
    static func findNearestCharger(to location: CLLocationCoordinate2D, from chargers: [Charger]) -> Charger? {
        return chargers.min { charger1, charger2 in
            let distance1 = DirectionUtils.calculateDistance(from: location, to: charger1.location)
            let distance2 = DirectionUtils.calculateDistance(from: location, to: charger2.location)
            return distance1 < distance2
        }
    }
}

struct ChargerResult: Identifiable {
    let id = UUID()
    let charger: Charger
    let distance: Double
    let timeToCharger: TimeInterval
    let isReachable: Bool
    let estimatedArrivalRange: Int
    let priority: Int
    
    var formattedDistance: String {
        return DirectionUtils.formatDistance(distance)
    }
    
    var formattedTime: String {
        return DirectionUtils.formatTime(timeToCharger)
    }
    
    var isUrgent: Bool {
        return estimatedArrivalRange < 20
    }
}