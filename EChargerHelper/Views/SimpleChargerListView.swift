import SwiftUI

struct SimpleChargerListView: View {
    let direction: TravelDirection
    let range: RemainingRange
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Finding chargers...")
                    .font(.headline)
                    .padding()
                
                Text("Direction: \(direction == .rotterdamToSantaPola ? "Rotterdam → Santa Pola" : "Santa Pola → Rotterdam")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Range: \(range.rawValue) km")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Mock charger data would appear here")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
            }
            .navigationTitle("Available Chargers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}