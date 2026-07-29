import XCTest
@testable import ShiningSun

final class ArduinoLineParserTests: XCTestCase {
    private let parser = ArduinoLineParser()

    func testCompactProtocol() {
        let reading = parser.parse("SUN:12, 130,255", date: .distantPast)
        XCTAssertEqual(reading, SunlightReading(red: 12, green: 130, blue: 255, date: .distantPast))
    }

    func testUNOOutputWithCRLF() {
        let reading = parser.parse("SUN:7,3,1\r\n", date: .distantPast)
        XCTAssertEqual(reading, SunlightReading(red: 7, green: 3, blue: 1, date: .distantPast))
        XCTAssertEqual(reading?.percentage, 1)
    }

    func testStreamDecoderHandlesSplitCRLF() {
        var decoder = ArduinoStreamDecoder()
        let firstChunk = Array("SUN:7,3,1\r".utf8)
        let secondChunk = Array("\n".utf8)

        XCTAssertTrue(decoder.append(firstChunk[...], date: .distantPast).isEmpty)
        XCTAssertEqual(
            decoder.append(secondChunk[...], date: .distantPast),
            [SunlightReading(red: 7, green: 3, blue: 1, date: .distantPast)]
        )
    }

    func testOriginalMappedOutput() {
        let reading = parser.parse(
            "Mapped Sensor Values \t red:25\t green: 100\t blue: 200",
            date: .distantPast
        )
        XCTAssertEqual(reading?.red, 25)
        XCTAssertEqual(reading?.green, 100)
        XCTAssertEqual(reading?.blue, 200)
    }

    func testRejectsOutOfRangeValue() {
        XCTAssertNil(parser.parse("SUN:256,0,0"))
    }

    func testThreeSunlightLevels() {
        XCTAssertEqual(SunlightReading(red: 20, green: 20, blue: 20, date: .now).level, .low)
        XCTAssertEqual(SunlightReading(red: 120, green: 120, blue: 120, date: .now).level, .medium)
        XCTAssertEqual(SunlightReading(red: 220, green: 220, blue: 220, date: .now).level, .high)
    }
}
