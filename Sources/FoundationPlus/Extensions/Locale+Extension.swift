import Foundation

public extension Locale {
    var temperatureUnit: UnitTemperature? {
        let units: [UnitTemperature] = [.celsius, .fahrenheit, .kelvin]
        let measurement = Measurement(value: 69, unit: UnitTemperature.celsius)
        let temperatureString = MeasurementFormatter().string(from: measurement)
        let matchedUnit = units.first { temperatureString.contains($0.symbol) }

        return matchedUnit
    }
}
