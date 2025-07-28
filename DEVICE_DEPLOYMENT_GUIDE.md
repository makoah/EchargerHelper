# iPhone 12 Pro Device Deployment Guide

## Prerequisites for Device Testing

### 1. Apple Developer Account Setup
- Ensure you have an Apple Developer Account (free or paid)
- Sign in to Xcode with your Apple ID: **Xcode > Preferences > Accounts**

### 2. Device Registration
- Connect your iPhone 12 Pro to your Mac via USB/Lightning cable
- Open **Window > Devices and Simulators** in Xcode
- Click **"Use for Development"** when your iPhone 12 Pro appears
- Enter your device passcode when prompted

### 3. Code Signing Configuration
Current settings (optimized for iPhone 12 Pro):
- **Bundle Identifier**: `com.mkokarmidi.EChargerHelper`
- **Code Signing**: Automatic (Apple Development)  
- **Deployment Target**: iOS 15.0 (compatible with your iOS 18.5)
- **Architecture**: arm64 (iPhone 12 Pro's A14 Bionic)

## Deployment Steps

### 1. Build for Device
```bash
# Connect iPhone 12 Pro and select it as build destination
# In Xcode: Product > Destination > Your iPhone 12 Pro
# Then: Product > Build (⌘+B)
```

### 2. Install and Run
```bash
# In Xcode: Product > Run (⌘+R)
# This will install and launch the app on your iPhone 12 Pro
```

### 3. Trust Developer Certificate
On your iPhone 12 Pro:
1. Go to **Settings > General > VPN & Device Management**
2. Find your Apple ID under "Developer App"
3. Tap and select **"Trust [Your Apple ID]"**
4. Confirm by tapping **"Trust"**

## Testing Checklist for iPhone 12 Pro

### Core Functionality
- [ ] App launches without crashes
- [ ] Direction selection works (Rotterdam ↔ Santa Pola)
- [ ] Range selection (20, 40, 60, 80 km) displays correctly
- [ ] "Find Chargers" button responds appropriately

### Location Services  
- [ ] Location permission prompt appears on first launch
- [ ] GPS positioning works (or fallback to Tarragona coordinates)
- [ ] App finds chargers based on actual location
- [ ] No crashes during location updates

### Performance on iPhone 12 Pro
- [ ] UI is responsive on 6.1" display (390x844 points)
- [ ] Smooth scrolling in charger list
- [ ] No memory warnings in Xcode console
- [ ] Battery usage is reasonable during testing

### Production Features
- [ ] No debug buttons or test UI elements visible
- [ ] Professional loading messages and error handling
- [ ] Clean charger list with proper formatting
- [ ] All navigation flows work correctly

## Troubleshooting

### Common Issues
1. **"Could not find developer disk image"**
   - Update Xcode to latest version
   - Restart iPhone and reconnect

2. **Code signing errors**
   - Check Apple ID is signed in to Xcode
   - Verify bundle identifier is unique
   - Try cleaning build folder: Product > Clean Build Folder

3. **App not appearing on device**
   - Check device trust settings
   - Verify developer certificate is trusted
   - Try reinstalling from Xcode

### Location Testing Tips
- Test both indoors (should fallback to Tarragona) and outdoors (GPS)
- Check different areas to verify route-based filtering
- Monitor location accuracy in different conditions

## Performance Monitoring

### Memory Usage
- Open Xcode debugger while app runs on device
- Monitor memory graph for leaks
- Verify charger results are limited (max 20 items)

### Battery Impact
- Use device normally with app running
- Check battery usage in iOS Settings after testing
- Location services should not drain battery excessively

---

**Your iPhone 12 Pro Configuration:**
- Device: iPhone 12 Pro (arm64)
- iOS Version: 18.5 
- Display: 6.1" Super Retina XDR (390x844 points)
- Deployment Target: iOS 15.0+