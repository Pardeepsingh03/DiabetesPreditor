//
//  DAGNode.swift
//  DiabetesPreditor
//
//  Created by Parry  on 23/08/2025.
//


import SwiftUI

struct DAGNode: Identifiable,Equatable, Codable {
    let id: String
    let label: String
    var position: CGPoint? // optional for layout
}

struct DAGEdge: Identifiable, Codable {
    let id = UUID()
    let source: String
    let target: String
}

struct DAGResponse: Codable {
    let nodes: [DAGNode]
    let edges: [DAGEdge]
}
