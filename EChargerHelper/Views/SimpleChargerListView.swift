import SwiftUI

struct SimpleChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chargerService = ChargerService()
    
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
                        
                        Text("Direction: \(direction == .rotterdamToSantaPola ? "Rotterdam → Santa Pola" : "Santa Pola → Rotterdam")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Range: \(range.rawValue) km")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                chargerService.fetchChargers(for: direction, range: range)
            }
        }
    }
}