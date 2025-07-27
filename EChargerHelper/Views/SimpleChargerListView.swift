import SwiftUI
import CoreLocation

struct SimpleChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chargerService = RealChargerService()
    @State private var debugMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if chargerService.isLoading {
                    VStack {
                        ProgressView()
                            .padding()
                        Text("Finding chargers...")
                            .font(.headline)
                    }
                } else if chargerService.chargerResults.isEmpty {
                    VStack {
                        Text("No chargers found")
                            .font(.headline)
                            .padding()
                        
                        if let errorMessage = chargerService.errorMessage {
                            Text("Error: \(errorMessage)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Text("Direction: \(direction == .rotterdamToSantaPola ? "Rotterdam → Santa Pola" : "Santa Pola → Rotterdam")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Range: \(range.rawValue) km")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Test API") {
                            Task {
                                if let realService = chargerService as? RealChargerService {
                                    let result = await realService.testAPIConnectivity()
                                    debugMessage = result
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding()
                        
                        if !debugMessage.isEmpty {
                            Text("Debug: \(debugMessage)")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                } else {
                    List(chargerService.chargerResults, id: \.charger.id) { result in
                        ChargerRowView(chargerResult: result) { chargerId in
                            chargerService.blacklistCharger(chargerId)
                        }
                    }
                }
            }
            .navigationTitle("Available Chargers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Test with Rotterdam coordinates for now
                let testLocation = CLLocationCoordinate2D(latitude: 51.9225, longitude: 4.4792)
                chargerService.fetchChargers(for: direction, range: range, userLocation: testLocation)
            }
        }
    }
}