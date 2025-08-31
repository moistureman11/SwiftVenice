import Foundation

class NetworkManager {
    private let apiKey: String
    private let baseURL = "https://api.venice.ai/api/v1"

    init() {
        self.apiKey = NetworkManager.loadApiKey()
    }

    private static func loadApiKey() -> String {
        if let apiKey = ProcessInfo.processInfo.environment["VENICE_API_KEY"], !apiKey.isEmpty {
            return apiKey
        } else {
            fatalError("VENICE_API_KEY environment variable not set. Please set the API key in your environment variables.")
        }
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

    func upscaleImage(request: UpscaleImageRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/image/upscale")!
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

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if let data = data, let errorResponse = try? JSONDecoder().decode(StandardError.self, from: data) {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.error])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."])))
                }
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            completion(.success(data))

        }.resume()
    }
}
