## Relevant Files

- `EChargerHelper/ContentView.swift` - Main app entry point with direction and range selection
- `EChargerHelper/Models/Charger.swift` - Data model for charger information including highway direction
- `EChargerHelper/Models/UserPreferences.swift` - Model for storing blacklisted chargers and settings
- `EChargerHelper/Services/ChargerService.swift` - Service for fetching charger data from APIs
- `EChargerHelper/Services/LocationService.swift` - Service for determining highway position and direction
- `EChargerHelper/Views/ChargerListView.swift` - List display of relevant chargers
- `EChargerHelper/Views/ChargerRowView.swift` - Individual charger row component
- `EChargerHelper/Utils/DirectionUtils.swift` - Utility functions for highway direction logic
- `EChargerHelper/Utils/DistanceUtils.swift` - Utility functions for distance calculations

### Notes

- iOS app will use SwiftUI for the interface
- Core Data or UserDefaults for storing blacklisted chargers
- Combine framework for reactive data handling
- Use standard iOS testing framework for unit tests

## Tasks

- [x] 1.0 Set up iOS app project structure and basic configuration
  - [x] 1.1 Create new iOS project in Xcode with SwiftUI
  - [x] 1.2 Configure app bundle identifier and basic settings
  - [x] 1.3 Set up project folder structure and organize files
  - [x] 1.4 Add necessary dependencies (networking, data persistence)
  - [x] 1.5 Create basic app icon and launch screen
- [ ] 2.0 Implement direction and range selection interface  
  - [ ] 2.1 Create ContentView with direction selection buttons
  - [ ] 2.2 Add range selection interface (80, 60, 40, 20 km options)
  - [ ] 2.3 Implement input validation and user feedback
  - [ ] 2.4 Create navigation flow to charger list
  - [ ] 2.5 Add app launch behavior to immediately show selection screen
- [ ] 3.0 Create charger data model with highway direction support
  - [ ] 3.1 Define Charger model with all required properties
  - [ ] 3.2 Create highway direction enumeration and logic
  - [ ] 3.3 Implement ChargerService for API integration
  - [ ] 3.4 Create mock data for Rotterdam-Santa Pola route
  - [ ] 3.5 Add amenities model for fast food restaurant data
- [ ] 4.0 Build charger filtering and sorting logic based on direction
  - [ ] 4.1 Implement DirectionUtils for highway-side calculations
  - [ ] 4.2 Create filtering logic based on travel direction
  - [ ] 4.3 Add distance calculation and sorting algorithms
  - [ ] 4.4 Implement range-based filtering (exclude unreachable chargers)
  - [ ] 4.5 Add real-time availability filtering
- [ ] 5.0 Implement charger compatibility management (blacklist functionality)
  - [ ] 5.1 Create UserPreferences model for storing blacklisted chargers
  - [ ] 5.2 Implement data persistence using UserDefaults or Core Data
  - [ ] 5.3 Add blacklist/unblacklist functionality to charger rows
  - [ ] 5.4 Create settings screen to manage blacklisted chargers
  - [ ] 5.5 Filter out blacklisted chargers from main results