import SwiftUI

struct HealthDataInputView: View {
    // Your existing state vars
    @State private var pregnancies: String = ""
    @State private var glucose: String = ""
    @State private var bloodPressure: String = ""
    @State private var skinThickness: String = ""
    @State private var insulin: String = ""
    @State private var bmi: String = ""
    @State private var dpf: String = ""
    @State private var age: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PredictionViewModel
   

    

    @State private var showValidationError = false
    @State private var showPrediction = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Your Health Data")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Please provide your health data for personalized risk prediction.")

                    Group {
                        CustomTextField(label: "Pregnancies",
                                        hint: "Number of times pregnant (0–17)",
                                        text: $pregnancies,
                                        keyboard: .numberPad)

                        CustomTextField(label: "Glucose (mg/dL)",
                                        hint: "Typical: 70–140 mg/dL",
                                        text: $glucose,
                                        keyboard: .decimalPad)

                        CustomTextField(label: "Blood Pressure (mmHg)",
                                        hint: "Normal: 80–120 mmHg",
                                        text: $bloodPressure,
                                        keyboard: .decimalPad)

                        CustomTextField(label: "Skin Thickness (mm)",
                                        hint: "Usually around 10–99 mm",
                                        text: $skinThickness,
                                        keyboard: .decimalPad)

                        CustomTextField(label: "Insulin (mu U/ml)",
                                        hint: "Normal fasting: 16–166",
                                        text: $insulin,
                                        keyboard: .decimalPad)

                        CustomTextField(label: "BMI",
                                        hint: "Healthy: 18.5–24.9",
                                        text: $bmi,
                                        keyboard: .decimalPad)

                        CustomTextField(label: "Diabetes Pedigree Function",
                                        hint: "Hereditary score (0.0–2.5)",
                                        text: $dpf,
                                        keyboard: .decimalPad)

                        CustomTextField(label: "Age",
                                        hint: "Enter your age in years",
                                        text: $age,
                                        keyboard: .numberPad)
                    }


                    Button(action: {
                        if validateInputs() {
                            let payload: [String: Any] = [
                                "Pregnancies": Double(pregnancies) ?? 0,
                                "Glucose": Double(glucose) ?? 0,
                                "BloodPressure": Double(bloodPressure) ?? 0,
                                "SkinThickness": Double(skinThickness) ?? 0,
                                "Insulin": Double(insulin) ?? 0,
                                "BMI": Double(bmi) ?? 0,
                                "DiabetesPedigreeFunction": Double(dpf) ?? 0,
                                "Age": Double(age) ?? 0
                            ]

                            viewModel.fetchPrediction(with: payload) {
                                dismiss()
                                viewModel.showData.toggle()
                            }
                        } else {
                            showValidationError = true
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .alert("Invalid Input", isPresented: $showValidationError) {
                        Button("OK", role: .cancel) { showValidationError = false }
                    } message: {
                        Text("Please fill out all fields correctly before continuing.")
                    }

                    // Fixed NavigationLink here:
                    NavigationLink(
                        destination: predictionDestination,
                        isActive: $showPrediction
                    ) {
                        EmptyView()
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Diabix")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Computed property that returns the destination View
    var predictionDestination: some View {
        if viewModel.predictionData != nil {
            AnyView(
                MainTabView()
            )
        } else {
            AnyView(
                Text("Loading...")
                    .fontWeight(.black)
            )
        }
    }


    func validateInputs() -> Bool {
        let fields = [pregnancies, glucose, bloodPressure, skinThickness, insulin, bmi, dpf, age]
        return !fields.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty })
    }
}

struct HealthDataInputView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataInputView()
    }
}

struct CustomTextField: View {
    var label: String
    var hint: String? = nil
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            if let hint = hint {
                Text(hint)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            TextField(label, text: $text)
                .keyboardType(keyboard)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}
