import SwiftUI
import CoreLocation

struct ChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    @StateObject private var chargerService = ChargerService()
    @StateObject private var realChargerService = RealChargerService()
    @StateObject private var locationManager = LocationManager()
    @State private var showingSettings = false
    @State private var useRealData = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if currentService.isLoading {
                    ProgressView("Finding chargers...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if currentService.chargerResults.isEmpty {
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
                            ForEach(currentService.chargerResults) { result in
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
                                
                                Text("\(currentService.chargerResults.count) charger\(currentService.chargerResults.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .refreshable {
                        if useRealData {
                            realChargerService.fetchRealChargers(for: direction, range: range)
                        } else {
                            chargerService.refreshAvailability()
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(useRealData ? "Real" : "Mock") {
                            useRealData.toggle()
                            fetchChargers()
                        }
                        .font(.caption)
                        .foregroundColor(useRealData ? .green : .orange)
                        
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
    
    private var currentService: any ChargerServiceProtocol {
        useRealData ? realChargerService : chargerService
    }
    
    private func fetchChargers() {
        if useRealData {
            realChargerService.fetchRealChargers(for: direction, range: range)
        } else {
            chargerService.fetchChargers(for: direction, range: range)
        }
    }
    
    private func toggleBlacklist(_ chargerId: UUID) {
        if chargerService.isChargerBlacklisted(chargerId) {
            chargerService.removeFromBlacklist(chargerId)
        } else {
            chargerService.blacklistCharger(chargerId)
        }
    }
}