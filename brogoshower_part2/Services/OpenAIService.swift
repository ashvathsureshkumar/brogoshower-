import Foundation
import OpenAI

// Simple local authentication service
class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func signUp(email: String, password: String) -> Bool {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty, email.contains("@") else {
            return false
        }
        
        // Check if user already exists
        if getUserPassword(for: email) != nil {
            return false // User already exists
        }
        
        // Store user credentials
        UserDefaults.standard.set(password, forKey: "user_\(email)")
        UserDefaults.standard.set(email, forKey: "currentUser")
        return true
    }
    
    func login(email: String, password: String) -> Bool {
        guard let storedPassword = getUserPassword(for: email) else {
            return false // User doesn't exist
        }
        
        if storedPassword == password {
            UserDefaults.standard.set(email, forKey: "currentUser")
            return true
        }
        
        return false // Wrong password
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func getCurrentUser() -> String? {
        return UserDefaults.standard.string(forKey: "currentUser")
    }
    
    func isLoggedIn() -> Bool {
        return getCurrentUser() != nil
    }
    
    private func getUserPassword(for email: String) -> String? {
        return UserDefaults.standard.string(forKey: "user_\(email)")
    }
}

class OpenAIService {
    static let shared = OpenAIService()

    private let openAI: OpenAI

    private init() {
        let apiKey = "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"
        self.openAI = OpenAI(apiToken: apiKey)
    }

    func analyzeImage(image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let base64Image = image.base64EncodedString()
        
        // Use direct REST API call since the SDK doesn't properly support vision
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getAPIKey())", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this mobile photo and determine if someone is taking a shower. Look for: running water from showerhead, wet hair, steam/fog, shower curtain/door, bathroom tiles with water, soap/shampoo use, water droplets, person in shower position. Output only 'Showered' or 'Not Showered'."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/png;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 50
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network Error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        print("GPT Vision Response: \(content)")
                        
                        if content.lowercased().contains("showered") {
                            self.saveShowerDataLocally { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(content))
                                }
                            }
                        } else {
                            completion(.success(content))
                        }
                    } else {
                        // Try to parse error message
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            print("OpenAI API Error: \(message)")
                            completion(.failure(NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                        } else {
                            completion(.failure(NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])))
                        }
                    }
                } catch {
                    print("JSON Parsing Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func getAPIKey() -> String {
        return "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"
    }

    private func saveShowerDataLocally(completion: @escaping (Error?) -> Void) {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today)
        
        var showerDates = UserDefaults.standard.stringArray(forKey: "showerDates") ?? []
        if !showerDates.contains(dateString) {
            showerDates.append(dateString)
            UserDefaults.standard.set(showerDates, forKey: "showerDates")
        }
        
        completion(nil)
    }
    
    func getShowerData() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "showerDates") ?? []
    }
} 