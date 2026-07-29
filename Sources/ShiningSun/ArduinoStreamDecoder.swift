import Foundation

struct ArduinoStreamDecoder {
    private let parser = ArduinoLineParser()
    private var buffer = Data()

    mutating func append(
        _ bytes: ArraySlice<UInt8>,
        date: Date = Date()
    ) -> [SunlightReading] {
        buffer.append(contentsOf: bytes)
        var readings: [SunlightReading] = []

        // Serial.println emits CRLF. Decode at the byte level because Swift
        // treats CRLF as one grapheme-cluster Character, so searching a String
        // for a standalone "\n" does not reliably find the packet boundary.
        while let newline = buffer.firstIndex(of: 0x0A) {
            let lineBytes = buffer[..<newline]
            buffer.removeSubrange(...newline)
            let line = String(decoding: lineBytes, as: UTF8.self)
            if let reading = parser.parse(line, date: date) {
                readings.append(reading)
            }
        }

        if buffer.count > 8_192 {
            buffer.removeFirst(buffer.count - 2_048)
        }

        return readings
    }

    mutating func reset() {
        buffer.removeAll(keepingCapacity: true)
    }
}
