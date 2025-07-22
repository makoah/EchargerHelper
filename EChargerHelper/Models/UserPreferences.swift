import Foundation

class UserPreferences: ObservableObject {
    @Published var blacklistedChargers: Set<UUID> = []
    
    private let blacklistKey = "blacklisted_chargers"
    
    init() {
        loadBlacklist()
    }
    
    func blacklistCharger(_ chargerId: UUID) {
        blacklistedChargers.insert(chargerId)
        saveBlacklist()
    }
    
    func removeFromBlacklist(_ chargerId: UUID) {
        blacklistedChargers.remove(chargerId)
        saveBlacklist()
    }
    
    func isBlacklisted(_ chargerId: UUID) -> Bool {
        return blacklistedChargers.contains(chargerId)
    }
    
    func toggleBlacklist(_ chargerId: UUID) {
        if isBlacklisted(chargerId) {
            removeFromBlacklist(chargerId)
        } else {
            blacklistCharger(chargerId)
        }
    }
    
    private func saveBlacklist() {
        let chargerIds = Array(blacklistedChargers).map { $0.uuidString }
        UserDefaults.standard.set(chargerIds, forKey: blacklistKey)
    }
    
    private func loadBlacklist() {
        if let chargerIds = UserDefaults.standard.array(forKey: blacklistKey) as? [String] {
            blacklistedChargers = Set(chargerIds.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func clearAllBlacklisted() {
        blacklistedChargers.removeAll()
        saveBlacklist()
    }
}