import AppKit
import SwiftUI

@main
struct ShiningSunApp: App {
    @StateObject private var model = SunlightModel()

    init() {
        // Keep the app out of the Dock even when it is launched with `swift run`.
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra {
            SunPopoverView(model: model)
        } label: {
            MenuBarSunLabel(serial: model.serial)
        }
        .menuBarExtraStyle(.window)
    }
}

private struct MenuBarSunLabel: View {
    @ObservedObject var serial: SerialMonitor

    var body: some View {
        Image(systemName: serial.reading.level.symbolName)
            .accessibilityLabel("Sunlight: \(serial.reading.level.title)")
            .help("Sunlight: \(serial.reading.level.title)")
    }
}
