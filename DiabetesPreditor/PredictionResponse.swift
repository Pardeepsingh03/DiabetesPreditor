//
//  PredictionResponse.swift
//  DiabetesPreditor
//
//  Created by Parry  on 16/07/2025.
//

struct PredictionResponse: Codable {
    let prediction: Int
    let confidence: Double
    let anchor_rule: [String]
    let anchor_precision: Double
    let anchor_coverage: Double
    let causal_effect: Double
    let counterfactual_effect_glucose_minus_20: Double
}





