import Foundation
import Combine

protocol ChargerServiceProtocol: ObservableObject {
    var chargerResults: [ChargerResult] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
}