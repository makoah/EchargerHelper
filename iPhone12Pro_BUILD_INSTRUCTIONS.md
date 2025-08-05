# ECharger Helper - iPhone 12 Pro Build & Install Instructions

## Prerequisites Check ✅

Before building, verify these requirements:
- **Xcode**: Version 14.0+ (required for iOS 15.0+ deployment)
- **macOS**: macOS 12.0+ (Monterey or later)
- **iPhone 12 Pro**: Running iOS 15.0+ (your iOS 18.5 is perfect)
- **Cable**: Lightning to USB-C/USB-A cable for connection
- **Apple ID**: Signed into Xcode (free Apple ID works for testing)

## Step-by-Step Build Process

### Step 1: Prepare Your Development Environment
```bash
# Navigate to project directory
cd /Users/mkokarmidi/EchargerHelper

# Verify project exists
ls -la EChargerHelper.xcodeproj
```

### Step 2: Open Project in Xcode
```bash
# Open the project
open EChargerHelper.xcodeproj
```

**In Xcode:**
1. Wait for project to fully load
2. Check that no build errors appear in the navigator
3. Verify "EChargerHelper" scheme is selected in the toolbar

### Step 3: Connect Your iPhone 12 Pro
1. **Connect** your iPhone 12 Pro to Mac via Lightning cable
2. **Unlock** your iPhone 12 Pro
3. If prompted "Trust This Computer?" → Tap **"Trust"**
4. Enter your iPhone passcode when requested

### Step 4: Configure Device in Xcode
1. **Open Device Manager**: Window → Devices and Simulators
2. **Select** your iPhone 12 Pro from the left sidebar
3. **Click** "Use for Development" if it appears
4. **Wait** for device processing to complete (shows "Ready for development")

### Step 5: Select Your iPhone 12 Pro as Build Target
In Xcode toolbar:
1. **Click** the device selector (next to the scheme)
2. **Choose** your iPhone 12 Pro from "iOS Device" section
3. **Verify** it shows "iPhone 12 Pro" (not Simulator)

### Step 6: Build the Project
```bash
# Option A: Command line build (verify compilation)
cd /Users/mkokarmidi/EchargerHelper
xcodebuild -project EChargerHelper.xcodeproj -scheme EChargerHelper -destination 'generic/platform=iOS' build
```

**OR in Xcode:**
1. **Press** ⌘+B (Product → Build)
2. **Wait** for "Build Succeeded" message
3. **Check** no errors in the Issue Navigator

### Step 7: Install and Run on iPhone 12 Pro

#### Method A: Direct Run from Xcode (Recommended)
1. **Press** ⌘+R (Product → Run)
2. **Wait** for app to install and launch on your iPhone 12 Pro
3. **First launch** will require developer trust (see Step 8)

#### Method B: Build and Install Separately
```bash
# Build for device
xcodebuild -project EChargerHelper.xcodeproj -scheme EChargerHelper -destination 'generic/platform=iOS' -configuration Debug build

# Install via Xcode (easier than command line)
# Use Xcode's Product → Run after building
```

### Step 8: Trust Developer Certificate (First Install Only)

**On your iPhone 12 Pro:**
1. **Go to**: Settings → General → VPN & Device Management
2. **Find**: "Developer App" section
3. **Tap**: Your Apple ID (com.mkokarmidi.EChargerHelper)
4. **Tap**: "Trust [Your Apple ID]"
5. **Confirm**: "Trust" in the popup

### Step 9: Launch and Test
1. **Find** ECharger Helper app on your iPhone 12 Pro home screen
2. **Tap** to launch
3. **Grant** location permission when prompted
4. **Test** basic functionality:
   - Direction selection
   - Range selection  
   - "Find Chargers" button

## Troubleshooting Common Issues

### Issue: "Developer Disk Image Not Found"
**Solution:**
```bash
# Update Xcode to latest version
# Restart iPhone 12 Pro
# Reconnect device to Mac
```

### Issue: "Code Signing Error"
**Solution:**
1. Xcode → Preferences → Accounts
2. Add Apple ID if not present
3. Project → EChargerHelper → Signing & Capabilities
4. Select your development team
5. Ensure "Automatically manage signing" is checked

### Issue: "App Won't Install"
**Solution:**
1. Delete any existing ECharger Helper app from iPhone
2. Clean build folder: Product → Clean Build Folder
3. Try install again

### Issue: "Location Permission Issues"
**Solution:**
- Check Info.plist has location usage descriptions ✅ (already configured)
- Reset location permissions: Settings → Privacy & Security → Location Services → ECharger Helper

## Verification Checklist

After successful installation, verify:

### ✅ Installation Success
- [ ] App appears on iPhone 12 Pro home screen
- [ ] App launches without immediate crash
- [ ] No "Untrusted Developer" warning appears

### ✅ Core Functionality  
- [ ] Direction selection buttons work
- [ ] Range selection grid displays properly on 6.1" screen
- [ ] "Find Chargers" button responds
- [ ] Navigation flows work correctly

### ✅ iPhone 12 Pro Specific
- [ ] UI fits perfectly on 390x844 point display
- [ ] Touch targets are appropriately sized
- [ ] Text is readable at iPhone 12 Pro pixel density
- [ ] No layout issues or cutoff content

### ✅ Location Services
- [ ] Location permission prompt appears
- [ ] GPS positioning works outdoors
- [ ] Fallback to Tarragona works indoors
- [ ] No crashes during location updates

## Performance Monitoring

### Memory Usage Check
1. **Run** app on device from Xcode
2. **Open** Debug Navigator (⌘+7)
3. **Monitor** Memory usage
4. **Verify** stays under 200MB during normal use

### Battery Impact Check
1. **Use** app for 10-15 minutes
2. **Go to** iPhone Settings → Battery
3. **Check** ECharger Helper usage is reasonable
4. **Should not** be highest battery consumer

## Build Configuration Summary

Current optimized settings for your iPhone 12 Pro:
- **Bundle ID**: com.mkokarmidi.EChargerHelper
- **Deployment Target**: iOS 15.0 (compatible with iOS 18.5)
- **Architecture**: arm64 (A14 Bionic optimized)
- **Code Signing**: Automatic Apple Development
- **Memory Limit**: 20 chargers max (prevents memory issues)
- **Location**: Proper permissions configured

## Quick Command Reference

```bash
# Navigate to project
cd /Users/mkokarmidi/EchargerHelper

# Open in Xcode
open EChargerHelper.xcodeproj

# Command line build (verification)
xcodebuild -project EChargerHelper.xcodeproj -scheme EChargerHelper -destination 'generic/platform=iOS' build

# Check connected devices
xcrun devicectl list devices

# View device logs (if issues occur)
xcrun devicectl log --device [DEVICE_ID] --style compact
```

---

**Next Steps After Installation:**
1. Complete basic functionality testing
2. Test GPS accuracy in different locations
3. Verify charger filtering works correctly
4. Test performance during extended use

**Support:** If build fails, check the project's git status and ensure all files are properly committed before attempting installation.