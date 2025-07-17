import Foundation
import SwiftUI

class PredictionViewModel: ObservableObject {
    @Published var predictionData: PredictionResponse?
    @AppStorage("uid") var userId: String?
    @Published var showData: Bool = false

    func fetchPrediction(with input: [String: Any], completion: @escaping () -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/predict") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: input)
        } catch {
            print("Encoding error:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(PredictionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.predictionData = decoded
                    PredictionHistoryService.shared.savePredictionToHistory(userId: self.userId ?? "", data: decoded)// 🔥 Save to Firestore
                    completion()
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}
