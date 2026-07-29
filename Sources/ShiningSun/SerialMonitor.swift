import Darwin
import Foundation

@MainActor
final class SerialMonitor: ObservableObject {
    @Published private(set) var reading = SunlightReading.zero
    @Published private(set) var portName: String?
    @Published private(set) var status = "Looking for Arduino…"

    private var fileDescriptor: Int32 = -1
    private var decoder = ArduinoStreamDecoder()
    private var pollTimer: Timer?
    private var reconnectTimer: Timer?

    init() {
        let timer = Timer(timeInterval: 2, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.connectIfNeeded()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        reconnectTimer = timer
        connectIfNeeded()
    }

    deinit {
        if fileDescriptor >= 0 {
            Darwin.close(fileDescriptor)
        }
    }

    private func connectIfNeeded() {
        guard fileDescriptor < 0 else { return }

        guard let device = Self.serialDevices().first else {
            status = "Connect the Arduino by USB"
            return
        }

        let descriptor = Darwin.open(device, O_RDWR | O_NOCTTY | O_NONBLOCK)
        guard descriptor >= 0 else {
            switch errno {
            case EBUSY:
                status = "Arduino is busy — close Serial Monitor"
            case EACCES:
                status = "Arduino access denied — reconnect it"
            default:
                status = "Could not connect to Arduino"
            }
            return
        }

        guard Self.configure(descriptor) else {
            Darwin.close(descriptor)
            status = "Could not configure \(device)"
            return
        }

        fileDescriptor = descriptor
        portName = URL(fileURLWithPath: device).lastPathComponent
        status = "Connected"
        decoder.reset()

        pollTimer?.invalidate()
        let timer = Timer(timeInterval: 0.08, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.readAvailableBytes()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        pollTimer = timer
    }

    private func readAvailableBytes() {
        guard fileDescriptor >= 0 else { return }

        var bytes = [UInt8](repeating: 0, count: 1024)
        let count = bytes.withUnsafeMutableBytes { storage in
            guard let address = storage.baseAddress else { return 0 }
            return Darwin.read(fileDescriptor, address, storage.count)
        }

        if count > 0 {
            if let latest = decoder.append(bytes.prefix(count)).last {
                reading = latest
            }
        } else if count < 0 && errno != EAGAIN && errno != EWOULDBLOCK {
            disconnect()
        }
    }

    private func disconnect() {
        if fileDescriptor >= 0 {
            Darwin.close(fileDescriptor)
        }
        fileDescriptor = -1
        pollTimer?.invalidate()
        pollTimer = nil
        portName = nil
        status = "Arduino disconnected"
    }

    private static func serialDevices() -> [String] {
        let supportedPrefixes = [
            "cu.usbmodem",
            "cu.usbserial",
            "cu.wchusbserial",
            "cu.SLAB_USBtoUART"
        ]

        let names = (try? FileManager.default.contentsOfDirectory(atPath: "/dev")) ?? []
        return names
            .filter { name in supportedPrefixes.contains { name.hasPrefix($0) } }
            .sorted()
            .map { "/dev/\($0)" }
    }

    private static func configure(_ descriptor: Int32) -> Bool {
        var options = termios()
        guard tcgetattr(descriptor, &options) == 0 else { return false }

        cfmakeraw(&options)
        cfsetspeed(&options, speed_t(B9600))
        options.c_cflag |= tcflag_t(CLOCAL | CREAD)
        options.c_cflag &= ~tcflag_t(CSTOPB | PARENB | CRTSCTS)
        options.c_cflag = (options.c_cflag & ~tcflag_t(CSIZE)) | tcflag_t(CS8)
        options.c_cc.16 = 0 // VMIN
        options.c_cc.17 = 0 // VTIME

        return tcsetattr(descriptor, TCSANOW, &options) == 0
    }
}
