//
//  EasyPDFReaderApp.swift
//  EasyPDFReader
//

import SwiftUI

@main
struct pdf_prac5_listApp: App {
    @StateObject private var store = PDFStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
