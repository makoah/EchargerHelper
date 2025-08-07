import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userPreferences = UserPreferences()
    @StateObject private var chargerService = ChargerService()
    
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "bolt.car")
                            .foregroundColor(.secondaryBlue)
                        VStack(alignment: .leading) {
                            Text("ECharger Helper")
                                .font(.headline)
                            Text("Version 1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("App Information")
                }
                
                Section {
                    if userPreferences.blacklistedChargers.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.successGreen)
                            Text("No incompatible chargers marked")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ForEach(Array(userPreferences.blacklistedChargers), id: \.self) { chargerId in
                            BlacklistedChargerRow(
                                chargerId: chargerId,
                                onRemove: {
                                    userPreferences.removeFromBlacklist(chargerId)
                                }
                            )
                        }
                        
                        Button(action: {
                            showingClearConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.errorRed)
                                Text("Clear All")
                                    .foregroundColor(.errorRed)
                            }
                        }
                    }
                } header: {
                    Text("Incompatible Chargers")
                } footer: {
                    Text("Chargers marked as incompatible with your charge tag will not appear in search results. You can remove them here if they become compatible.")
                }
                
                Section {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Vehicle")
                            Text("Mercedes EQB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "road.lanes")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Route")
                            Text("Rotterdam ↔ Santa Pola")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.powerYellow)
                        VStack(alignment: .leading) {
                            Text("Charger Type")
                            Text("Ultra-fast DC (150kW+)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                } header: {
                    Text("Configuration")
                }
                
                Section {
                    if let supportURL = URL(string: "mailto:support@echargerhelper.com") {
                        Link(destination: supportURL) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.secondaryBlue)
                                Text("Contact Support")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let privacyURL = URL(string: "https://echargerhelper.com/privacy") {
                        Link(destination: privacyURL) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundColor(.secondaryBlue)
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear All Incompatible Chargers", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    userPreferences.clearAllBlacklisted()
                }
            } message: {
                Text("This will remove all chargers from your incompatible list. They will appear in search results again.")
            }
        }
    }
}

struct BlacklistedChargerRow: View {
    let chargerId: UUID
    let onRemove: () -> Void
    
    @State private var chargerName: String = "Unknown Charger"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(chargerName)
                    .font(.body)
                
                Text("Marked as incompatible")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.errorRed)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            loadChargerName()
        }
    }
    
    private func loadChargerName() {
        // In a real app, you'd look up the charger name by ID
        // For now, we'll use a simplified approach
        chargerName = "Charger \(chargerId.uuidString.prefix(8))"
    }
}

#Preview {
    SettingsView()
}