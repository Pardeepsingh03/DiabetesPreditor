import SwiftUI
import Charts

struct PredictionGraphView: View {
    @State private var cfFeature = "Glucose"
    @State private var cfDelta = "20"
    @State private var cfEffectResult: Double? = nil
    @StateObject private var viewModel = PredictionGraphViewModel()
    @State private var showNewPrediction = false
    @EnvironmentObject var viewModel1: PredictionViewModel
    @State private var causalEffect: Double? = nil
    @State private var counterfactualEffect: Double? = nil

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading latest prediction...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let prediction = viewModel.latestPrediction {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Confidence Ring
                            predictionRing(prediction: prediction)

                            // Anchor Rules
                            anchorRuleChart(prediction: prediction)

                            CausalChartView(
                                prediction: prediction,
                                onRun: { feature, delta in
                                    let input = PatientInput(
                                        Pregnancies: prediction.input.Pregnancies,
                                        Glucose: prediction.input.Glucose,
                                        BloodPressure: prediction.input.BloodPressure,
                                        SkinThickness: prediction.input.SkinThickness,
                                        Insulin: prediction.input.Insulin,
                                        BMI: prediction.input.BMI,
                                        DiabetesPedigreeFunction: prediction.input.DiabetesPedigreeFunction,
                                        Age: prediction.input.Age
                                    )

                                    viewModel1.fetchCounterfactual(for: input, feature: feature, delta: delta) {
                                              // Delay ensures SwiftUI redraws properly
                                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                    withAnimation {
                                                        causalEffect = viewModel1.cfResult?.causal_effect
                                                        counterfactualEffect = viewModel1.cfResult?.counterfactual_effect
                                                    }
                                                  
                                                }
                                    }
                                },
                                causalEffect: $causalEffect,
                                counterfactualEffect: $counterfactualEffect
                                
                            )




                            // Additional Details
                           

                            NavigationLink(destination: ExplanationGraphView()) {
                                HStack {
                                    Image(systemName: "chart.bar.doc.horizontal")
                                    Text("See Full Explanation")
                                }
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal)
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    Text("No prediction data found.")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Prediction Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewPrediction = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Add New Prediction")
                }
            }
            .fullScreenCover(isPresented: $showNewPrediction, onDismiss: {
            
                    viewModel.loadLatestPrediction()
            
                
                }) {
                    HealthDataInputView()
                }
                .task {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewModel.loadLatestPrediction()
                    }
                    
                }
        }
    }

    // MARK: - Component Views (Refactored)
    func predictionRing(prediction: PredictionHistory) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)

            Circle()
                .trim(from: 0, to: CGFloat(prediction.confidence))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: prediction.prediction == 1 ? [.red, .orange] : [.green, .mint]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack {
                Text("\(Int(prediction.confidence * 100))%")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)

                Text(prediction.prediction == 1 ? "Likely Diabetic" : "Unlikely Diabetic")
                    .font(.headline)
                    .foregroundColor(prediction.prediction == 1 ? .red : .green)
            }
        }
        .frame(width: 200, height: 200)
        .padding(.top)
    }

    func anchorRuleChart(prediction: PredictionHistory) -> some View {
        card(title: "Anchor Rules Impact") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(prediction.anchorRules.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)

                            Text(humanReadableRule(from: prediction.anchorRules[index]))
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }

                        ProgressView(value: prediction.anchorPrecision)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
                            .frame(height: 8)
                            .clipShape(Capsule())

                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                            Text("Confidence: \(Int(prediction.anchorPrecision * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
        }
    }




//    func explanationCard(prediction: PredictionHistory) -> some View {
//        card(title: "Explanation") {
//            VStack(alignment: .leading, spacing: 8) {
//                labelRow("📌 Anchor Coverage", "\(String(format: "%.2f", prediction.anchorCoverage))")
//                labelRow("🧪 Causal Effect", "\(String(format: "%.4f", prediction.causalEffect))")
//                labelRow("🔄 Counterfactual", "\(String(format: "%.4f", prediction.counterfactualEffect))")
//            }
//        }
//    }
    
   

    
    func humanReadableRule(from rawRule: String) -> String {
        let formatted = rawRule
            .replacingOccurrences(of: ">", with: "is greater than")
            .replacingOccurrences(of: "<", with: "is less than")
            .replacingOccurrences(of: ">=", with: "is at least")
            .replacingOccurrences(of: "<=", with: "is at most")
            .replacingOccurrences(of: "==", with: "is equal to")

        return formatted
            .replacingOccurrences(of: "Pregnancies", with: "Number of pregnancies")
            .replacingOccurrences(of: "Glucose", with: "Glucose level")
            .replacingOccurrences(of: "BloodPressure", with: "Blood pressure")
            .replacingOccurrences(of: "SkinThickness", with: "Skin thickness")
            .replacingOccurrences(of: "Insulin", with: "Insulin level")
            .replacingOccurrences(of: "BMI", with: "Body Mass Index (BMI)")
            .replacingOccurrences(of: "DiabetesPedigreeFunction", with: "Diabetes pedigree function")
            .replacingOccurrences(of: "Age", with: "Age")
    }


    func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    

    func labelRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}


// MARK: - Preview


class PredictionGraphViewModel: ObservableObject {
    @Published var latestPrediction: PredictionHistory?
    @Published var isLoading = true
   
    func loadLatestPrediction() {
        
        guard let userId = UserDefaults.standard.string(forKey: "uid") else {
            print("❌ No user ID in UserDefaults")
            return
        }

        PredictionHistoryService.shared.fetchLatestPrediction(for: userId) { [weak self] prediction in
            DispatchQueue.main.async {
                self?.latestPrediction = prediction
                self?.isLoading = false
                print("✅ Loaded prediction: \(String(describing: self?.latestPrediction))")

            }
        }
    }
}



