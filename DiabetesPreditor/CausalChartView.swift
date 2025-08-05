import SwiftUI
import Charts

struct CausalChartView: View {
    let prediction: PredictionHistory
    let onRun: (_ feature: String, _ delta: Double) -> Void

    @State private var feature: String = ""
    @State private var delta: String = ""

    var body: some View {
        let effects: [(label: String, value: Double, color: Color, description: String)] = [
            ("Causal Effect", prediction.causalEffect, .green, "Direct impact of variable on outcome."),
            ("Counterfactual Effect", prediction.counterfactualEffect, .orange, "Estimated impact if input was changed.")
        ]

        VStack(alignment: .leading, spacing: 16) {
            Text("Causal Effect Analysis")
                .font(.headline)

            HStack(spacing: 12) {
                TextField("Feature (e.g. Glucose)", text: $feature)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)

                TextField("Δ (delta)", text: $delta)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .keyboardType(.decimalPad)

                Button("Run") {
                    guard let deltaValue = Double(delta), !feature.isEmpty else {
                        // Handle invalid input here if needed
                        return
                    }
                    onRun(feature, deltaValue)
                }
                .buttonStyle(.borderedProminent)
            }

            Chart {
                ForEach(effects, id: \.label) { effect in
                    BarMark(
                        x: .value("Type", effect.label),
                        y: .value("Effect", effect.value)
                    )
                    .foregroundStyle(effect.color.gradient)
                    .annotation(position: .top) {
                        Text(String(format: "%.2f", effect.value))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(height: 200)
            .chartYAxisLabel("Effect Value")
            .chartXAxisLabel("Effect Type")

            ForEach(effects, id: \.label) { effect in
                HStack {
                    Circle()
                        .fill(effect.color)
                        .frame(width: 12, height: 12)
                    Text("\(effect.label): \(effect.description)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
