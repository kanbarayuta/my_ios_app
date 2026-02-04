//
//  PDFListView.swift
//  EasyPDFReader
//
import UniformTypeIdentifiers
import SwiftUI

struct PDFListView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var store: PDFStore

    @State private var showImporter = false

    // 名前編集用
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var renamingID: UUID?

    @State private var showDeleteConfirm = false
    @State private var deletingID: UUID?


    var body: some View {
        VStack {
            Text("PDF一覧")
                .font(.title.bold())
                .foregroundStyle(.black.opacity(0.6))
            ZStack{
                List {
                    ForEach(store.files) { file in
                        HStack {
                            Button {
                                path.append(Screen.pdf(id: file.id))
                            } label: {
                                HStack {
                                    Text(file.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .lineLimit(1)
                                        .truncationMode(.tail) // 末尾を…にする（省略）

                                    Spacer()

                                    HStack(spacing: 10) {
                                        Text("p.\(file.currentPage + 1)")
                                        Text("★ \(file.bookmarks.count)")
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())   // これが“どこ押しても反応するように
                            }
                            .buttonStyle(.plain)

                            Menu {
                                Button("名前変更") {
                                    renamingID = file.id
                                    renameText = file.name
                                    showRenameAlert = true
                                }
                                Button("削除", role: .destructive) {
                                    deletingID = file.id
                                    showDeleteConfirm = true
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .padding(.horizontal, 8)
                                    .contentShape(Rectangle())
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.delete(id: file.id)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { indexSet in
                        // List標準の編集削除にも対応したいなら（任意）
                        for index in indexSet {
                            let id = store.files[index].id
                            store.delete(id: id)
                        }
                    }
                }
                VStack {
                    Spacer()
                    Button("＋") { showImporter = true }
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 75, height: 75)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.blue.opacity(0.75))
                        )
                        
                    Spacer()
                        .frame(height: 150)
                }
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.pdf]) { result in
            do {
                let pickedURL = try result.get()
                try store.importPDF(from: pickedURL)
            } catch {
                print("Import error:", error)
                // ここはアラートにしてもOK
            }
        }
        .alert("名前を変更", isPresented: $showRenameAlert) {
            TextField("表示名", text: $renameText)
            Button("保存") {
                let newName = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                if let id = renamingID, !newName.isEmpty {
                    store.rename(id: id, to: newName)
                }
            }
            Button("キャンセル", role: .cancel) {}
        }

        .confirmationDialog("削除しますか？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                if let id = deletingID {
                    store.delete(id: id)
                }
            }
            Button("キャンセル", role: .cancel) {}
        }

    }
}
