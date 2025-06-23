//
//  TeamControlView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import SwiftUI

struct TeamControlView: View {
    let teamName: String
    let score: Int
    let lastOperation: ScoreEntry?
    let onAddScore: (Int) -> Void
    let onUndo: () -> Void
    let canUndo: Bool
    
    private let scoreIncrements = [5, 10, 15, 20, 25, 30, 35]
    private let gridColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(teamName): \(score)")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let lastOp = lastOperation {
                    Text("(+\(lastOp.points))")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(scoreIncrements, id: \.self) { points in
                    Button(action: { onAddScore(points) }) {
                        Text("+\(points)")
                    }
                    .buttonStyle(ScoreButtonStyle(color: .blue))
                }
                
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .buttonStyle(ScoreButtonStyle(color: .red))
                .disabled(!canUndo)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}


#Preview("Team Controls") {
    TeamControlView(
        teamName: "Preview Team",
        score: 100,
        lastOperation: ScoreEntry(points: 15),
        onAddScore: { points in print("Add \(points)") },
        onUndo: { print("Undo") },
        canUndo: true
    )
    .preferredColorScheme(.dark)
    .padding()
}
