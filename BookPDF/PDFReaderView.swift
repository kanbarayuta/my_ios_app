//
//  PDFReaderView.swift
//  EasyPDFReader
//
import SwiftUI
import PDFKit

struct PDFReader: View {
    let id: UUID
    @EnvironmentObject private var store: PDFStore

    @State private var showBookmarks = false
    @State private var isSinglePageFit = true

    var body: some View {
        Group {
            if let file = store.file(for: id) {
                let url = store.url(for: file)

                PDFCanvasView(url: url, id: id, isSinglePageFit: isSinglePageFit)
                    .navigationTitle(file.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .background(DisableSwipeBackView())
            } else {
                Text("PDFが見つかりません")
            }

        }
        .onDisappear {
            store.forceSave()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isSinglePageFit.toggle()
                } label: {
                    Image(systemName: isSinglePageFit ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
                }
                // しおりトグル
                Button {
                    store.toggleBookmark(for: id)
                } label: {
                    Image(systemName: store.isCurrentPageBookmarked(for: id) ? "bookmark.fill" : "bookmark")
                }

                // しおり一覧を開く（本アイコン）
                Button {
                    showBookmarks = true
                } label: {
                    Image(systemName: "book")
                }
                
            }
        }
        .sheet(isPresented: $showBookmarks) {
            if let file = store.file(for: id) {
                let url = store.url(for: file)
                if let doc = PDFDocument(url: url) {
                    BookmarkListView(id: id, pageCount: doc.pageCount)
                        .environmentObject(store)
                } else {
                    Text("PDFが開けません")
                }
            } else {
                Text("PDFが見つかりません")
            }
        }
    }
}

struct BookmarkListView: View {
    let id: UUID
    let pageCount: Int

    @EnvironmentObject private var store: PDFStore
    @Environment(\.dismiss) private var dismiss

    @State private var inputPageText = ""   // 1始まりで入力してもらう

    var body: some View {
        NavigationStack {
            List {
                // ヘッダー（ページジャンプ）
                Section {
                    HStack(spacing: 12) {
                        TextField("ページ", text: $inputPageText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 90)

                        Text("/ \(pageCount)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("ジャンプ") {
                            jump()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(pageCount == 0)
                    }
                }

                // しおり一覧
                Section("しおり") {
                    if let file = store.file(for: id) {
                        let pages = file.bookmarks.sorted()

                        if pages.isEmpty {
                            Text("しおりがありません")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(pages, id: \.self) { page in
                                Button {
                                    store.updateCurrentPage(page, for: id)
                                    store.forceSave()
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: "bookmark")
                                        Text("ページ \(page + 1)")
                                        Spacer()
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                let toRemove = indexSet.map { pages[$0] }
                                for p in toRemove {
                                    store.removeBookmark(page: p, for: id)
                                }
                            }
                        }
                    } else {
                        Text("データが見つかりません")
                    }
                }
            }
            .navigationTitle("しおり")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func jump() {
        // 入力は 1始まり想定 → storeは 0始まりで保存
        let trimmed = inputPageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let page1 = Int(trimmed) else { return }

        let page0 = page1 - 1
        let safe = max(0, min(page0, pageCount - 1))

        store.updateCurrentPage(safe, for: id)
        store.forceSave()
        dismiss()
    }
}


struct DisableSwipeBackView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            vc.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
