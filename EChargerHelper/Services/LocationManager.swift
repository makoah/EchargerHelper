import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        // Optimize for battery life on iPhone 12 Pro
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        // Reduce power consumption
        locationManager.distanceFilter = 100 // Only update if moved 100m
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = getUserFriendlyLocationMessage(for: authorizationStatus)
            return
        }
        
        // Clear any previous errors when making a new request
        errorMessage = nil
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    deinit {
        // Ensure location services are properly stopped
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    // MARK: - User-Friendly Messages
    
    private func getUserFriendlyLocationMessage(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .denied:
            return "Location access is required to find chargers near you. Please go to Settings > Privacy & Security > Location Services > ECharger Helper and select 'While Using App'."
        case .restricted:
            return "Location services are restricted on this device. Please check your device restrictions or contact your administrator."
        case .notDetermined:
            return "We need location access to find nearby chargers. Tap 'Allow' when prompted."
        default:
            return "Location service unavailable. Please check your settings."
        }
    }
    
    /// Provides context-specific guidance for location permission issues
    func getLocationGuidanceMessage() -> String {
        switch authorizationStatus {
        case .denied:
            return "🗺️ To find chargers near you:\n\n1. Open Settings\n2. Tap Privacy & Security\n3. Tap Location Services\n4. Find ECharger Helper\n5. Select 'While Using App'"
        case .restricted:
            return "📱 Location services are restricted on this device. Check with your device administrator if this is a managed device."
        case .notDetermined:
            return "📍 We'll ask for location permission to show nearby chargers along your route."
        case .authorizedWhenInUse, .authorizedAlways:
            return "✅ Location access is enabled. We can find chargers near your current position."
        @unknown default:
            return "❓ Location status unknown. Try restarting the app."
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        errorMessage = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = getLocationErrorMessage(for: error)
    }
    
    /// Converts location errors into user-friendly messages with actionable guidance
    private func getLocationErrorMessage(for error: Error) -> String {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                return "Unable to find your location. Please ensure you're in an area with good GPS reception and try again."
            case .denied:
                return "Location access denied. Go to Settings > Privacy & Security > Location Services > ECharger Helper and select 'While Using App'."
            case .network:
                return "Network error while getting location. Please check your internet connection and try again."
            case .headingFailure:
                return "Compass not available. Location services will work without compass features."
            case .rangingUnavailable, .rangingFailure:
                return "Precision location services unavailable. Basic location will still work."
            case .promptDeclined:
                return "Location permission was declined. Enable location access in Settings to find nearby chargers."
            case .regionMonitoringDenied, .regionMonitoringFailure:
                return "Region monitoring unavailable. Basic location services will still work."
            case .regionMonitoringSetupDelayed:
                return "Location services starting up. Please wait a moment and try again."
            case .regionMonitoringResponseDelayed:
                return "Location response delayed. Please wait a moment for GPS to acquire signal."
            default:
                return "Location error: \(clError.localizedDescription). Please try again or check your device's location settings."
            }
        } else {
            return "Unable to access location services. Please ensure location access is enabled in Settings."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .denied, .restricted:
            errorMessage = getUserFriendlyLocationMessage(for: status)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}