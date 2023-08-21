import Foundation

public extension TimeInterval {
    enum Scaler: Double {
        case seconds = 1
        case minutes = 60
        case hours = 3600
        case days = 86400
        case weeks = 604_800
    }

    init(scaler: TimeInterval.Scaler, value: Double) {
        self.init(value * scaler.rawValue)
    }
}
