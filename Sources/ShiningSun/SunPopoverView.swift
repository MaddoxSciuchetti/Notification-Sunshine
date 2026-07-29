import AppKit
import SwiftUI

struct SunPopoverView: View {
    @ObservedObject var model: SunlightModel
    @ObservedObject private var serial: SerialMonitor

    init(model: SunlightModel) {
        self.model = model
        self.serial = model.serial
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: serial.reading.level.symbolName)
                    .font(.system(size: 30, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(levelColor)

                Text("\(serial.reading.level.title) sunlight")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Spacer()
                    Text("\(serial.reading.percentage)%")
                        .font(.caption.monospacedDigit())
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.18))

                        Capsule()
                            .fill(levelColor)
                            .frame(
                                width: geometry.size.width
                                    * Double(serial.reading.percentage) / 100.0
                            )
                    }
                }
                .frame(height: 7)

                Text(serial.status)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    TextField("you@example.com", text: $model.email)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { model.subscribe() }

                    Button("Enable") {
                        model.subscribe()
                    }
                    .disabled(!model.isEmailValid || model.isSubscribing)
                }

                if model.isSubscribing {
                    ProgressView()
                        .controlSize(.small)
                } else if let message = model.subscriptionMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(message.contains("enabled") ? .green : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(width: 320)
    }

    private var levelColor: Color {
        color(for: serial.reading.level)
    }

    private func color(for level: SunlightLevel) -> Color {
        switch level {
        case .low: .blue
        case .medium: .orange
        case .high: .yellow
        }
    }
}
