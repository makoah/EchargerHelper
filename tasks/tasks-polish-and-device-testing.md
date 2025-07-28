# Task List: Polish App for Release and Device Testing

Generated from requirements: Clean up debug elements, remove test UI, and prepare for real iPhone device testing.

## Relevant Files

- `EChargerHelper/Views/SimpleChargerListView.swift` - Remove debug UI elements (Test API button, debug messages)
- `EChargerHelper/Services/RealChargerService.swift` - Clean up debug logging and console prints
- `EChargerHelper/Services/LocationManager.swift` - Remove debug console output
- `EChargerHelper/Services/OpenChargeMapService.swift` - Clean up API debug logging
- `EChargerHelper.xcodeproj/project.pbxproj` - Verify all files properly included for device build
- `EChargerHelper/Info.plist` - Ensure proper device permissions and settings

### Notes

- Focus on creating a clean, professional user experience
- Maintain all core functionality while removing development/debug elements
- Optimize specifically for iPhone 12 Pro (6.1" Super Retina XDR display, iOS 14.1+)
- Ensure app works seamlessly with iPhone 12 Pro's GPS and location services
- Test with real location services and OpenChargeMap API on your actual device
- Consider iPhone 12 Pro battery optimization for location-heavy usage

## Tasks

- [x] 1.0 Clean Up Debug UI Elements
  - [x] 1.1 Remove "Test API" button from SimpleChargerListView
  - [x] 1.2 Remove debug message display and debugMessage state variable
  - [x] 1.3 Clean up conditional cast warning by removing unnecessary cast
  - [x] 1.4 Update loading messages to be professional and user-friendly
  - [x] 1.5 Remove testAPIConnectivity method from RealChargerService
  - [x] 1.6 Simplify error display to show only essential user information
- [ ] 2.0 Remove Debug Logging and Console Output
  - [x] 2.1 Remove print statements from RealChargerService API calls
  - [ ] 2.2 Remove debug logging from LocationManager delegate methods
  - [ ] 2.3 Clean up API debug logging in OpenChargeMapService fetchChargers method
  - [ ] 2.4 Remove console output from loadChargersFromAPI method
  - [ ] 2.5 Keep only essential error logging for production troubleshooting
  - [ ] 2.6 Remove raw API response logging that could expose sensitive data
- [ ] 3.0 Optimize for iPhone 12 Pro Performance
  - [ ] 3.1 Verify Info.plist location permissions are properly configured for device
  - [ ] 3.2 Set minimum deployment target to iOS 14.1 for iPhone 12 Pro compatibility
  - [ ] 3.3 Configure build settings for iPhone 12 Pro architecture (arm64)
  - [ ] 3.4 Optimize UI layout for iPhone 12 Pro screen dimensions (390x844 points)
  - [ ] 3.5 Test memory usage and optimize for device constraints
  - [ ] 3.6 Configure proper signing and provisioning for device deployment
- [ ] 4.0 Prepare for iPhone 12 Pro Testing
  - [ ] 4.1 Create step-by-step iPhone 12 Pro build and install instructions
  - [ ] 4.2 Document GPS testing procedures specific to iPhone 12 Pro
  - [ ] 4.3 Create Barcelona area testing checklist with specific locations
  - [ ] 4.4 Verify OpenChargeMap API rate limits and usage with device location
  - [ ] 4.5 Test battery usage during continuous location tracking
  - [ ] 4.6 Create troubleshooting guide for common iPhone 12 Pro issues
  - [ ] 4.7 Document how to test highway-side filtering on actual AP-7 route