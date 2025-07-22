import SwiftUI

struct ContentView: View {
    @State private var selectedDirection: TravelDirection?
    @State private var selectedRange: RemainingRange?
    @State private var showChargerList = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var isReadyToSearch: Bool {
        selectedDirection != nil && selectedRange != nil
    }
    
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
                
                Button(action: {
                    if isReadyToSearch {
                        showChargerList = true
                    } else {
                        showValidationAlert()
                    }
                }) {
                    Text("Find Chargers")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isReadyToSearch ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top)
                .disabled(!isReadyToSearch && selectedDirection == nil)
                
                if selectedDirection != nil && selectedRange == nil {
                    Text("Please select your remaining range")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, -20)
                }
                
                if selectedDirection == nil {
                    Text("Please select your travel direction first")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, -20)
                }
                
                Spacer()
            }
            .navigationTitle("ECharger Helper")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showChargerList) {
            if let direction = selectedDirection, let range = selectedRange {
                ChargerListView(direction: direction, range: range)
            }
        }
        .alert("Input Required", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func showValidationAlert() {
        if selectedDirection == nil {
            alertMessage = "Please select your travel direction first."
        } else if selectedRange == nil {
            alertMessage = "Please select your remaining range."
        }
        showingAlert = true
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