import SwiftUI
import CoreLocation

struct ChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    @StateObject private var chargerService = ChargerService()
    @State private var showingSettings = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if chargerService.isLoading {
                    ProgressView("Finding chargers...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if chargerService.chargerResults.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bolt.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No chargers found")
                            .font(.headline)
                        
                        Text("No compatible chargers found for your route and range. Try increasing your range or check your direction.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Refresh") {
                            fetchChargers()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ForEach(chargerService.chargerResults) { result in
                                ChargerRowView(
                                    chargerResult: result,
                                    onBlacklistToggle: { chargerId in
                                        toggleBlacklist(chargerId)
                                    }
                                )
                            }
                        } header: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Route: \(direction.displayName)")
                                        .font(.caption)
                                    Text("Range: \(range.rawValue) km remaining")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Text("\(chargerService.chargerResults.count) charger\(chargerService.chargerResults.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .refreshable {
                        chargerService.refreshAvailability()
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Refresh") {
                            fetchChargers()
                        }
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                fetchChargers()
            }
        }
    }
    
    private func fetchChargers() {
        chargerService.fetchChargers(for: direction, range: range)
    }
    
    private func toggleBlacklist(_ chargerId: UUID) {
        if chargerService.isChargerBlacklisted(chargerId) {
            chargerService.removeFromBlacklist(chargerId)
        } else {
            chargerService.blacklistCharger(chargerId)
        }
    }
}