//
//  TeamView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import SwiftUI

struct TeamView: View {
    let team: String
    @StateObject private var scoreHistory: ScoreHistory = ScoreHistory()
    private var points: [Int] = [5, 10, 15, 20, 25, 30, 35]
    
    init(team: String) {
        self.team = team
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(team):")
                Text("\(scoreHistory.score)")
                    .font(.headline)
                if (scoreHistory.lastAction != nil) {
                    Text("(+\(scoreHistory.lastAction!))")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                ForEach(points, id: \.self) { score in
                    Button("+\(score)") {
                        scoreHistory.addScore(score)
                    }
                    .padding()
                    .frame(minWidth: 70)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    scoreHistory.undoLast()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .padding()
                        .frame(minWidth: 70)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding()
    }
}

#Preview {
    TeamView(team: "Default Team Name")
}
