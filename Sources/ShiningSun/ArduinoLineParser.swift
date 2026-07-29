import Foundation

struct ArduinoLineParser {
    /// Accepts the compact protocol from `Arduino/ShiningSun.ino`:
    /// `SUN:123,145,167`
    ///
    /// It also accepts the human-readable mapped line from the sketch supplied
    /// by the user, so the Mac app remains compatible while the Arduino is
    /// being reflashed.
    func parse(_ text: String, date: Date = Date()) -> SunlightReading? {
        if let values = captures(
            in: text,
            pattern: #"SUN:\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})"#
        ) {
            return reading(values, date: date)
        }

        if let values = captures(
            in: text,
            pattern: #"Mapped Sensor Values\s+red:\s*(\d{1,3})\s+green:\s*(\d{1,3})\s+blue:\s*(\d{1,3})"#
        ) {
            return reading(values, date: date)
        }

        return nil
    }

    private func captures(in text: String, pattern: String) -> [Int]? {
        guard let expression = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = expression.firstMatch(in: text, range: range),
              match.numberOfRanges == 4 else {
            return nil
        }

        return (1...3).compactMap { index in
            guard let range = Range(match.range(at: index), in: text) else {
                return nil
            }
            return Int(text[range])
        }
    }

    private func reading(_ values: [Int], date: Date) -> SunlightReading? {
        guard values.count == 3, values.allSatisfy({ (0...255).contains($0) }) else {
            return nil
        }
        return SunlightReading(red: values[0], green: values[1], blue: values[2], date: date)
    }
}
