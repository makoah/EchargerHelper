import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "location.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Location Permission")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("ECharger Helper needs location access to find nearby chargers along your route")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Status-specific content
                VStack(spacing: 16) {
                    StatusCard(
                        authorizationStatus: locationManager.authorizationStatus,
                        guidanceMessage: locationManager.getLocationGuidanceMessage()
                    )
                    
                    if locationManager.authorizationStatus == .denied {
                        Button(action: openSettings) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Open Settings")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    } else if locationManager.authorizationStatus == .notDetermined {
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            HStack {
                                Image(systemName: "location")
                                Text("Enable Location Access")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Location Access")
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
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct StatusCard: View {
    let authorizationStatus: CLAuthorizationStatus
    let guidanceMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                statusIcon
                Text(statusTitle)
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            Text(guidanceMessage)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var statusIcon: some View {
        let (iconName, color) = iconInfo
        return Image(systemName: iconName)
            .foregroundColor(color)
    }
    
    private var statusTitle: String {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location Enabled"
        case .denied:
            return "Location Denied"
        case .restricted:
            return "Location Restricted"
        case .notDetermined:
            return "Location Permission Needed"
        @unknown default:
            return "Location Status Unknown"
        }
    }
    
    private var iconInfo: (String, Color) {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return ("checkmark.circle.fill", .green)
        case .denied:
            return ("xmark.circle.fill", .red)
        case .restricted:
            return ("exclamationmark.triangle.fill", .orange)
        case .notDetermined:
            return ("questionmark.circle.fill", .blue)
        @unknown default:
            return ("questionmark.circle", .gray)
        }
    }
}

#Preview {
    LocationPermissionView(locationManager: LocationManager())
}