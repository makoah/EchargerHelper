import SwiftUI

struct ContentView: View {
    @State private var selectedDirection: TravelDirection?
    @State private var selectedRange: RemainingRange?
    @State private var showChargerList = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("ECharger Helper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Which direction are you traveling?")
                    .font(.headline)
                
                VStack(spacing: 15) {
                    Button(action: {
                        selectedDirection = .rotterdamToSantaPola
                    }) {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("Rotterdam → Santa Pola")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedDirection == .rotterdamToSantaPola ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDirection == .rotterdamToSantaPola ? .white : .primary)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        selectedDirection = .santaPolaToRotterdam
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Santa Pola → Rotterdam")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedDirection == .santaPolaToRotterdam ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDirection == .santaPolaToRotterdam ? .white : .primary)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                if selectedDirection != nil {
                    Text("How many kilometers of range do you have left?")
                        .font(.headline)
                        .padding(.top)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(RemainingRange.allCases, id: \.self) { range in
                            Button(action: {
                                selectedRange = range
                            }) {
                                VStack {
                                    Text("\(range.rawValue)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("km")
                                        .font(.caption)
                                }
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(selectedRange == range ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(selectedRange == range ? .white : .primary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if selectedDirection != nil && selectedRange != nil {
                    Button(action: {
                        showChargerList = true
                    }) {
                        Text("Find Chargers")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                Spacer()
            }
            .navigationTitle("ECharger Helper")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showChargerList) {
            ChargerListView(direction: selectedDirection!, range: selectedRange!)
        }
    }
}

enum TravelDirection: CaseIterable {
    case rotterdamToSantaPola
    case santaPolaToRotterdam
    
    var displayName: String {
        switch self {
        case .rotterdamToSantaPola:
            return "Rotterdam → Santa Pola"
        case .santaPolaToRotterdam:
            return "Santa Pola → Rotterdam"
        }
    }
}

enum RemainingRange: Int, CaseIterable {
    case eighty = 80
    case sixty = 60
    case forty = 40
    case twenty = 20
}

struct ChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    var body: some View {
        NavigationView {
            Text("Charger list for \(direction.displayName) with \(range.rawValue)km range")
                .navigationTitle("Available Chargers")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}