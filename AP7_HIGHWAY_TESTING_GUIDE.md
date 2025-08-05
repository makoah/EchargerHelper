# AP-7 Highway-Side Filtering Testing Guide

## Overview: Critical Highway-Side Awareness

**The Problem**: EV drivers can't cross divided highways to reach chargers on the wrong side
**The Solution**: ECharger Helper's direction-aware filtering prevents wrong-side suggestions
**The Test**: Validate this works correctly on real AP-7 highway sections

## AP-7 Route Context

**Autopista del Mediterráneo (AP-7)**:
- **Route**: French border → Barcelona → Valencia → Alicante → Spanish border
- **Rotterdam-Santa Pola Corridor**: Key highway for the entire journey
- **Direction Importance**: Northbound vs Southbound access points are critical
- **Testing Relevance**: Real-world validation of highway-side logic

## Highway-Side Filtering Logic

### Current Implementation
Located in `DirectionUtils.swift`:
```swift
static func isAccessibleFromDirection(charger: Charger, direction: TravelDirection) -> Bool {
    switch charger.highwayAccess.direction {
    case .both:
        return true // Accessible from either direction
    case .rotterdamToSantaPola:
        return direction == .rotterdamToSantaPola
    case .santaPolaToRotterdam:
        return direction == .santaPolaToRotterdam
    }
}
```

### What This Prevents
- **Wrong-side chargers**: Never suggests chargers requiring U-turn or highway crossing
- **Dangerous access**: Prevents suggestions for opposite carriageway
- **Time wasted**: No detours to inaccessible charging stations

## AP-7 Testing Locations

### Test Section 1: Barcelona Area (AP-7 km 150-180)
**Why Test Here**: Heavy traffic, clear highway separation, multiple service areas

#### Location A: Martorell Service Area (Both Sides)
- **Coordinates**: 41.4667° N, 1.9167° E  
- **AP-7 km**: ~553
- **Service Areas**: North and South bound separated
- **Test Value**: Perfect for direction filtering validation

**Test Procedure:**
1. **Park at Northbound service area** (towards France/Rotterdam)
2. **Set app direction**: Santa Pola → Rotterdam
3. **Expected Result**: Should show this service area and others northbound only
4. **Verification**: Should NOT show southbound service areas across highway

#### Location B: AP-7 near Barcelona Airport
- **Coordinates**: 41.2971° N, 2.0833° E
- **AP-7 km**: ~620  
- **Challenge**: Airport access from both directions
- **Test Value**: Complex junction testing

**Test Scenarios:**
```
Scenario 1: Northbound Traffic (Santa Pola → Rotterdam)
Position: Southbound side of AP-7
Expected: Only northbound chargers ahead
Must NOT show: Chargers requiring southbound access

Scenario 2: Southbound Traffic (Rotterdam → Santa Pola)  
Position: Northbound side of AP-7
Expected: Only southbound chargers ahead
Must NOT show: Chargers requiring northbound access
```

### Test Section 2: Valencia Area (AP-7 km 350-400)
**Why Test Here**: Major city with multiple highway access points

#### Location C: Valencia North Service Area
- **Coordinates**: 39.5696° N, 0.3824° W
- **Direction Test**: Critical filtering point
- **Real Chargers**: Multiple operators likely present

**Validation Steps:**
1. **Approach from Barcelona** (southbound)
2. **Test app** while on AP-7 southbound
3. **Verify**: Only shows Valencia and southward chargers
4. **Check**: No suggestions for northbound return journey

#### Location D: Valencia South Access
- **Coordinates**: 39.4199° N, 0.3436° W  
- **Test Focus**: Exit access vs highway continuation
- **Challenge**: City exits vs highway chargers

### Test Section 3: Alicante Area (AP-7 km 470-500)
**Why Test Here**: Final AP-7 section, route complexity increases

#### Location E: Alicante Service Areas
- **Coordinates**: 38.3516° N, 0.4910° W
- **Test Value**: End-of-highway behavior
- **Real-world**: Last major charging opportunity

## Testing Methodology

### Pre-Test Setup
1. **Ensure GPS accuracy**: Wait for precise location lock
2. **Note highway side**: Are you on north or southbound carriageway?
3. **Document real chargers**: What's actually visible from your position?
4. **Test both directions**: Try both Rotterdam→Santa Pola and reverse

### Test Protocol for Each Location

#### Step 1: Position Verification
```
Current Location: _______________
GPS Coordinates: _______________  
Highway Side: Northbound/Southbound AP-7
Actual Chargers Visible: _______________
```

#### Step 2: Direction Testing - Rotterdam → Santa Pola
1. **Select direction**: Rotterdam → Santa Pola
2. **Choose range**: 60km (good test range)
3. **Tap "Find Chargers"**
4. **Record results**: Which chargers are suggested?
5. **Verify accessibility**: Can you actually reach suggested chargers?

#### Step 3: Direction Testing - Santa Pola → Rotterdam  
1. **Select direction**: Santa Pola → Rotterdam
2. **Same range**: 60km
3. **Compare results**: Should be different from Step 2
4. **Verify logic**: Only opposite-direction chargers should appear

#### Step 4: Real-World Validation
```
App Suggestions vs Reality Check:
App showed: _____ chargers
Actually accessible: _____ chargers  
Wrong-side suggestions: _____ (should be 0)
Missing accessible chargers: _____ 
```

### Success Criteria

#### Must Pass (Critical)
- [ ] **Zero wrong-side suggestions**: Never suggests inaccessible chargers
- [ ] **Direction filtering works**: Different results for different directions
- [ ] **Highway awareness**: Understands northbound vs southbound
- [ ] **No dangerous suggestions**: Never requires highway crossing

#### Should Pass (Important)
- [ ] **Finds real chargers**: Shows actual charging stations when available
- [ ] **Logical ordering**: Closest accessible chargers first
- [ ] **Range respect**: Only shows chargers within selected range
- [ ] **Service area priority**: Prefers highway service areas

#### Nice to Have (Enhancement)
- [ ] **Real-time data**: Shows actual charger availability if available
- [ ] **Amenity accuracy**: Correctly identifies service area amenities
- [ ] **Multiple operators**: Shows different charging networks

## Data Recording Template

### AP-7 Highway Test Report
```
Date: ___________
Test Section: Barcelona/Valencia/Alicante  
Weather: ___________
Traffic: Light/Moderate/Heavy

Location: _______________
AP-7 km: _____
Highway Side: North/South bound
GPS Accuracy: _____ meters

ROTTERDAM → SANTA POLA Test:
Chargers Found: _____
Accessible: _____ / Wrong-side: _____
Range Accuracy: Good/Fair/Poor

SANTA POLA → ROTTERDAM Test:  
Chargers Found: _____
Accessible: _____ / Wrong-side: _____
Different from first test: Yes/No

Real-World Validation:
Actually drove to suggested charger: Yes/No
Charger was accessible as suggested: Yes/No
Navigation was correct: Yes/No

Overall Highway Filtering: Pass/Fail
```

## Common Highway Testing Challenges

### Challenge 1: GPS Accuracy on Highway
**Problem**: High-speed movement can affect GPS precision
**Solution**: Test while stationary at service areas when possible

### Challenge 2: Mock Data vs Real Data  
**Problem**: Mock data may not reflect real highway geography
**Solution**: Note when app is using fallback data vs API data

### Challenge 3: Service Area Complexity
**Problem**: Some service areas accessible from both directions
**Solution**: Focus on clearly separated north/south facilities

### Challenge 4: Urban Highway Sections
**Problem**: City sections have complex access patterns  
**Solution**: Test in clear highway sections away from complex junctions

## Safety Considerations

### Testing Safety Protocol
⚠️ **Never test while driving** - passenger testing only
⚠️ **Use service areas** for stationary testing when possible
⚠️ **Don't cross highways** to validate wrong-side suggestions
⚠️ **Plan fuel/battery** for testing detours

### Highway Driving Safety
- Test during moderate traffic periods
- Use hands-free testing when possible
- Have passenger operate app during movement
- Plan safe stopping points for detailed testing

## Expected Results by Location

### Barcelona Area (Heavy Traffic)
- **Many service areas**: Should find multiple options
- **Clear separation**: North/south filtering should be obvious
- **Real API data**: Likely to get actual OpenChargeMap results

### Valencia Area (Moderate Traffic)
- **Fewer options**: More selective charger results
- **City influence**: May mix highway and city chargers
- **Direction critical**: Wrong direction = long detour

### Alicante Area (Route End)
- **Limited options**: Fewer highway chargers available
- **End-of-route**: App logic handles route termination
- **Real-world critical**: Last chance for highway-speed charging

## Post-Testing Analysis

### Data Validation
1. **Compile wrong-side suggestions**: Should be zero across all tests
2. **Check direction consistency**: Results should differ by direction
3. **Validate real-world accuracy**: Suggested chargers were actually accessible
4. **Note any edge cases**: Document unexpected behavior

### Success Metrics
- **100% accuracy**: No wrong-side suggestions allowed
- **90%+ real-world match**: Suggested chargers are actually accessible  
- **Direction consistency**: Different results for opposite directions
- **Range logic**: All suggestions within selected range

---

**Critical Success Factor**: Highway-side filtering is the core value proposition of ECharger Helper. It must work perfectly on real AP-7 sections to prevent dangerous or impossible charging suggestions for EV drivers.