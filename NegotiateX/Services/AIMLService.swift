import Foundation
import SwiftUI

class AIMLService {
    private let apiKey: String
    private let baseURL = "https://api.aimlapi.com"
    private let model = "meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateResponse(
        prompt: String, scenario: String, persona: String, images: [UIImage],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/chat/completions"
        guard let url = URL(string: endpoint) else {
            completion(.failure(AIMLError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = """
            You are an AI assistant specialized in negotiation strategies, taking on the persona of \(persona). Your task is to provide expert advice and guidance for the following negotiation scenario: \(scenario).

            Consider the following aspects in your response:
            1. Analyze the situation from multiple perspectives.
            2. Identify key stakeholders and their potential interests.
            3. Suggest effective communication strategies.
            4. Propose potential win-win solutions.
            5. Anticipate possible objections and how to address them.
            6. Recommend specific negotiation techniques relevant to this scenario.

            If images are provided, analyze them for relevant information that could impact the negotiation strategy.

            Respond in a clear, concise manner, organizing your thoughts into distinct sections for easy readability. Your goal is to provide actionable advice that can be immediately applied to the negotiation scenario.
            """

        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            [
                "role": "user",
                "content": [
                    ["type": "text", "text": prompt]
                ]
                    + images.map { image in
                        ["type": "image_url", "image_url": ["url": convertImageToBase64(image)]]
                    },
            ],
        ]

        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "max_tokens": 1000,
            "temperature": 0.7,
            "top_p": 0.95,
            "frequency_penalty": 0.5,
            "presence_penalty": 0.5,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(AIMLError.jsonEncodingFailed(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(AIMLError.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(AIMLError.noDataReceived))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorMessage = json["error"] as? [String: Any],
                        let message = errorMessage["message"] as? String
                    {
                        completion(.failure(AIMLError.apiError(message)))
                    } else if let choices = json["choices"] as? [[String: Any]],
                        let firstChoice = choices.first,
                        let message = firstChoice["message"] as? [String: Any],
                        let content = message["content"] as? String
                    {
                        completion(.success(content))
                    } else {
                        throw AIMLError.invalidResponseFormat(
                            String(data: data, encoding: .utf8) ?? "Unable to decode response")
                    }
                } else {
                    throw AIMLError.invalidJSONResponse(
                        String(data: data, encoding: .utf8) ?? "Unable to decode response")
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func convertImageToBase64(_ image: UIImage) -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return ""
        }
        return "data:image/jpeg;base64," + imageData.base64EncodedString()
    }
}

enum AIMLError: Error, LocalizedError {
    case invalidURL
    case jsonEncodingFailed(Error)
    case networkError(Error)
    case noDataReceived
    case apiError(String)
    case invalidResponseFormat(String)
    case invalidJSONResponse(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .jsonEncodingFailed(let error):
            return "JSON encoding failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noDataReceived:
            return "No data received from the server"
        case .apiError(let message):
            return "API error: \(message)"
        case .invalidResponseFormat(let response):
            return "Invalid response format. Raw response: \(response)"
        case .invalidJSONResponse(let response):
            return "Invalid JSON response. Raw response: \(response)"
        }
    }
}
