import Foundation

@MainActor
final class SunlightModel: ObservableObject {
    @Published var email = UserDefaults.standard.string(forKey: "subscriberEmail") ?? ""
    @Published private(set) var subscriptionMessage: String?
    @Published private(set) var isSubscribing = false

    let serial = SerialMonitor()

    var reading: SunlightReading { serial.reading }
    var isEmailValid: Bool {
        let pattern = #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    func subscribe() {
        guard isEmailValid, !isSubscribing else { return }

        isSubscribing = true
        subscriptionMessage = nil
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let level = reading.level

        Task {
            do {
                try await EmailSubscriptionService().subscribe(email: address, level: level)
                UserDefaults.standard.set(address, forKey: "subscriberEmail")
                subscriptionMessage = "Daily weather email enabled."
            } catch {
                subscriptionMessage = error.localizedDescription
            }
            isSubscribing = false
        }
    }
}
