//
//  Model.swift
//  EasyPDFReader
//

import Foundation

enum Screen: Hashable {
    case pdf(id: UUID)
}

struct PDFFile: Identifiable, Codable {
    let id: UUID
    let fileURL: String
    var name: String
    var currentPage: Int
    var bookmarks: Set<Int>

    init(
        id: UUID = UUID(),
        fileURL: String,
        name: String,
        currentPage: Int = 0,
        bookmarks: Set<Int> = []
    ) {
        self.id = id
        self.fileURL = fileURL
        self.name = name
        self.currentPage = currentPage
        self.bookmarks = bookmarks
    }
}

