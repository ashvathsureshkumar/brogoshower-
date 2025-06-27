import Foundation
import UIKit

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func signUp(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty, email.contains("@") else {
            return false
        }
        
        if getUserPassword(for: email) != nil {
            return false
        }
        
        UserDefaults.standard.set(password, forKey: "user_\(email)")
        UserDefaults.standard.set(email, forKey: "currentUser")
        return true
    }
    
    func login(email: String, password: String) -> Bool {
        guard let storedPassword = getUserPassword(for: email) else {
            return false
        }
        
        if storedPassword == password {
            UserDefaults.standard.set(email, forKey: "currentUser")
            return true
        }
        
        return false
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

// Claude image + text analysis service
class ClaudeService {
    static let shared = ClaudeService()
    
    private init() {}
    
    func analyzeImage(image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // Compress image to stay under Claude's 5MB limit
        guard let uiImage = UIImage(data: image) else {
            completion(.failure(NSError(domain: "AnthropicError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create UIImage from data"])))
            return
        }
        
        let compressedImageData = compressImageForClaude(uiImage)
        let base64Image = compressedImageData.base64EncodedString()
        
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            completion(.failure(NSError(domain: "AnthropicError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(getAPIKey(), forHTTPHeaderField: "x-api-key") 
        
        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 100,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": """
                            Analyze this mobile photo and determine if someone is taking a shower. Look for: running water from showerhead, wet hair, steam/fog, shower curtain/door, bathroom tiles with water, soap/shampoo use, water droplets, person in shower position. Output only 'Showered' or 'Not Showered'.
                            """
                        ]
                    ]
                ]
            ]
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
                    completion(.failure(NSError(domain: "AnthropicError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let contentArray = json["content"] as? [[String: Any]],
                       let firstContent = contentArray.first,
                       let text = firstContent["text"] as? String {
                        
                        print("Claude Vision Response: \(text)")
                        
                        // Check if it starts with "Showered" (not "Not Showered")
                        if text.lowercased().hasPrefix("showered") {
                            self.saveShowerDataLocally { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success("Showered"))
                                }
                            }
                        } else {
                            completion(.success("Not Showered"))
                        }
                    } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let errorInfo = json["error"] as? [String: Any],
                              let message = errorInfo["message"] as? String {
                        print("Anthropic API Error: \(message)")
                        completion(.failure(NSError(domain: "AnthropicError", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                    } else {
                        print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                        completion(.failure(NSError(domain: "AnthropicError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])))
                    }
                } catch {
                    print("JSON Parsing Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func getAPIKey() -> String {
        return Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String ?? ""
    }

    private func compressImageForClaude(_ image: UIImage) -> Data {
        // Target size: 4MB to stay well under Claude's 5MB limit
        let maxSizeBytes = 4 * 1024 * 1024 // 4MB
        
        // Start with reasonable dimensions (max 1024px on longest side)
        let maxDimension: CGFloat = 1024
        let resizedImage = resizeImage(image, maxDimension: maxDimension)
        
        // Try different compression qualities
        var compressionQuality: CGFloat = 0.8
        var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)!
        
        // Reduce quality until we're under the size limit
        while imageData.count > maxSizeBytes && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)!
        }
        
        print("Compressed image size: \(imageData.count) bytes (quality: \(compressionQuality))")
        return imageData
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        // Only resize if the image is actually larger
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
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
