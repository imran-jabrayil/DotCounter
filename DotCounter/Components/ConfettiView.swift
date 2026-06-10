//
//  ConfettiView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 10.06.26.
//

import SwiftUI

/// A lightweight, self-contained confetti burst used to celebrate a win.
///
/// Renders a fixed number of coloured pieces that fall and fade once, driven by
/// a single `animate` flag. There is no timer loop and no external dependency —
/// the parent shows the overlay, lets it animate, then removes it. Each piece's
/// random start position, colour, and timing are computed once at init so the
/// animation is stable across redraws.
struct ConfettiView: View {
    /// The number of confetti pieces to render.
    var pieceCount: Int = 80

    /// Drives the fall/fade animation; flipped to `true` by `onAppear`.
    @State private var animate = false

    /// Immutable per-piece visual + timing parameters, generated once.
    private let pieces: [Piece]

    /// One confetti piece's randomised, stable parameters.
    private struct Piece: Identifiable {
        let id = UUID()
        let xFraction: CGFloat   // horizontal start, 0...1 of the width
        let color: Color
        let size: CGFloat
        let delay: Double
        let duration: Double
        let spin: Double         // total rotation in degrees
        let drift: CGFloat       // horizontal drift in points
    }

    init(pieceCount: Int = 80) {
        self.pieceCount = pieceCount
        let palette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        self.pieces = (0..<pieceCount).map { _ in
            Piece(
                xFraction: .random(in: 0...1),
                color: palette.randomElement() ?? .blue,
                size: .random(in: 6...12),
                delay: .random(in: 0...0.4),
                duration: .random(in: 1.6...2.6),
                spin: .random(in: 180...720),
                drift: .random(in: -40...40)
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.6)
                        .rotationEffect(.degrees(animate ? piece.spin : 0))
                        .position(
                            x: piece.xFraction * geo.size.width + (animate ? piece.drift : 0),
                            y: animate ? geo.size.height + 40 : -40
                        )
                        .opacity(animate ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: animate
                        )
                }
            }
        }
        .allowsHitTesting(false) // purely decorative; never blocks taps
        .onAppear { animate = true }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        ConfettiView()
    }
}
