import SwiftUI

struct ExplanationGraphView: View {
    @State private var zoomScale: CGFloat = 1.0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
        
                // SHAP Summary Plot Card
                card(title: "SHAP Summary Plot") {
                    Text("This SHAP plot explains which features most influenced your prediction. Larger bars mean greater contribution to risk.")
                        .font(.caption)
                        .foregroundColor(.gray)

                    AsyncImage(url: URL(string: "http://127.0.0.1:8000/shap")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(zoomScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in zoomScale = value }
                                    .onEnded { _ in withAnimation { zoomScale = 1.0 } }
                            )
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        ProgressView("Loading SHAP plot...")
                    }
                }

                // DAG Plot Card
                card(title: "Causal DAG (Directed Acyclic Graph)") {
                    Text("This DAG shows how features are causally related to diabetes. Arrows represent cause-effect directions.")
                        .font(.caption)
                        .foregroundColor(.gray)

                    AsyncImage(url: URL(string: "http://127.0.0.1:8000/dag")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(zoomScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in zoomScale = value }
                                    .onEnded { _ in withAnimation { zoomScale = 1.0 } }
                            )
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        ProgressView("Loading DAG graph...")
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Explanation")
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Reusable Card View
    @ViewBuilder
    func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
