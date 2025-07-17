import SwiftUI
import Charts

struct PredictionGraphView: View {
    @StateObject private var viewModel = PredictionGraphViewModel()
    @State private var showNewPrediction = false
    @EnvironmentObject var viewModel1: PredictionViewModel

    var body: some View {
        NavigationView {
            Group {
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

                            // Causal Effects
                            causalChart(prediction: prediction)

                            // Additional Details
                            explanationCard(prediction: prediction)

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
                    viewModel.isLoading = true
                    viewModel.loadLatestPrediction()
                }) {
                    HealthDataInputView()
                }
                .task {
                    viewModel.loadLatestPrediction()
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
            Chart {
                ForEach(prediction.anchorRules.indices, id: \.self) { index in
                    BarMark(
                        x: .value("Rule", prediction.anchorRules[index]),
                        y: .value("Precision", prediction.anchorPrecision)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
        }
    }

    func causalChart(prediction: PredictionHistory) -> some View {
        card(title: "Causal Effect Analysis") {
            Chart {
                BarMark(
                    x: .value("Type", "Causal Effect"),
                    y: .value("Effect", prediction.causalEffect)
                )
                .foregroundStyle(Color.green.gradient)

                BarMark(
                    x: .value("Type", "Counterfactual Effect"),
                    y: .value("Effect", prediction.counterfactualEffect)
                )
                .foregroundStyle(Color.orange.gradient)
            }
            .frame(height: 180)
        }
    }

    func explanationCard(prediction: PredictionHistory) -> some View {
        card(title: "Explanation") {
            VStack(alignment: .leading, spacing: 8) {
                labelRow("📌 Anchor Coverage", "\(String(format: "%.2f", prediction.anchorCoverage))")
                labelRow("🧪 Causal Effect", "\(String(format: "%.4f", prediction.causalEffect))")
                labelRow("🔄 Counterfactual", "\(String(format: "%.4f", prediction.counterfactualEffect))")
            }
        }
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
struct PredictionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionGraphView()
    }
}

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
            }
        }
    }
}

