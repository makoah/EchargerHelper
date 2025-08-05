# OpenChargeMap API Rate Limits & Usage Guide - ECharger Helper

## Current API Configuration

**API Endpoint**: `https://api.openchargemap.io/v3/poi`
**API Key**: `cff5c9bb-2278-4f6f-84ef-177eb6011238`
**Max Results per Request**: 50 chargers
**Filters Applied**:
- Fast DC charging only (Level 3)
- Minimum 50kW power rating
- Distance-based search radius

## Rate Limiting Strategy

### Current Implementation Protections
1. **Request Timeout**: 10-second timeout prevents hanging requests
2. **Result Limiting**: Maximum 50 results per API call
3. **Fallback System**: Switches to mock data if API fails
4. **Single Request per Search**: Only one API call per "Find Chargers" action

### Recommended Rate Limiting for Device Testing

#### Conservative Testing Approach
- **Maximum**: 1 API request per 10 seconds
- **Daily Limit**: 100 API requests maximum
- **Testing Sessions**: Limit to 20 requests per hour

#### API Request Scenarios
```
User Action → API Calls
├── Launch App → 0 calls (no automatic requests)
├── Select Direction → 0 calls
├── Select Range → 0 calls  
├── Tap "Find Chargers" → 1 call
├── Change Location → 1 call (if location changes significantly)
└── Refresh Results → 1 call
```

## Rate Limiting Implementation

### Current Code Analysis
The app currently has basic protection but could benefit from additional rate limiting:

**Existing Protection**:
```swift
// 10-second timeout prevents hanging requests
let apiChargers = try await withTimeout(seconds: 10) { [self] in
    try await self.openChargeMapService.fetchChargers(near: location, radius: range.rawValue)
}
```

### Enhanced Rate Limiting (Recommended)
Add these protections to `RealChargerService.swift`:

```swift
private var lastAPICallTime: Date = Date.distantPast
private let minimumAPIInterval: TimeInterval = 10.0 // 10 seconds between calls

func fetchChargers(for direction: TravelDirection, range: RemainingRange, userLocation: CLLocationCoordinate2D? = nil) {
    // Rate limiting check
    let timeSinceLastCall = Date().timeIntervalSince(lastAPICallTime)
    if timeSinceLastCall < minimumAPIInterval {
        // Use cached data or mock data instead of API call
        loadMockData(direction: direction, range: range, location: userLocation ?? estimatedLocation)
        return
    }
    
    // Proceed with API call
    lastAPICallTime = Date()
    // ... existing implementation
}
```

## Testing Usage Guidelines

### Phase 1: Initial Device Testing (Day 1-2)
**Budget**: 50 API requests maximum
**Focus**: Basic functionality verification

**Test Plan**:
- **App Installation**: 5 test searches (various locations)
- **GPS Testing**: 10 test searches (different GPS conditions)  
- **Direction Testing**: 10 test searches (both directions)
- **Range Testing**: 15 test searches (all range options)
- **Error Handling**: 10 test searches (edge cases)

### Phase 2: Barcelona Area Testing (Day 3-5)
**Budget**: 100 API requests maximum  
**Focus**: Real-world location testing

**Test Plan**:
- **8 Barcelona Locations** × 2 directions × 2 ranges = 32 searches
- **Highway Access Points**: 20 searches
- **Performance Testing**: 20 searches  
- **Edge Case Testing**: 28 searches

### Phase 3: Extended Testing (Day 6-7)
**Budget**: 50 API requests maximum
**Focus**: Stress testing and optimization

**Test Plan**:
- **Battery Impact Testing**: 20 searches
- **Memory Usage Testing**: 15 searches
- **Error Recovery Testing**: 15 searches

## API Request Monitoring

### Request Tracking Implementation
Add logging to monitor API usage during testing:

```swift
private var apiRequestCount = 0
private var dailyRequestCount = 0
private var lastResetDate = Date()

func trackAPIRequest() {
    apiRequestCount += 1
    
    // Reset daily counter if new day
    if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
        dailyRequestCount = 0
        lastResetDate = Date()
    }
    
    dailyRequestCount += 1
    
    print("API Request #\(apiRequestCount) (Daily: \(dailyRequestCount))")
    
    // Warning if approaching limits
    if dailyRequestCount > 80 {
        print("⚠️ Approaching daily API limit")
    }
}
```

### Request Optimization Strategies

#### 1. Location-Based Caching
```swift
private var locationCache: [String: [Charger]] = [:]
private let cacheValidityInterval: TimeInterval = 300 // 5 minutes

func getCacheKey(for location: CLLocationCoordinate2D, radius: Int) -> String {
    return "\(Int(location.latitude * 1000))_\(Int(location.longitude * 1000))_\(radius)"
}
```

#### 2. Smart Request Batching  
- Only make API calls when location changes by more than 5km
- Cache results for nearby locations
- Use fallback data for minor location changes

#### 3. Intelligent Fallback
```swift
// Fallback priority:
// 1. Cached API data (if recent)
// 2. Enhanced mock data (location-aware)
// 3. Basic mock data (generic)
```

## Error Handling and Fallback

### API Failure Scenarios
1. **Rate Limit Exceeded**: HTTP 429 response
2. **Network Timeout**: No response within 10 seconds
3. **Invalid API Key**: HTTP 401/403 response
4. **Service Unavailable**: HTTP 500+ responses

### Fallback Strategy
```swift
enum APIFallbackReason {
    case rateLimited
    case networkTimeout  
    case serviceUnavailable
    case invalidKey
}

func handleAPIFailure(_ reason: APIFallbackReason) {
    switch reason {
    case .rateLimited:
        // Use cached data or wait before retry
        useLastKnownResults()
    case .networkTimeout:
        // Use mock data immediately
        loadMockData()
    case .serviceUnavailable:
        // Show user-friendly error
        showServiceUnavailableMessage()
    case .invalidKey:
        // Critical error - use mock data
        loadMockDataWithWarning()
    }
}
```

## Testing Checklist for API Usage

### Pre-Testing Setup
- [ ] Verify API key is active: `cff5c9bb-2278-4f6f-84ef-177eb6011238`
- [ ] Enable network monitoring in Xcode
- [ ] Set up request counting mechanism
- [ ] Prepare fallback scenarios for testing

### During Testing
- [ ] Monitor API request frequency
- [ ] Track response times and success rates  
- [ ] Verify fallback mechanisms work
- [ ] Check for any rate limiting responses

### Daily Testing Limits
- [ ] **Day 1**: Maximum 50 API requests
- [ ] **Day 2**: Maximum 50 API requests  
- [ ] **Day 3**: Maximum 100 API requests
- [ ] **Day 4**: Maximum 100 API requests
- [ ] **Day 5**: Maximum 50 API requests

### Request Budget Tracking
```
Test Session: ___________
Requests Made: ___/___
Success Rate: ___%
Average Response Time: ___ms
Fallback Activations: ___
Rate Limit Hits: ___
```

## API Response Analysis

### Expected Response Format
```json
{
  "ID": 12345,
  "UUID": "abc-123-def",
  "AddressInfo": {
    "Title": "Charging Station Name",
    "Latitude": 41.3851,
    "Longitude": 2.1734,
    "Town": "Barcelona"
  },
  "Connections": [
    {
      "PowerKW": 150,
      "ConnectionType": {"ID": 25}
    }
  ],
  "StatusType": {"ID": 50}
}
```

### Response Validation
- [ ] Valid JSON structure
- [ ] Required fields present (AddressInfo, Connections)
- [ ] Coordinates within expected range
- [ ] Power ratings ≥ 50kW (as filtered)

## Production Recommendations

### For App Store Release
1. **Implement proper rate limiting** (10-second minimum between requests)
2. **Add request caching** (5-minute cache validity)
3. **Monitor API usage** in production
4. **Consider API key rotation** strategy
5. **Implement graceful degradation** to mock data

### Usage Monitoring
- Track daily API usage via analytics
- Set up alerts for unusual request patterns
- Monitor API success/failure rates
- Plan for potential API changes or restrictions

---

**Testing Note**: During device testing, be mindful of API usage to avoid potential rate limiting. The fallback to mock data ensures the app remains functional even without API access.