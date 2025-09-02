import SwiftUI

struct DAGView: View {
    @StateObject private var viewModel = DAGViewModel()
    @State private var selectedNode: DAGNode?
    @State private var nodePositions: [String: CGPoint] = [:]
    @State private var dragOffsets: [String: CGSize] = [:]

    private let nodeRadius: CGFloat = 30
    private let arrowLength: CGFloat = 14
    private let arrowWidth: CGFloat  = 10

    // 🔑 Hardcoded node descriptions
    private let nodeDescriptions: [String: String] = [
        "Age": """
        Age of the patient. As age increases, the likelihood of developing type 2 diabetes also increases.
        This is because the body may gradually lose efficiency in producing and using insulin over time.
        Age is therefore considered an important non-modifiable risk factor.
        """,

        "BMI": """
        Body Mass Index (BMI) is calculated using weight and height (kg/m²).
        A higher BMI often indicates overweight or obesity, which is strongly associated with insulin resistance
        and increased risk of type 2 diabetes. Maintaining a healthy BMI can reduce long-term risk.
        """,

        "Glucose": """
        Blood glucose level represents the amount of sugar in the blood.
        Elevated fasting or post-meal glucose levels are direct indicators of impaired glucose regulation
        and a major diagnostic factor for diabetes. Consistently high values can confirm diabetes presence.
        """,

        "Insulin": """
        Blood insulin level indicates how much insulin the body produces to regulate blood sugar.
        Abnormal levels (either too high or too low) may suggest insulin resistance or insufficient insulin production.
        These are both key features in the development of type 2 diabetes.
        """,

        "Pregnancies": """
        Number of pregnancies a patient has had. Pregnancy is associated with increased insulin resistance,
        and some women develop gestational diabetes during pregnancy.
        A higher number of pregnancies can slightly increase long-term diabetes risk.
        """,

        "BloodPressure": """
        Diastolic blood pressure (the lower value in a blood pressure reading) measures the pressure in blood vessels
        when the heart rests between beats. Chronic high blood pressure (hypertension) is a known risk factor
        for cardiovascular disease and is commonly seen in patients with diabetes or pre-diabetes.
        """,

        "SkinThickness": """
        Skin fold thickness (usually measured at the triceps) is used as an estimate of subcutaneous fat levels.
        Higher values are often linked with obesity and body fat distribution patterns, which can influence
        metabolic health and diabetes risk.
        """,

        "DiabetesPedigreeFunction": """
        A genetic risk score that estimates the likelihood of developing diabetes based on family history.
        Higher values indicate a stronger hereditary component, meaning the patient’s relatives are more likely
        to have diabetes, increasing the patient’s own risk.
        """
    ]


    var body: some View {
        ZStack {
            // ---- EDGES ----
            ForEach(viewModel.edges) { edge in
                if let s = nodePositions[edge.source],
                   let t = nodePositions[edge.target] {
                    drawEdge(from: s, to: t, source: edge.source, target: edge.target)
                }
            }
            
            // ---- NODES ----
            ForEach(viewModel.nodes) { node in
                if let pos = nodePositions[node.id] {
                    let offset = dragOffsets[node.id] ?? .zero
                    nodeView(for: node, pos: pos, offset: offset)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 400)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            Task {
                await viewModel.fetchDAG()
                for node in viewModel.nodes {
                    if let p = node.position { nodePositions[node.id] = p }
                }
            }
        }
        // 🔑 Apple Maps style bottom sheet
        .sheet(item: $selectedNode) { node in
            VStack(spacing: 20) {
                // Drag indicator
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.top, 8)

                // Node title
                Text(node.label)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                // Node description card
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(nodeDescriptions[node.label] ?? "No description available.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemBackground))
                    .ignoresSafeArea()
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }

    }
    
    // MARK: - Edge Drawing
    private func drawEdge(from s: CGPoint, to t: CGPoint, source: String, target: String) -> some View {
        let sPos = CGPoint(x: s.x + (dragOffsets[source]?.width  ?? 0),
                           y: s.y + (dragOffsets[source]?.height ?? 0))
        let tPos = CGPoint(x: t.x + (dragOffsets[target]?.width  ?? 0),
                           y: t.y + (dragOffsets[target]?.height ?? 0))
        
        let dx = tPos.x - sPos.x
        let dy = tPos.y - sPos.y
        let dist = max(0.0001, sqrt(dx*dx + dy*dy))
        let ux = dx / dist, uy = dy / dist
        let nx = -uy, ny = ux
        
        let start = CGPoint(x: sPos.x + ux*nodeRadius, y: sPos.y + uy*nodeRadius)
        let end   = CGPoint(x: tPos.x - ux*nodeRadius, y: tPos.y - uy*nodeRadius)
        
        let baseCenter = CGPoint(x: end.x - ux*arrowLength, y: end.y - uy*arrowLength)
        let tip  = end
        let left = CGPoint(x: baseCenter.x + nx*(arrowWidth/2), y: baseCenter.y + ny*(arrowWidth/2))
        let right = CGPoint(x: baseCenter.x - nx*(arrowWidth/2), y: baseCenter.y - ny*(arrowWidth/2))
        
        return ZStack {
            Path { p in
                p.move(to: start)
                p.addLine(to: end)
            }
            .stroke(
                LinearGradient(colors: [.gray.opacity(0.7), .black],
                               startPoint: .leading,
                               endPoint: .trailing),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            
            Path { p in
                p.move(to: tip)
                p.addLine(to: left)
                p.addLine(to: right)
                p.closeSubpath()
            }
            .fill(Color.black.opacity(0.8))
        }
    }

    // MARK: - Node Drawing
    private func nodeView(for node: DAGNode, pos: CGPoint, offset: CGSize) -> some View {
        let isSelected = selectedNode?.id == node.id
        let finalX = pos.x + offset.width
        let finalY = pos.y + offset.height

        return Circle()
            .fill(isSelected ? Color.blue : Color.orange)
            .frame(width: 60, height: 60)
            .overlay(
                Text(node.label)
                    .foregroundColor(.white)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(4)
            )
            .position(x: finalX, y: finalY)
            .gesture(
                DragGesture()
                    .onChanged { dragOffsets[node.id] = $0.translation }
                    .onEnded { _ in
                        nodePositions[node.id] = CGPoint(
                            x: pos.x + (dragOffsets[node.id]?.width ?? 0),
                            y: pos.y + (dragOffsets[node.id]?.height ?? 0)
                        )
                        dragOffsets[node.id] = .zero
                    }
            )
            .onTapGesture { selectedNode = node }
    }
}
