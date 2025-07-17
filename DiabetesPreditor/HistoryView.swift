import SwiftUI

struct HistoryView: View {
    @State private var predictionHistory: [PredictionHistory] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading prediction history...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if predictionHistory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No prediction history found.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(predictionHistory) { item in
                                HistoryCardView(history: item)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Prediction History")
            .task {
                await loadUserHistory()
            }
        }
    }

    // MARK: - Load History
    func loadUserHistory() async {
        guard let userId = UserDefaults.standard.string(forKey: "uid") else {
            print("❌ No UID found in UserDefaults")
            self.isLoading = false
            return
        }

        await withCheckedContinuation { continuation in
            PredictionHistoryService.shared.fetchHistory(for: userId) { history in
                DispatchQueue.main.async {
                    self.predictionHistory = history
                    self.isLoading = false
                    continuation.resume()
                }
            }
        }
    }
}


struct HistoryCardView: View {
    let history: PredictionHistory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(history.prediction == 1 ? "Diabetic" : "Non-Diabetic",
                      systemImage: history.prediction == 1 ? "heart.slash.fill" : "heart.fill")
                    .font(.headline)
                    .foregroundColor(history.prediction == 1 ? .red : .green)
                Spacer()
                Text(history.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                InfoRow(label: "Confidence", value: "\(String(format: "%.2f", history.confidence * 100))%")
                InfoRow(label: "Anchor Rules", value: history.anchorRules.joined(separator: ", "))
                InfoRow(label: "Causal Effect", value: String(format: "%.4f", history.causalEffect))
                InfoRow(label: "Counterfactual", value: String(format: "%.4f", history.counterfactualEffect))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
        }
        .font(.subheadline)
    }
}
#Preview {
    InfoRow(label: "Label", value: "Value")
}