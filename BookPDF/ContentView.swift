//
//  ContentView.swift
//  EasyPDFReader
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            PDFListView(path: $path)
                .navigationDestination(for: Screen.self) { screen in
                    if case .pdf(let id) = screen {
                        PDFReader(id: id)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PDFStore())
}

