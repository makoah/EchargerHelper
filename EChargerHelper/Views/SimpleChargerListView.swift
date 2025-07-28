import SwiftUI
import CoreLocation

struct SimpleChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chargerService = RealChargerService()
    
    var body: some View {
        NavigationView {
            VStack {
                if chargerService.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding()
                        
                        Text("Finding Chargers")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("Searching for fast chargers along your route")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if chargerService.chargerResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "ev.charger.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Text("No Chargers Found")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("No fast chargers found within \(range.rawValue)km along your route. Try increasing your search range or check a different area.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.blue)
                                Text(direction == .rotterdamToSantaPola ? "Rotterdam → Santa Pola" : "Santa Pola → Rotterdam")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "battery.25")
                                    .foregroundColor(.orange)
                                Text("\(range.rawValue) km range")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top)
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
                // Use GPS location instead of fixed coordinates
                chargerService.fetchChargers(for: direction, range: range, userLocation: nil)
            }
        }
    }
}