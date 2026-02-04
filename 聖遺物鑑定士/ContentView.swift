//
//  ContentView.swift
//  ArtifactAppraiser
//


import SwiftUI

enum Screen{
    case start
    case calc
    case result
}

struct ContentView: View {
    @State private var screen:Screen = .start
    @State var vm = ArtifactViewModel()
    @State private var calcElapsed: TimeInterval = 0
    @State private var maxScore: Double = 0
    @State private var maxScoreArtifact: String = ""
    var body: some View {
        ZStack {
            switch screen {
            case .start:
                StartView(screen: $screen)
            case .calc:
                CalcView(
                    screen: $screen,
                    elapsed: $calcElapsed,
                    maxScore: $maxScore,
                    maxScoreArtifact: $maxScoreArtifact,
                    vm: vm
                )
            case .result:
                ResultView(
                    screen: $screen,
                    elapsed: calcElapsed,
                    maxScore: maxScore,
                    maxScoreArtifact: maxScoreArtifact,
                )
            }
        }
    }
}


#Preview {
    ContentView()
}
