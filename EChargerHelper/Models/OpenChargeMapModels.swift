import Foundation

// MARK: - API Error Types
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
}

// MARK: - Open Charge Map API Response Models
struct OpenChargeMapPOI: Codable {
    let ID: Int?
    let UUID: String?
    let DataProvider: DataProvider?
    let OperatorInfo: OperatorInfo?
    let StatusType: StatusType?
    let AddressInfo: AddressInfo?
    let Connections: [Connection]?
    let GeneralComments: String?
    let DateLastStatusUpdate: String?
}

struct DataProvider: Codable {
    let Title: String?
    let ID: Int?
}

struct OperatorInfo: Codable {
    let Title: String?
    let ID: Int?
    let PhonePrimaryContact: String?
    let ContactEmail: String?
    let WebsiteURL: String?
}

struct StatusType: Codable {
    let IsOperational: Bool?
    let ID: Int?
    let Title: String?
}

struct AddressInfo: Codable {
    let ID: Int?
    let Title: String?
    let AddressLine1: String?
    let AddressLine2: String?
    let Town: String?
    let StateOrProvince: String?
    let Postcode: String?
    let Country: Country?
    let Latitude: Double?
    let Longitude: Double?
    let AccessComments: String?
}

struct Country: Codable {
    let ID: Int?
    let ISOCode: String?
    let Title: String?
}

struct Connection: Codable {
    let ID: Int?
    let ConnectionType: ConnectionType?
    let Reference: String?
    let StatusType: StatusType?
    let Level: Level?
    let PowerKW: Double?
    let CurrentType: CurrentType?
    let Quantity: Int?
    let Comments: String?
}

struct ConnectionType: Codable {
    let ID: Int?
    let Title: String?
    let FormalName: String?
    let IsDiscontinued: Bool?
    let IsObsolete: Bool?
}

struct Level: Codable {
    let ID: Int?
    let Title: String?
    let Comments: String?
    let IsFastChargeCapable: Bool?
}

struct CurrentType: Codable {
    let ID: Int?
    let Title: String?
    let Description: String?
}