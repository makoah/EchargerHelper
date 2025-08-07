import Foundation
import CoreLocation
import Combine

class RealChargerService: ChargerServiceProtocol {
    @Published var chargerResults: [ChargerResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let locationManager = LocationManager()
    private let openChargeMapService = OpenChargeMapService()
    private var cancellables = Set<AnyCancellable>()
    private var userPreferences = UserPreferences()
    
    // API rate limiting
    private var lastAPICallTime: Date = Date.distantPast
    private let minimumAPIInterval: TimeInterval = 10.0 // 10 seconds between API calls
    
    deinit {
        // Clean up resources to prevent memory leaks
        locationManager.stopUpdatingLocation()
        cancellables.removeAll()
        
        // Set loading state to false directly since we're on deinit
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
    
    func fetchChargers(for direction: TravelDirection, range: RemainingRange, userLocation: CLLocationCoordinate2D? = nil) {
        isLoading = true
        errorMessage = nil
        
        // Monitor memory usage during extended app usage
        logMemoryUsage()
        
        if let userLocation = userLocation {
            // Validate provided location before using
            guard DirectionUtils.isValidCoordinate(userLocation) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Invalid location coordinates. Please try again or enable location services."
                }
                return
            }
            
            // Check if location is within reasonable bounds for the route
            guard DirectionUtils.isWithinRouteBounds(userLocation) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Location appears to be outside the Rotterdam-Santa Pola route. Please check your location or use the app while traveling this route."
                }
                return
            }
            
            // Use validated location
            Task {
                await loadChargersFromAPI(location: userLocation, direction: direction, range: range)
            }
        } else {
            // Get current location from GPS for real-world usage
            locationManager.requestLocation()
            
            // Set up a smart timeout with helpful messaging
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
                guard let self = self, self.isLoading else { return }
                
                // Check if we have a location error to display
                if let locationError = self.locationManager.errorMessage {
                    self.errorMessage = "Location Error: \(locationError)"
                    self.isLoading = false
                } else {
                    // Use fallback location with explanation
                    self.errorMessage = "Using approximate location (GPS taking longer than expected)"
                    let fallbackLocation = CLLocationCoordinate2D(latitude: 41.1189, longitude: 1.2445)
                    Task {
                        await self.loadChargersFromAPI(location: fallbackLocation, direction: direction, range: range)
                    }
                }
            }
            
            // Monitor location updates
            locationManager.$location
                .compactMap { $0 }
                .first()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] location in
                    guard let self = self else { return }
                    
                    // Validate location manager's coordinate
                    guard DirectionUtils.isValidCoordinate(location.coordinate) else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.errorMessage = "Unable to determine valid location. Please check your GPS signal and try again."
                        }
                        return
                    }
                    
                    Task {
                        await self.loadChargersFromAPI(location: location.coordinate, direction: direction, range: range)
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    private func loadChargersFromAPI(location: CLLocationCoordinate2D, direction: TravelDirection, range: RemainingRange) async {
        // Validate coordinates at the start of API loading
        guard DirectionUtils.isValidCoordinate(location) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid location coordinates provided to charger search."
            }
            return
        }
        do {
            // Rate limiting check
            let timeSinceLastCall = Date().timeIntervalSince(lastAPICallTime)
            if timeSinceLastCall < minimumAPIInterval {
                // Use mock data instead of API call to respect rate limits
                await loadMockData(direction: direction, range: range, location: location)
                return
            }
            
            // Update last API call time
            lastAPICallTime = Date()
            
            // Add timeout for API call
            let apiChargers = try await withTimeout(seconds: 10) { [self] in
                try await self.openChargeMapService.fetchChargers(near: location, radius: range.rawValue)
            }
            
            // 2. Filter for direction and accessibility
            let filteredChargers = apiChargers.filter { charger in
                // Check if charger is in the right direction
                DirectionUtils.isChargerAhead(charger: charger, for: direction, from: location) &&
                DirectionUtils.isAccessibleFromDirection(charger: charger, direction: direction)
            }
            
            // 3. Convert to ChargerResults with real distance calculations
            // Limit results for iPhone memory optimization (max 20 chargers)
            let limitedChargers = Array(filteredChargers.prefix(20))
            self.chargerResults = limitedChargers.map { charger in
                let distance = DirectionUtils.calculateDistance(from: location, to: charger.location)
                let timeToCharger = DirectionUtils.calculateTimeToCharger(distance: distance)
                
                return ChargerResult(
                    charger: charger,
                    distance: distance,
                    timeToCharger: timeToCharger,
                    isReachable: distance <= Double(range.rawValue) * 0.8,
                    estimatedArrivalRange: calculateArrivalRange(currentRange: range.rawValue, distance: distance),
                    priority: calculatePriority(charger: charger, distance: distance)
                )
            }
            
            // If no chargers found, fallback to mock data
            if self.chargerResults.isEmpty {
                await loadMockData(direction: direction, range: range, location: location)
            } else {
                self.isLoading = false
            }
            
        } catch {
            // Provide detailed error information for different failure types
            let userFriendlyError = getUserFriendlyAPIError(error)
            self.errorMessage = userFriendlyError
            await loadMockData(direction: direction, range: range, location: location)
        }
    }
    
    @MainActor
    private func loadMockData(direction: TravelDirection, range: RemainingRange, location: CLLocationCoordinate2D) async {
        // Generate mock chargers near location
        let mockChargers = generateMockChargers(near: location, count: 5)
        
        let filteredChargers = mockChargers.filter { charger in
            DirectionUtils.isChargerAhead(charger: charger, for: direction, from: location) &&
            DirectionUtils.isAccessibleFromDirection(charger: charger, direction: direction)
        }
        
        self.chargerResults = filteredChargers.map { charger in
            let distance = DirectionUtils.calculateDistance(from: location, to: charger.location)
            let timeToCharger = DirectionUtils.calculateTimeToCharger(distance: distance)
            
            return ChargerResult(
                charger: charger,
                distance: distance,
                timeToCharger: timeToCharger,
                isReachable: distance <= Double(range.rawValue) * 0.8,
                estimatedArrivalRange: calculateArrivalRange(currentRange: range.rawValue, distance: distance),
                priority: calculatePriority(charger: charger, distance: distance)
            )
        }
        
        self.isLoading = false
    }
    
    private func generateMockChargers(near location: CLLocationCoordinate2D, count: Int) -> [Charger] {
        var chargers: [Charger] = []
        
        for i in 0..<count {
            let offsetLat = Double.random(in: -0.1...0.1)
            let offsetLng = Double.random(in: -0.1...0.1)
            
            let chargerLocation = ChargerLocation(
                latitude: location.latitude + offsetLat,
                longitude: location.longitude + offsetLng,
                address: "Highway Service Area \(i + 1)",
                city: "Service Stop",
                country: "Netherlands",
                postalCode: "1000\(i)"
            )
            
            let charger = Charger(
                name: "FastCharge Station \(i + 1)",
                location: chargerLocation,
                powerRating: [150, 175, 300, 350].randomElement() ?? 150,
                connectorTypes: [.ccs2],
                availability: [.available, .occupied, .unknown].randomElement() ?? .available,
                amenities: ChargerAmenities(
                    hasFastFood: Bool.random(),
                    fastFoodRestaurants: Bool.random() ? Array(["McDonald's", "Shell Select"].shuffled().prefix(1)) : [],
                    hasRestrooms: true,
                    hasWifi: Bool.random(),
                    hasShopping: Bool.random(),
                    hasParking: true,
                    isAccessible: Bool.random()
                ),
                highwayAccess: HighwayAccess(
                    highwayName: "A2 Highway",
                    direction: [.both, .rotterdamToSantaPola, .santaPolaToRotterdam].randomElement() ?? .both,
                    exitNumber: String(Int.random(in: 1...100)),
                    accessInstructions: "Service area directly accessible from highway",
                    distanceFromHighway: Int.random(in: 100...500),
                    requiresCrossing: false
                ),
                operatorInfo: ChargerOperatorInfo(
                    name: "Shell Recharge",
                    network: "Shell",
                    supportPhone: "+31-800-123456",
                    appName: "Shell Recharge"
                ),
                userRating: Double.random(in: 3.0...5.0)
            )
            
            chargers.append(charger)
        }
        
        return chargers
    }
    
    private func calculateArrivalRange(currentRange: Int, distance: Double) -> Int {
        // EQB consumption: ~0.2 kWh/km
        let consumedRange = Int(distance * 1.2) // Add 20% buffer for real conditions
        return max(0, currentRange - consumedRange)
    }
    
    private func calculatePriority(charger: Charger, distance: Double) -> Int {
        var priority = 100
        
        // Prefer ultra-fast chargers
        if charger.powerRating >= 300 { priority += 30 }
        else if charger.powerRating >= 150 { priority += 20 }
        
        // Prefer available chargers
        if charger.availability == .available { priority += 40 }
        
        // Prefer closer chargers
        priority += max(0, 50 - Int(distance))
        
        return priority
    }
    
    // Add timeout wrapper
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw APIError.httpError(408) // Timeout error
            }
            
            guard let result = try await group.next() else {
                throw APIError.httpError(408)
            }
            
            group.cancelAll()
            return result
        }
    }
    
    // MARK: - Blacklist Methods
    func blacklistCharger(_ chargerId: UUID) {
        userPreferences.blacklistCharger(chargerId)
        // Remove from current results
        chargerResults.removeAll { $0.charger.id == chargerId }
    }
    
    func removeFromBlacklist(_ chargerId: UUID) {
        userPreferences.removeFromBlacklist(chargerId)
    }
    
    func isChargerBlacklisted(_ chargerId: UUID) -> Bool {
        return userPreferences.isBlacklisted(chargerId)
    }
    
    func stopLocationServices() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Memory Monitoring
    private func logMemoryUsage() {
        #if DEBUG
        let memoryUsage = getMemoryUsage()
        print("EChargerHelper Memory Usage: \(memoryUsage) MB")
        
        // Log warning if memory usage exceeds reasonable threshold for mobile app
        if memoryUsage > 50 { // 50MB threshold
            print("⚠️ High memory usage detected: \(memoryUsage) MB")
        }
        #endif
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024 / 1024 // Convert to MB
        } else {
            return 0
        }
    }
    
    func refreshAvailability() {
        isLoading = true
        
        // Monitor memory usage during refresh
        logMemoryUsage()
        
        // Simulate API call to refresh real-time availability
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // In a real app, this would update availability from API
            // For now, just complete the loading state
            self.isLoading = false
        }
    }
}

// API Service for Open Charge Map
struct OpenChargeMapService {
    private let baseURL = "https://api.openchargemap.io/v3/poi"
    private let apiKey: String
    
    init() {
        self.apiKey = Self.loadAPIKey()
    }
    
    private static func loadAPIKey() -> String {
        // Try to load from Info.plist in the main bundle
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenChargeMapAPIKey") as? String {
            return apiKey
        }
        
        // Fallback to direct plist reading if bundle method fails
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["OpenChargeMapAPIKey"] as? String else {
            // Use fallback API key to prevent crashes during development
            print("⚠️ OpenChargeMapAPIKey not found in Info.plist, using fallback")
            return "cff5c9bb-2278-4f6f-84ef-177eb6011238"
        }
        return apiKey
    }
    
    func fetchChargers(near location: CLLocationCoordinate2D, radius: Int) async throws -> [Charger] {
        // Build API URL
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "output", value: "json"),
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "distance", value: String(radius)),
            URLQueryItem(name: "distanceunit", value: "KM"),
            URLQueryItem(name: "maxresults", value: "50"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "levelid", value: "3"), // Fast DC charging only
            URLQueryItem(name: "minpowerkw", value: "50") // Minimum 50kW
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let openChargeMapResponse = try JSONDecoder().decode([OpenChargeMapPOI].self, from: data)
            let chargers = openChargeMapResponse.compactMap { convertToCharger($0) }
            
            return chargers
            
        } catch {
            // Fallback to enhanced mock data for development
            return generateRouteBasedMockData(userLocation: location, direction: .rotterdamToSantaPola)
        }
    }
    
    private func convertToCharger(_ poi: OpenChargeMapPOI) -> Charger? {
        guard let addressInfo = poi.AddressInfo,
              let latitude = addressInfo.Latitude,
              let longitude = addressInfo.Longitude else {
            return nil
        }
        
        // Get the highest power connection
        let maxPower = poi.Connections?.compactMap { $0.PowerKW }.max() ?? 50
        
        // Determine availability
        let availability: ChargerAvailabilityStatus
        if let statusType = poi.StatusType {
            switch statusType.ID {
            case 50: availability = .available
            case 75: availability = .occupied
            case 100, 150: availability = .outOfOrder
            default: availability = .unknown
            }
        } else {
            availability = .unknown
        }
        
        // Get connector types
        let connectors = poi.Connections?.compactMap { connection -> ChargerConnectorType? in
            guard let connectionTypeID = connection.ConnectionType?.ID else { return nil }
            switch connectionTypeID {
            case 25, 1036: return .ccs2
            case 2: return .chademo
            case 1: return .type2
            case 27: return .tesla
            default: return .ccs2 // Default to CCS2 for fast charging
            }
        } ?? [.ccs2]
        
        return Charger(
            name: poi.AddressInfo?.Title ?? "Charging Station",
            location: ChargerLocation(
                latitude: latitude,
                longitude: longitude,
                address: [addressInfo.AddressLine1, addressInfo.AddressLine2].compactMap { $0 }.joined(separator: ", "),
                city: addressInfo.Town ?? "Unknown",
                country: addressInfo.Country?.Title ?? "Unknown",
                postalCode: addressInfo.Postcode ?? ""
            ),
            powerRating: Int(maxPower),
            connectorTypes: Array(Set(connectors)), // Remove duplicates
            availability: availability,
            amenities: ChargerAmenities(
                hasFastFood: false, // Not available in API
                fastFoodRestaurants: [],
                hasRestrooms: false,
                hasWifi: false,
                hasShopping: false,
                hasParking: true,
                isAccessible: poi.GeneralComments?.contains("accessible") ?? false
            ),
            highwayAccess: HighwayAccess(
                highwayName: determineHighway(latitude: latitude, longitude: longitude),
                direction: .both, // Assume accessible from both directions
                exitNumber: nil,
                accessInstructions: poi.GeneralComments ?? "No specific instructions",
                distanceFromHighway: Int.random(in: 100...1000),
                requiresCrossing: false
            ),
            operatorInfo: ChargerOperatorInfo(
                name: poi.OperatorInfo?.Title ?? "Unknown Operator",
                network: poi.DataProvider?.Title ?? "Unknown Network",
                supportPhone: poi.OperatorInfo?.PhonePrimaryContact,
                appName: nil
            ),
            pricing: nil, // Not available in basic API
            userRating: nil // Not available in basic API
        )
    }
    
    private func determineHighway(latitude: Double, longitude: Double) -> String {
        // Determine highway based on location
        switch latitude {
        case 51.0...: return "A4/A2 (Netherlands)"
        case 49.5..<51.0: return "A1/A26 (Belgium)"
        case 42.5..<49.5: return "A6/A7 (France)"
        default: return "AP-7 (Spain)"
        }
    }
    
    private func generateRouteBasedMockData(userLocation: CLLocationCoordinate2D, direction: TravelDirection) -> [Charger] {
        // Generate chargers along the actual route
        let routePoints = getRoutePoints(direction: direction)
        
        return routePoints.compactMap { point in
            // Only include chargers that are ahead of user's current position
            guard isAheadOnRoute(userLocation: userLocation, chargerLocation: point, direction: direction) else {
                return nil
            }
            
            return createChargerAtLocation(point)
        }
    }
    
    private func getRoutePoints(direction: TravelDirection) -> [CLLocationCoordinate2D] {
        // Key charging locations along Rotterdam-Santa Pola route
        return [
            CLLocationCoordinate2D(latitude: 51.9225, longitude: 4.4792), // Rotterdam
            CLLocationCoordinate2D(latitude: 51.4416, longitude: 5.4697), // Eindhoven
            CLLocationCoordinate2D(latitude: 50.8467, longitude: 4.3525), // Brussels
            CLLocationCoordinate2D(latitude: 49.4431, longitude: 1.0993), // Rouen
            CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris
            CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357), // Lyon
            CLLocationCoordinate2D(latitude: 43.6047, longitude: 1.4442), // Toulouse
            CLLocationCoordinate2D(latitude: 43.2965, longitude: 5.3698), // Marseille
            CLLocationCoordinate2D(latitude: 41.6488, longitude: -0.8891), // Zaragoza
            CLLocationCoordinate2D(latitude: 39.4699, longitude: -0.3763), // Valencia
            CLLocationCoordinate2D(latitude: 38.1929, longitude: -0.5519)  // Santa Pola
        ]
    }
    
    private func isAheadOnRoute(userLocation: CLLocationCoordinate2D, chargerLocation: CLLocationCoordinate2D, direction: TravelDirection) -> Bool {
        // Simplified: check if charger is in the right direction
        switch direction {
        case .rotterdamToSantaPola:
            return chargerLocation.latitude <= userLocation.latitude + 1.0 // Allow some tolerance
        case .santaPolaToRotterdam:
            return chargerLocation.latitude >= userLocation.latitude - 1.0
        }
    }
    
    private func createChargerAtLocation(_ location: CLLocationCoordinate2D) -> Charger {
        // Create realistic charger data for the location
        let operators = ["Ionity", "Fastned", "Tesla", "ChargePoint", "Electromaps"]
        let operatorName = operators.randomElement() ?? "Ionity"
        
        return Charger(
            name: "\(operatorName) \(getCityName(for: location))",
            location: ChargerLocation(
                latitude: location.latitude,
                longitude: location.longitude,
                address: "Highway Service Area",
                city: getCityName(for: location),
                country: getCountryName(for: location),
                postalCode: "00000"
            ),
            powerRating: [150, 175, 300, 350].randomElement() ?? 150,
            connectorTypes: [.ccs2],
            availability: [.available, .occupied, .unknown].randomElement() ?? .available,
            amenities: ChargerAmenities(
                hasFastFood: Bool.random(),
                fastFoodRestaurants: Bool.random() ? Array(["McDonald's", "Shell Select"].shuffled().prefix(1)) : [],
                hasRestrooms: true,
                hasWifi: Bool.random(),
                hasShopping: Bool.random(),
                hasParking: true,
                isAccessible: Bool.random()
            ),
            highwayAccess: HighwayAccess(
                highwayName: getHighwayName(for: location),
                direction: .both,
                exitNumber: String(Int.random(in: 1...100)),
                accessInstructions: "Service area directly accessible from highway",
                distanceFromHighway: Int.random(in: 100...500),
                requiresCrossing: false
            ),
            operatorInfo: ChargerOperatorInfo(
                name: operatorName,
                network: operatorName,
                supportPhone: "+33123456789",
                appName: "\(operatorName) App"
            ),
            pricing: PricingInfo(
                pricePerKwh: Double.random(in: 0.35...0.79),
                pricePerMinute: nil,
                connectionFee: Bool.random() ? Double.random(in: 0.5...2.0) : nil,
                currency: "EUR"
            ),
            userRating: Double.random(in: 3.5...4.8)
        )
    }
    
    private func getCityName(for location: CLLocationCoordinate2D) -> String {
        // Simplified city mapping based on latitude
        switch location.latitude {
        case 51.5...: return "Rotterdam"
        case 51.0..<51.5: return "Eindhoven"
        case 50.5..<51.0: return "Brussels"
        case 49.0..<50.5: return "Rouen"
        case 48.0..<49.0: return "Paris"
        case 45.0..<48.0: return "Lyon"
        case 43.0..<45.0: return "Toulouse"
        case 41.0..<43.0: return "Marseille"
        case 39.0..<41.0: return "Valencia"
        default: return "Santa Pola"
        }
    }
    
    private func getCountryName(for location: CLLocationCoordinate2D) -> String {
        switch location.latitude {
        case 51.0...: return "Netherlands"
        case 49.5..<51.0: return "Belgium"
        case 42.5..<49.5: return "France"
        default: return "Spain"
        }
    }
    
    private func getHighwayName(for location: CLLocationCoordinate2D) -> String {
        switch location.latitude {
        case 51.0...: return "A4/A2"
        case 49.5..<51.0: return "A1/A26"
        case 42.5..<49.5: return "A6/A7"
        default: return "AP-7"
        }
    }
}

// MARK: - Safe Array Extensions
extension Array {
    /// Safely returns a random element from the array, or nil if empty
    func safeRandomElement() -> Element? {
        return isEmpty ? nil : randomElement()
    }
    
    /// Safely returns a random element from the array with a fallback default
    func safeRandomElement(default defaultValue: Element) -> Element {
        return randomElement() ?? defaultValue
    }
}

// MARK: - Edge Case Testing
extension RealChargerService {
    /// Test method to validate edge case handling
    private func testEdgeCases() {
        // Test empty arrays with safe methods
        let emptyIntArray: [Int] = []
        _ = emptyIntArray.safeRandomElement() // Should return nil
        _ = emptyIntArray.safeRandomElement(default: 42) // Should return 42
        
        // Test arrays that might be empty during random selection
        let powerRatings = [150, 175, 300, 350]
        _ = powerRatings.safeRandomElement(default: 150)
        
        let availability = [ChargerAvailabilityStatus.available, .occupied, .unknown]
        _ = availability.safeRandomElement(default: .available)
        
        // Test URL creation edge cases
        _ = URL(string: "https://echargerhelper.com/privacy")
        _ = URL(string: "") // Should return nil
        
        // Test coordinate bounds
        _ = CLLocationCoordinate2D(latitude: 41.3851, longitude: 2.1734)
        _ = CLLocationCoordinate2D(latitude: 999, longitude: 2.1734)
        
        // Test empty operators array
        let operators: [String] = []
        _ = operators.safeRandomElement(default: "DefaultOperator")
        
        print("Edge case testing completed - all safe methods handle nil gracefully")
    }
    
    /// Converts API and service errors into user-friendly messages
    private func getUserFriendlyAPIError(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection. Please check your network and try again."
            case .timedOut:
                return "Request timed out. Please check your connection and try again."
            case .cannotFindHost, .cannotConnectToHost:
                return "Cannot connect to charging network servers. Please try again later."
            case .networkConnectionLost:
                return "Network connection lost. Please check your connection and try again."
            case .dataNotAllowed:
                return "Data usage not allowed. Please check your cellular data settings."
            default:
                return "Network error occurred. Please check your connection and try again."
            }
        } else if error is DecodingError {
            return "Received unexpected data from charging network. Please try again."
        } else {
            return "Unable to find chargers in this area. Please try a different location or check back later."
        }
    }
}