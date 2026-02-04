//
//  PDFStore.swift
//  EasyPDFReader
//

import SwiftUI
import Combine


@MainActor
final class PDFStore: ObservableObject {
    @Published var files: [PDFFile] = []
    private var lastSaveAt = Date.distantPast

    private let saveKey = "pdf_files"

    init() { load() }

    func index(for id: UUID) -> Int? {
        files.firstIndex { $0.id == id }
    }

    func file(for id: UUID) -> PDFFile? {
        files.first { $0.id == id }
    }

    func currentPage(for id: UUID) -> Int? {
        file(for: id)?.currentPage
    }

    func updateCurrentPage(_ page: Int, for id: UUID) {
        guard let index = index(for: id) else { return }
        files[index].currentPage = page
        if Date().timeIntervalSince(lastSaveAt) >= 1.0 {
            save()
            lastSaveAt = Date()
        }
    }

    func toggleBookmark(for id: UUID) {
        guard let index = index(for: id) else { return }
        let page = files[index].currentPage
        if files[index].bookmarks.contains(page) {
            files[index].bookmarks.remove(page)
        } else {
            files[index].bookmarks.insert(page)
        }
        save()
    }

    func isCurrentPageBookmarked(for id: UUID) -> Bool {
        guard let file = file(for: id) else { return false }
        return file.bookmarks.contains(file.currentPage)
    }
    func removeBookmark(page: Int, for id: UUID) {
        guard let index = index(for: id) else { return }
        files[index].bookmarks.remove(page)
        save()
    }

    func reset() {
        files = []
        UserDefaults.standard.removeObject(forKey: saveKey)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(files) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: saveKey),
            let savedFiles = try? JSONDecoder().decode([PDFFile].self, from: data)
        else { return }

        files = savedFiles
    }
    func forceSave() {
        save()
        lastSaveAt = Date()
    }

}

extension PDFStore {
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        ?? FileManager.default.temporaryDirectory
    }

    func url(for file: PDFFile) -> URL {
        documentsURL.appendingPathComponent(file.fileURL)
    }
    func rename(id: UUID, to newName: String) {
        guard let i = index(for: id) else { return }
        files[i].name = newName
        save()
    }
    func delete(id: UUID) {
        guard let i = index(for: id) else { return }
        let file = files[i]

        // Documentsの実ファイルも削除（失敗しても一覧削除は進める）
        let fileURL = documentsURL.appendingPathComponent(file.fileURL)
        try? FileManager.default.removeItem(at: fileURL)

        files.remove(at: i)
        save()
    }
    /// ファイルApp等から選んだPDFをDocumentsへコピーして登録
    func importPDF(from pickedURL: URL, displayName: String = "") throws {
        let ok = pickedURL.startAccessingSecurityScopedResource()
        defer { if ok { pickedURL.stopAccessingSecurityScopedResource() } }
        
        let ext = pickedURL.pathExtension.isEmpty ? "pdf" : pickedURL.pathExtension
        let newFileName = "\(UUID().uuidString).\(ext)"
        let dstURL = documentsURL.appendingPathComponent(newFileName)

        if FileManager.default.fileExists(atPath: dstURL.path) {
            try FileManager.default.removeItem(at: dstURL)
        }
        try FileManager.default.copyItem(at: pickedURL, to: dstURL)

        let defaultName = pickedURL.deletingPathExtension().lastPathComponent
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? defaultName : trimmed

        files.append(PDFFile(fileURL: newFileName, name: finalName))
        save()
    }
}
