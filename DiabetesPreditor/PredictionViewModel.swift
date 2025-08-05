import Foundation
import SwiftUI

struct PatientInput: Codable {
    let Pregnancies: Double
    let Glucose: Double
    let BloodPressure: Double
    let SkinThickness: Double
    let Insulin: Double
    let BMI: Double
    let DiabetesPedigreeFunction: Double
    let Age: Double
}

struct CounterfactualInput: Codable {
    let feature: String
    let delta: Double
}

// Request payload for /predict_cf
struct CounterfactualRequest: Codable {
    let input: PatientInput
    let cf: CounterfactualInput
}



class PredictionViewModel: ObservableObject {
    @Published var predictionData: PredictResponse?
    @AppStorage("uid") var userId: String?
    @Published var showData: Bool = false
    @Published var cfResult: CounterfactualResponse?
   

    func fetchPrediction(with input: PatientInput, completion: @escaping () -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/predict") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(input)
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
                let decoded = try JSONDecoder().decode(PredictResponse.self, from: data)
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
    
    func fetchCounterfactual(for input: PatientInput, feature: String, delta: Double, completion: @escaping () -> Void) {
            guard let url = URL(string: "http://127.0.0.1:8000/predict_cf") else { return }
            
            let requestData = CounterfactualRequest(input: input, cf: CounterfactualInput(feature: feature, delta: delta))
           var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let jsonData = try JSONEncoder().encode(requestData)
                request.httpBody = jsonData
            } catch {
                print("Encoding error: \(error)")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decoded = try JSONDecoder().decode(CounterfactualResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.cfResult = decoded
                            print(self.cfResult ?? "")
                            completion()
                        }
                    } catch {
                        print("Decoding error: \(error)")
                    }
                } else {
                    print("Request error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }

}

struct CounterfactualResponse: Codable {
    let feature: String?
    let delta: Double?
    let causal_effect: Double?
    let counterfactual_effect: Double?
}

