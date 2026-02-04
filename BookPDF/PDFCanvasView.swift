//
//  PDFCanvasView.swift
//  EasyPDFReader
//

import SwiftUI
import Combine
import PDFKit

struct PDFCanvasView: UIViewRepresentable {
    let url: URL
    let id: UUID
    let isSinglePageFit: Bool
    @EnvironmentObject var store: PDFStore

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .horizontal
        pdfView.displaysAsBook = true
        pdfView.semanticContentAttribute = .forceRightToLeft

        // 通知は一回だけ付ける
        context.coordinator.attach(to: pdfView)

        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        // 表示モード切替（Fit / Continuous）
        if context.coordinator.lastIsSinglePageFit != isSinglePageFit {
            context.coordinator.lastIsSinglePageFit = isSinglePageFit

            if isSinglePageFit {
                // 1枚を画面に収める（ページめくり）
                pdfView.usePageViewController(true, withViewOptions: nil)
                pdfView.displayMode = .singlePage
                pdfView.displayDirection = .horizontal
            } else {
                // 連続表示（スクロール）
                pdfView.usePageViewController(false, withViewOptions: nil)
                pdfView.displayMode = .singlePageContinuous
                pdfView.displayDirection = .horizontal
            }

            pdfView.autoScales = true
        }
        //  URLが変わった時だけ、逆順ドキュメントを作り直す
        if context.coordinator.lastURL != url {
            context.coordinator.lastURL = url
            context.coordinator.isReady = false

            guard let original = PDFDocument(url: url) else {
                pdfView.document = nil
                return
            }

            let reversed = makeReversedDocument(from: original)
            pdfView.document = reversed
            context.coordinator.pageCount = reversed.pageCount

            // 初期表示：currentPage(元PDF基準) -> reversedIndex へ変換して開く
            DispatchQueue.main.async {
                guard let doc = pdfView.document, doc.pageCount > 0 else { return }

                let pageCount = doc.pageCount
                let currentPageOriginal = store.currentPage(for: id) ?? 0

                // 0は「元PDFの0」扱い → reversedでは末尾
                let reversedIndex = pageCount - 1 - currentPageOriginal
                let safeIndex = max(0, min(reversedIndex, pageCount - 1))

                if let page = doc.page(at: safeIndex) {
                    context.coordinator.isProgrammaticMove = true
                    pdfView.go(to: page)
                    context.coordinator.isProgrammaticMove = false
                }

                context.coordinator.isReady = true
            }
            return
        }

        // 2) URL同じ：外部から currentPage が更新された時だけ必要なら移動
        guard let doc = pdfView.document, doc.pageCount > 0 else { return }
        let pageCount = doc.pageCount
        context.coordinator.pageCount = pageCount

        let currentPageOriginal = store.currentPage(for: id) ?? 0
        let reversedIndex = pageCount - 1 - currentPageOriginal
        let safeIndex = max(0, min(reversedIndex, pageCount - 1))

        if let current = pdfView.currentPage {
            let currentReversedIndex = doc.index(for: current)
            if currentReversedIndex == safeIndex { return } // もうそのページ
        }

        if let page = doc.page(at: safeIndex) {
            context.coordinator.isProgrammaticMove = true
            pdfView.go(to: page)
            context.coordinator.isProgrammaticMove = false
        }
    }

    static func dismantleUIView(_ uiView: PDFView, coordinator: Coordinator) {
        coordinator.detach()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(id: id, store: store)
    }

    // 逆順PDFDocumentを作る
    private func makeReversedDocument(from document: PDFDocument) -> PDFDocument {
        let newDocument = PDFDocument()
        for index in (0..<document.pageCount).reversed() {
            if let page = document.page(at: index) {
                newDocument.insert(page, at: newDocument.pageCount)
            }
        }
        return newDocument
    }

    final class Coordinator: NSObject {
        var lastIsSinglePageFit: Bool? = nil
        let id: UUID
        let store: PDFStore
        weak var pdfView: PDFView?

        var lastURL: URL?
        var pageCount: Int = 0

        var isProgrammaticMove = false
        var isReady = false
        private var isAttached = false

        init(id: UUID, store: PDFStore) {
            self.id = id
            self.store = store
        }

        func attach(to view: PDFView) {
            guard !isAttached else { return }
            isAttached = true
            self.pdfView = view

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(pageChanged(_:)),
                name: Notification.Name.PDFViewPageChanged,
                object: view
            )
        }

        func detach() {
            if let view = pdfView {
                NotificationCenter.default.removeObserver(self, name: Notification.Name.PDFViewPageChanged, object: view)
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }

        @objc private func pageChanged(_ notification: Notification) {
            // 初期ロード中のPDFKitの勝手な通知は無視
            if !isReady { return }
            if isProgrammaticMove { return }

            guard
                let view = notification.object as? PDFView,
                let page = view.currentPage,
                let doc = view.document
            else { return }

            let reversedIndex = doc.index(for: page)
            let pageCount = doc.pageCount

            // ★ 保存は「元PDF基準」に戻す
            let currentPageOriginal = pageCount - 1 - reversedIndex
            store.updateCurrentPage(currentPageOriginal, for: id)
        }
    }
}
