import Foundation
import Combine

class ChargerService: ObservableObject {
    @Published var chargers: [Charger] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMockData()
    }
    
    func fetchChargers(for direction: TravelDirection, range: RemainingRange) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.chargers = self.filterChargers(for: direction, range: range)
            self.isLoading = false
        }
    }
    
    private func filterChargers(for direction: TravelDirection, range: RemainingRange) -> [Charger] {
        let filteredChargers = mockChargers.filter { charger in
            let highwayDirection = charger.highwayAccess.direction
            let travelDirection = direction
            
            return highwayDirection.isCompatible(with: travelDirection) && 
                   charger.powerRating >= 150 &&
                   isWithinRange(charger, range: range)
        }
        
        return filteredChargers.sorted { charger1, charger2 in
            getDistanceToCharger(charger1) < getDistanceToCharger(charger2)
        }
    }
    
    private func isWithinRange(_ charger: Charger, range: RemainingRange) -> Bool {
        let distanceToCharger = getDistanceToCharger(charger)
        let rangeInKm = Double(range.rawValue)
        let safetyBuffer = 0.8
        
        return distanceToCharger <= (rangeInKm * safetyBuffer)
    }
    
    private func getDistanceToCharger(_ charger: Charger) -> Double {
        return Double.random(in: 15...200)
    }
    
    private func loadMockData() {
        chargers = mockChargers
    }
}

private let mockChargers: [Charger] = [
    Charger(
        name: "Ionity Aire de Repos A1",
        location: ChargerLocation(
            latitude: 50.1234,
            longitude: 4.5678,
            address: "Aire de Repos A1",
            city: "Seclin",
            country: "France",
            postalCode: "59113"
        ),
        powerRating: 350,
        connectorTypes: [.ccs2],
        availability: .available,
        amenities: ChargerAmenities(
            hasFastFood: true,
            fastFoodRestaurants: ["McDonald's", "Shell Select"],
            hasRestrooms: true,
            hasWifi: true,
            hasShopping: true,
            hasParking: true,
            isAccessible: true
        ),
        highwayAccess: HighwayAccess(
            highwayName: "A1",
            direction: .rotterdamToSantaPola,
            exitNumber: "17",
            accessInstructions: "Exit 17, follow signs to Aire de Repos",
            distanceFromHighway: 200,
            requiresCrossing: false
        ),
        operatorInfo: OperatorInfo(
            name: "Ionity",
            network: "Ionity",
            supportPhone: "+33123456789",
            appName: "Ionity App"
        ),
        pricing: PricingInfo(
            pricePerKwh: 0.69,
            pricePerMinute: nil,
            connectionFee: nil,
            currency: "EUR"
        ),
        userRating: 4.2
    ),
    
    Charger(
        name: "Fastned Utrecht",
        location: ChargerLocation(
            latitude: 52.0907,
            longitude: 5.1214,
            address: "Laagraven 22",
            city: "Utrecht",
            country: "Netherlands",
            postalCode: "3439 LC"
        ),
        powerRating: 300,
        connectorTypes: [.ccs2, .chademo],
        availability: .occupied,
        amenities: ChargerAmenities(
            hasFastFood: true,
            fastFoodRestaurants: ["Burger King"],
            hasRestrooms: true,
            hasWifi: false,
            hasShopping: false,
            hasParking: true,
            isAccessible: true
        ),
        highwayAccess: HighwayAccess(
            highwayName: "A2",
            direction: .santaPolaToRotterdam,
            exitNumber: "5",
            accessInstructions: "Exit 5 Utrecht-Noord, turn right at roundabout",
            distanceFromHighway: 500,
            requiresCrossing: false
        ),
        operatorInfo: OperatorInfo(
            name: "Fastned",
            network: "Fastned",
            supportPhone: "+31201234567",
            appName: "Fastned App"
        ),
        pricing: PricingInfo(
            pricePerKwh: 0.59,
            pricePerMinute: nil,
            connectionFee: nil,
            currency: "EUR"
        ),
        userRating: 4.5
    ),
    
    Charger(
        name: "Electromaps Valencia Norte",
        location: ChargerLocation(
            latitude: 39.5021,
            longitude: -0.4156,
            address: "AP-7 Km 362",
            city: "Valencia",
            country: "Spain",
            postalCode: "46016"
        ),
        powerRating: 150,
        connectorTypes: [.ccs2],
        availability: .available,
        amenities: ChargerAmenities(
            hasFastFood: true,
            fastFoodRestaurants: ["Telepizza", "Repsol Café"],
            hasRestrooms: true,
            hasWifi: true,
            hasShopping: true,
            hasParking: true,
            isAccessible: false
        ),
        highwayAccess: HighwayAccess(
            highwayName: "AP-7",
            direction: .both,
            exitNumber: "362",
            accessInstructions: "Área de Servicio Valencia Norte",
            distanceFromHighway: 100,
            requiresCrossing: false
        ),
        operatorInfo: OperatorInfo(
            name: "Electromaps",
            network: "Electromaps",
            supportPhone: "+34912345678",
            appName: "Electromaps"
        ),
        pricing: PricingInfo(
            pricePerKwh: 0.45,
            pricePerMinute: nil,
            connectionFee: 1.0,
            currency: "EUR"
        ),
        userRating: 3.8
    )
]