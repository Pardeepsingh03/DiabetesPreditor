import SwiftUI
import Charts

struct CausalChartView: View {
    let prediction: PredictionHistory
    let onRun: (_ feature: String, _ delta: Double) -> Void

    @Binding var causalEffect: Double?
    @Binding var counterfactualEffect: Double?

    @State private var feature: String = "Glucose"
    @State private var delta: String = ""

    // 👇 Track which field is focused
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case deltaField
    }

    var body: some View {
        let effects: [(label: String, value: Double?, color: Color, description: String)] = [
            ("Causal Effect", causalEffect, .green, "Shows how much a change in the selected feature *directly* influences the prediction."),
            ("Counterfactual Effect", counterfactualEffect, .orange, "Estimates how the prediction would change *if* this feature were changed by the given delta.")
        ]

        VStack(alignment: .leading, spacing: 20) {
            Text("📊 Causal Effect Analysis")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 12) {
                Text("🔍 Enter a feature and delta to explore its effect on the prediction:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Feature Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("e.g. Glucose", text: $feature)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)

                    Text("Δ (Change to Apply)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("e.g. 2.0", text: $delta)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .deltaField)

                    Button(action: {
                        guard let deltaValue = Double(delta), !feature.isEmpty else { return }

                        // 👇 Trigger the causal analysis
                        onRun(feature, deltaValue)

                        // 👇 Dismiss the keyboard
                        focusedField = nil
                    }) {
                        Text("Run Analysis")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
            }

            Divider()

            Chart {
                ForEach(effects, id: \.label) { effect in
                    if let value = effect.value {
                        BarMark(
                            x: .value("Effect Type", effect.label),
                            y: .value("Effect Value", value)
                        )
                        .foregroundStyle(effect.color.gradient)
                        .annotation(position: .top) {
                            Text(String(format: "%.4f", value))
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .frame(height: 220)
            .chartYAxisLabel("Effect Value")
            .chartXAxisLabel("Effect Type")

            VStack(alignment: .leading, spacing: 8) {
                Text("🧠 Interpretation Guide")
                    .font(.subheadline.bold())
                ForEach(effects, id: \.label) { effect in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(effect.color)
                            .frame(width: 12, height: 12)
                            .padding(.top, 2)
                        Text("\(effect.label): \(effect.description)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}
