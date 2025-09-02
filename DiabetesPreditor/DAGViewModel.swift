//
//  DAGViewModel.swift
//  DiabetesPreditor
//
//  Created by Parry  on 23/08/2025.
//

import Foundation
@MainActor
class DAGViewModel: ObservableObject {
    @Published var nodes: [DAGNode] = []
    @Published var edges: [DAGEdge] = []
    
    func fetchDAG() async {
        guard let url = URL(string: "http://127.0.0.1:8000/dag_json") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let dag = try JSONDecoder().decode(DAGResponse.self, from: data)
            
            // Assign default positions (circle layout)
            let count = dag.nodes.count
            let radius: CGFloat = 120
            let center = CGPoint(x: 150, y: 150)
            
            var positionedNodes: [DAGNode] = []
            
            for (i, node) in dag.nodes.enumerated() {
                let angle = 2 * .pi * CGFloat(i) / CGFloat(count)
                let pos = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
                var newNode = node
                newNode.position = pos
                positionedNodes.append(newNode)
            }
            
            self.nodes = positionedNodes
            self.edges = dag.edges
        } catch {
            print("❌ Failed to fetch DAG:", error)
        }
    }
}
