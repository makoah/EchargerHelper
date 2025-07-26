import Foundation

struct Charger: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: ChargerLocation
    let powerRating: Int
    let connectorTypes: [ChargerConnectorType]
    let availability: ChargerAvailabilityStatus
    let amenities: ChargerAmenities
    let highwayAccess: HighwayAccess
    let operatorInfo: ChargerOperatorInfo
    let pricing: PricingInfo?
    let userRating: Double?
    let lastUpdated: Date
    
    init(id: UUID = UUID(), name: String, location: ChargerLocation, powerRating: Int, connectorTypes: [ChargerConnectorType], availability: ChargerAvailabilityStatus, amenities: ChargerAmenities, highwayAccess: HighwayAccess, operatorInfo: ChargerOperatorInfo, pricing: PricingInfo? = nil, userRating: Double? = nil, lastUpdated: Date = Date()) {
        self.id = id
        self.name = name
        self.location = location
        self.powerRating = powerRating
        self.connectorTypes = connectorTypes
        self.availability = availability
        self.amenities = amenities
        self.highwayAccess = highwayAccess
        self.operatorInfo = operatorInfo
        self.pricing = pricing
        self.userRating = userRating
        self.lastUpdated = lastUpdated
    }
}

struct ChargerLocation: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
    let city: String
    let country: String
    let postalCode: String
}

struct ChargerAmenities: Codable {
    let hasFastFood: Bool
    let fastFoodRestaurants: [String]
    let hasRestrooms: Bool
    let hasWifi: Bool
    let hasShopping: Bool
    let hasParking: Bool
    let isAccessible: Bool
}

struct HighwayAccess: Codable {
    let highwayName: String
    let direction: HighwayDirection
    let exitNumber: String?
    let accessInstructions: String
    let distanceFromHighway: Int
    let requiresCrossing: Bool
}

struct ChargerOperatorInfo: Codable {
    let name: String
    let network: String
    let supportPhone: String?
    let appName: String?
}

struct PricingInfo: Codable {
    let pricePerKwh: Double?
    let pricePerMinute: Double?
    let connectionFee: Double?
    let currency: String
}

enum ChargerConnectorType: String, CaseIterable, Codable {
    case ccs2 = "CCS2"
    case chademo = "CHAdeMO"
    case type2 = "Type2"
    case tesla = "Tesla"
    
    var displayName: String {
        switch self {
        case .ccs2:
            return "CCS2 (Combined Charging System)"
        case .chademo:
            return "CHAdeMO"
        case .type2:
            return "Type 2 (AC)"
        case .tesla:
            return "Tesla Supercharger"
        }
    }
}

enum ChargerAvailabilityStatus: String, CaseIterable, Codable {
    case available = "available"
    case occupied = "occupied"
    case outOfOrder = "out_of_order"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .available:
            return "Available"
        case .occupied:
            return "Occupied"
        case .outOfOrder:
            return "Out of Order"
        case .unknown:
            return "Status Unknown"
        }
    }
    
    var color: String {
        switch self {
        case .available:
            return "green"
        case .occupied:
            return "orange"
        case .outOfOrder:
            return "red"
        case .unknown:
            return "gray"
        }
    }
}

enum HighwayDirection: String, CaseIterable, Codable {
    case rotterdamToSantaPola = "rotterdam_to_santa_pola"
    case santaPolaToRotterdam = "santa_pola_to_rotterdam"
    case both = "both_directions"
    
    var displayName: String {
        switch self {
        case .rotterdamToSantaPola:
            return "Rotterdam → Santa Pola"
        case .santaPolaToRotterdam:
            return "Santa Pola → Rotterdam"
        case .both:
            return "Both Directions"
        }
    }
    
    func isCompatible(with travelDirection: TravelDirection) -> Bool {
        switch self {
        case .both:
            return true
        case .rotterdamToSantaPola:
            return travelDirection == .rotterdamToSantaPola
        case .santaPolaToRotterdam:
            return travelDirection == .santaPolaToRotterdam
        }
    }
}