//
//  NumberPad.swift
//  ArtifactAppraiser
//

import SwiftUI

struct NumberPad: View {
    @Binding var tokens: [String]

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                key("7")
                key("8")
                key("9")
            }
            HStack(spacing: 10) {
                key("4")
                key("5")
                key("6")
            }
            HStack(spacing: 10) {
                key("1")
                key("2")
                key("3")
            }
            HStack(spacing: 10) {
                backspace()
                key("0")
                key(".")
            }
        }
        .padding(16)
    }

    // 数字・ドット
    private func key(_ value: String) -> some View {
        Button {
            add(value)
        } label: {
            KeyView(label: value)
        }
    }

    // ←
    private func backspace() -> some View {
        Button {
            if !tokens.isEmpty {
                tokens.removeLast()
            }
        } label: {
            KeyView(label: "←")
        }
    }

    // MARK: - 入力ロジック

    private func add(_ value: String) {
        if value == "." {
            // 小数点は1つまで
            if tokens.contains(".") { return }
            // 先頭が . なら 0.
            if tokens.isEmpty {
                tokens.append("0")
            }
        }
        tokens.append(value)
    }

    private func submit() {
        let text = tokens.joined()
        let number = Double(text) ?? 0
        print("入力:", number)
        // ここで答え判定など
    }
}
struct KeyView: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(.myYellow)
            .shadow(color: .myYellow, radius: 4)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.myYellow, lineWidth: 4)
                    .shadow(color: .white, radius: 4)
            )
    }
}
