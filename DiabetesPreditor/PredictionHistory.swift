//
//  PredictionHistory.swift
//  DiabetesPreditor
//
//  Created by Parry on 16/07/2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Model
struct PredictionHistory: Codable, Identifiable {
    @DocumentID var id: String?
    let input: PatientInput
    let prediction: Int
    let confidence: Double
    let anchorRules: [String]
    let anchorPrecision: Double
    let anchorCoverage: Double
    let causalEffect: Double
    let counterfactualEffect: Double
    let timestamp: Date
}

// MARK: - Service
class PredictionHistoryService {
    
    static let shared = PredictionHistoryService()
    private let db = Firestore.firestore()

    // MARK: Save Prediction
    func savePredictionToHistory(userId: String, data: PredictResponse) {
        let history = PredictionHistory(
            input: data.input, prediction: data.prediction,
            confidence: data.confidence,
            anchorRules: data.anchor_rule,
            anchorPrecision: data.anchor_precision,
            anchorCoverage: data.anchor_coverage,
            causalEffect: data.causal_effect,
            counterfactualEffect: data.counterfactual_effect_glucose_minus_20,
            timestamp: Date()
        )

        do {
            _ = try db.collection("users")
                .document(userId)
                .collection("prediction_history")
                .addDocument(from: history)

            print("✅ Prediction saved to history for user: \(userId)")
        } catch {
            print("❌ Error saving prediction history:", error.localizedDescription)
        }
    }


    // MARK: Fetch Prediction History
    func fetchHistory(for userId: String, completion: @escaping ([PredictionHistory]) -> Void) {
        db.collection("users")
            .document(userId)
            .collection("prediction_history")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching prediction history:", error.localizedDescription)
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found")
                    completion([])
                    return
                }

                let history = documents.compactMap { doc in
                    try? doc.data(as: PredictionHistory.self)
                }

                completion(history)
            }
    }
    
    func fetchLatestPrediction(for userId: String, completion: @escaping (PredictionHistory?) -> Void) {
        db.collection("users")
            .document(userId)
            .collection("prediction_history")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching latest prediction:", error.localizedDescription)
                    completion(nil)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    completion(nil)
                    return
                }

                let prediction = try? document.data(as: PredictionHistory.self)
                completion(prediction)
            }
    }

}
