import Foundation

class NetworkManager {
    private let apiKey: String
    private let baseURL = "https://api.venice.ai/api/v1"

    init() {
        self.apiKey = NetworkManager.loadApiKey()
    }

    private static func loadApiKey() -> String {
        guard let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let keys = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
              let apiKey = keys["VeniceAPIKey"] as? String else {
            fatalError("Unable to find or read ApiKeys.plist. Please make sure the file exists and contains the VeniceAPIKey.")
        }
        return apiKey
    }

    func getChatCompletion(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                completion(.success(chatResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func generateImage(request: ImageGenerationRequest, completion: @escaping (Result<ImageGenerationResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/image/generate")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let imageResponse = try JSONDecoder().decode(ImageGenerationResponse.self, from: data)
                completion(.success(imageResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
