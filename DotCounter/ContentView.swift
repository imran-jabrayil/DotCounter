//
//  ContentView.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 22.06.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TeamView(team: "Team 1")
            TeamView(team: "Team 2")
        }
    }
}

#Preview {
    ContentView()
}
