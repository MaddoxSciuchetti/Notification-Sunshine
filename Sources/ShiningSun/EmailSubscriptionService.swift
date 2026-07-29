import Foundation

struct EmailSubscriptionService {
    enum SubscriptionError: LocalizedError {
        case notConfigured
        case invalidResponse
        case rejected(String)

        var errorDescription: String? {
            switch self {
            case .notConfigured:
                "Daily email service is not configured in this build."
            case .invalidResponse:
                "The email service returned an invalid response."
            case .rejected(let message):
                message
            }
        }
    }

    struct Request: Encodable {
        let email: String
        let timeZone: String
        let locale: String
        let sunlightLevel: String
    }

    func subscribe(email: String, level: SunlightLevel) async throws {
        guard let rawURL = Bundle.main.object(forInfoDictionaryKey: "SunshineSubscriptionURL") as? String,
              !rawURL.isEmpty,
              !rawURL.contains("YOUR-ENDPOINT"),
              let url = URL(string: rawURL) else {
            throw SubscriptionError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        request.httpBody = try JSONEncoder().encode(
            Request(
                email: email,
                timeZone: TimeZone.current.identifier,
                locale: Locale.current.identifier,
                sunlightLevel: level.title.lowercased()
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SubscriptionError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Subscription failed."
            throw SubscriptionError.rejected(message)
        }
    }
}
