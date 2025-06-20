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
        let query = ChatQuery(
            messages: [
                .user(.init(content: .string("Analyze this image and respond with either 'Showered' or 'Not Showered'")))
            ],
            model: .gpt4_o
        )

        openAI.chats(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chatResult):
                    if let responseText = chatResult.choices.first?.message.content {
                        // Check if the response indicates showering
                        if responseText.contains("Showered") {
                            self.saveShowerDataLocally { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(responseText))
                                }
                            }
                        } else {
                            completion(.success(responseText))
                        }
                    } else {
                        let error = NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response text found."])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
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