//
//  ContentView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = GameStore()
    @State private var showingAddGameView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(store.sortedGames) { game in
                    NavigationLink(destination: GameDetailView(game: game)) {
                        GameRowView(game: game)
                    }
                }
                .onDelete(perform: store.delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGameView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGameView) {
                AddGameView(store: store)
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview("ContentView Preview") {
    ContentView()
}
