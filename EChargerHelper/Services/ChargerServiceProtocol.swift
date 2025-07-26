import Foundation
import Combine
import CoreLocation

protocol ChargerServiceProtocol: ObservableObject {
    var chargerResults: [ChargerResult] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func fetchChargers(for direction: TravelDirection, range: RemainingRange, userLocation: CLLocationCoordinate2D?)
    func blacklistCharger(_ chargerId: UUID)
    func removeFromBlacklist(_ chargerId: UUID)
    func isChargerBlacklisted(_ chargerId: UUID) -> Bool
    func refreshAvailability()
}