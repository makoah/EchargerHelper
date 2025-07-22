import SwiftUI

struct ChargerRowView: View {
    let chargerResult: ChargerResult
    let onBlacklistToggle: (UUID) -> Void
    
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and distance
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(chargerResult.charger.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(chargerResult.charger.location.city), \(chargerResult.charger.location.country)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(chargerResult.formattedDistance)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(chargerResult.formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Status and power info
            HStack {
                // Availability status
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(chargerResult.charger.availability.displayName)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                // Power rating
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(chargerResult.charger.powerRating) kW")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Range on arrival
                if chargerResult.estimatedArrivalRange < 30 {
                    HStack(spacing: 4) {
                        Image(systemName: "battery.25")
                            .font(.caption)
                            .foregroundColor(chargerResult.isUrgent ? .red : .orange)
                        Text("\(chargerResult.estimatedArrivalRange)km left")
                            .font(.caption)
                            .foregroundColor(chargerResult.isUrgent ? .red : .orange)
                    }
                }
            }
            
            // Amenities
            if chargerResult.charger.amenities.hasFastFood || chargerResult.charger.amenities.hasRestrooms {
                HStack(spacing: 12) {
                    if chargerResult.charger.amenities.hasFastFood {
                        HStack(spacing: 4) {
                            Image(systemName: "fork.knife")
                                .font(.caption)
                                .foregroundColor(.green)
                            if !chargerResult.charger.amenities.fastFoodRestaurants.isEmpty {
                                Text(chargerResult.charger.amenities.fastFoodRestaurants.first ?? "Food")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("Restaurant")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    if chargerResult.charger.amenities.hasRestrooms {
                        HStack(spacing: 4) {
                            Image(systemName: "toilet")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("Restrooms")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Action buttons
            HStack {
                Button(action: {
                    showingDetails = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                        Text("Details")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                
                Spacer()
                
                Button(action: {
                    onBlacklistToggle(chargerResult.charger.id)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption)
                        Text("Incompatible")
                            .font(.caption)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .tint(.red)
                
                if let rating = chargerResult.charger.userRating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingDetails) {
            ChargerDetailView(charger: chargerResult.charger)
        }
    }
    
    private var statusColor: Color {
        switch chargerResult.charger.availability {
        case .available:
            return .green
        case .occupied:
            return .orange
        case .outOfOrder:
            return .red
        case .unknown:
            return .gray
        }
    }
}

struct ChargerDetailView: View {
    let charger: Charger
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Basic info section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Charger Information")
                            .font(.headline)
                        
                        InfoRow(label: "Power", value: "\(charger.powerRating) kW")
                        InfoRow(label: "Operator", value: charger.operatorInfo.name)
                        InfoRow(label: "Network", value: charger.operatorInfo.network)
                        
                        if let pricing = charger.pricing {
                            if let pricePerKwh = pricing.pricePerKwh {
                                InfoRow(label: "Price", value: String(format: "%.2f %@/kWh", pricePerKwh, pricing.currency))
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Location section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.headline)
                        
                        InfoRow(label: "Address", value: charger.location.address)
                        InfoRow(label: "City", value: "\(charger.location.city), \(charger.location.country)")
                        InfoRow(label: "Highway", value: charger.highwayAccess.highwayName)
                        
                        if let exitNumber = charger.highwayAccess.exitNumber {
                            InfoRow(label: "Exit", value: exitNumber)
                        }
                        
                        InfoRow(label: "Access", value: charger.highwayAccess.accessInstructions)
                    }
                    
                    Divider()
                    
                    // Amenities section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amenities")
                            .font(.headline)
                        
                        if charger.amenities.hasFastFood {
                            AmenityRow(icon: "fork.knife", text: "Fast Food", details: charger.amenities.fastFoodRestaurants.joined(separator: ", "))
                        }
                        
                        if charger.amenities.hasRestrooms {
                            AmenityRow(icon: "toilet", text: "Restrooms")
                        }
                        
                        if charger.amenities.hasWifi {
                            AmenityRow(icon: "wifi", text: "WiFi")
                        }
                        
                        if charger.amenities.hasShopping {
                            AmenityRow(icon: "bag", text: "Shopping")
                        }
                        
                        if charger.amenities.isAccessible {
                            AmenityRow(icon: "figure.roll", text: "Wheelchair Accessible")
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(charger.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct AmenityRow: View {
    let icon: String
    let text: String
    let details: String?
    
    init(icon: String, text: String, details: String? = nil) {
        self.icon = icon
        self.text = text
        self.details = details
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.green)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.body)
                
                if let details = details, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}