//
//  TeamView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import SwiftUI

struct TeamView: View {
    let team: String
    @Binding var score: Int
    @State private var history: [Int] = []
    private let points: [Int] = [5, 10, 15, 20, 25, 30, 35]

    @State private var lastActionTime: Date = .distantPast
    private let throttleInterval: TimeInterval = 0.5
    
    @State private var isThrottlingActive: Bool = false

    init(team: String, score: Binding<Int>) {
        self.team = team
        self._score = score
    }

    var lastAdded: Int? {
        guard let last = history.last else { return nil }
        return last
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(team):")
                Text("\(score)")
                    .font(.headline)
                if let last = lastAdded {
                    Text("(+\(last))")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                ForEach(points, id: \.self) { value in
                    Button("+\(value)") {
                        let now = Date()
                        if now.timeIntervalSince(lastActionTime) > throttleInterval {
                            history.append(value)
                            score += value
                            lastActionTime = now
                            
                            isThrottlingActive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + throttleInterval) {
                                self.isThrottlingActive = false
                            }
                        }
                    }
                    .padding()
                    .frame(minWidth: 70)
                    .background(isThrottlingActive ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                    .disabled(isThrottlingActive)
                }

                Button(action: {
                    let now = Date()
                    if now.timeIntervalSince(lastActionTime) > throttleInterval {
                        if let last = history.popLast() {
                            score -= last
                        }
                        lastActionTime = now
                        
                        isThrottlingActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + throttleInterval) {
                            self.isThrottlingActive = false
                        }
                    }
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .padding()
                        .frame(minWidth: 70)
                        .background(isThrottlingActive ? Color.gray : Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                .disabled(isThrottlingActive)
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
    @Previewable @State var score = 25
    TeamView(team: "Preview Team", score: $score)
}
