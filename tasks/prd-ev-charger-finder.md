# Product Requirements Document: EV Charger Finder App

## Introduction/Overview

An iPhone app designed specifically for Mercedes EQB drivers traveling the Rotterdam to Santa Pola, Spain route (and vice versa). The app helps users identify the nearest ultra-fast DC chargers based on their current remaining range and travel direction, ensuring suggestions are only for chargers accessible on their side of the highway.

**Problem:** EQB drivers on the Rotterdam-Santa Pola corridor need a quick, reliable way to find compatible ultra-fast chargers that are actually accessible without crossing highways or going in the wrong direction.

**Goal:** Provide instant access to directionally-relevant charging options based on current range and travel direction, with personalized compatibility tracking.

## Goals

1. **Directional Accuracy:** Only suggest chargers accessible when traveling in the specified direction (Rotterdam→Santa Pola or Santa Pola→Rotterdam)
2. **Highway-Side Awareness:** Prevent suggesting chargers on the opposite side of divided highways
3. **Immediate Relevance:** Present charging options within seconds based on user's current range and direction
4. **Compatibility Tracking:** Allow users to maintain a personal blacklist of incompatible chargers

## User Stories

1. **As an EQB driver with 40km range heading from Rotterdam to Santa Pola**, I want to see only ultra-fast chargers ahead of me on my side of the highway so I don't waste time or risk running out of power trying to reach inaccessible chargers.

2. **As a driver traveling from Santa Pola to Rotterdam**, I want chargers suggested in the northbound direction only, not southbound chargers I can't reach.

3. **As a user who discovered a charger doesn't work with my charge tag**, I want to mark it as incompatible so the app won't suggest it again.

4. **As a traveler wanting to combine charging with meals**, I want to know which charging locations have fast food restaurants in walking distance.

## Functional Requirements

1. **Direction-Critical Input:**
   - App immediately prompts for travel direction: "Rotterdam → Santa Pola" or "Santa Pola → Rotterdam"
   - App prompts for remaining range: 80km, 60km, 40km, or 20km options
   - Direction determines which side of highway/which chargers are accessible

2. **Highway-Aware Charger Filtering:**
   - Charger database must include highway direction/side information
   - Filter results to show only chargers accessible from user's travel direction
   - Account for highway splits, merge points, and access restrictions
   - Never suggest chargers requiring highway crossing or wrong-direction travel

3. **Charger Database:**
   - Focus exclusively on ultra-fast DC chargers (150kW+)
   - Include detailed access information: which highway direction, exit requirements
   - Cover Rotterdam to Santa Pola route with highway-side precision
   - Integrate with existing charger APIs plus manual curation for access details

4. **Distance & Accessibility Display:**
   - Show distance remaining until each charger exit
   - Indicate if charger requires specific exit maneuvers
   - Sort by distance ahead in travel direction
   - Never show chargers "behind" current position

5. **Charger Information Display:**
   - Basic info: location name, power rating, real-time availability
   - Highway access: exit number, side of highway
   - Nearby amenities: fast food restaurants within walking distance
   - User ratings and recent status comments

6. **Compatibility Management:**
   - Allow marking chargers as "incompatible with my charge tag"
   - Hide blacklisted chargers from future results
   - Manage blacklist in settings

## Non-Goals (Out of Scope)

- Navigation/route planning integration (future iteration)
- Map display (future iteration)
- Chargers below 150kW
- Offline functionality
- Routes outside Rotterdam-Santa Pola corridor
- Chargers requiring significant detours

## Design Considerations

- **Critical Direction Input:** Direction selection must be prominent and unambiguous
- **Highway Context:** Display should make highway side/access clear
- **iOS Native:** Target iPhone with native development
- **Quick Decision Making:** Interface optimized for drivers with limited range

## Technical Considerations

- **Highway Topology:** Database must model highway directions and access points accurately
- **Geospatial Logic:** Algorithms to determine "ahead" vs "behind" based on route direction
- **Mercedes EQB Specifications:** Research charge tag compatibility requirements
- **Real-time Data:** Integration with European charger networks for availability

## Success Metrics

- **Directional Accuracy:** 100% of suggested chargers must be accessible from user's highway direction
- **No Wrong-Side Suggestions:** Zero instances of suggesting inaccessible chargers
- **Time to Decision:** User identifies suitable charger within 10 seconds
- **Range Confidence:** Users feel confident about reaching suggested chargers

## Open Questions

1. **Highway Mapping:** How do we accurately map which chargers are accessible from which highway directions?
2. **Exit Information:** Should we include specific exit numbers and directions in the database?
3. **Position Estimation:** How do we determine user's approximate highway position without complex GPS?
4. **Access Validation:** How do we verify that chargers are actually accessible as described?
5. **Cross-Border Considerations:** Are there access differences at country borders along the route?