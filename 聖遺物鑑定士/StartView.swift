//
//  StartView.swift
//  ArtifactAppraiser
//
import SwiftUI

struct StartView: View {
    @Binding var screen:Screen
    @State private var showInfo = false
    var body: some View {
        ZStack {
            StartBackground()
            
            Button {
                showInfo.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .shadow(color: .myYellow, radius: 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding()
            .zIndex(10)
            
            VStack {
                Image("startTitle")
                    .resizable()
                    .scaledToFit()
                    .shadow(
                        color: .myYellow,
                        radius: 10,
                    )
                Spacer()
                Button {
                    screen = .calc
                } label: {
                    StartButtonLabel()
                }
                .padding(.bottom, 50)
            }
            
            if showInfo {
                InfoOverlay(showInfo: $showInfo)
            }
        }
    }
}

struct StartBackground: View {
    var body: some View {
        GeometryReader { geo in
            if geo.size.width >= 600 {
                // iPad / 大画面用
                Image("startBackgroundiPad")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            } else {
                // iPhone 用
                Image("startBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: -15)
            }
        }
        .ignoresSafeArea()
    }
}

struct InfoOverlay: View {
    @Binding var showInfo: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showInfo = false
                }

            VStack(spacing: 16) {
                Text("How to Play")
                    .font(.title.bold())
                    .foregroundStyle(.myYellow)

                Text("""
表示される聖遺物の
スコアを暗算で計算して
正しい数値を入力してください。

計算方法はサブステータスの
攻撃力％+会心率×2+会心ダメージ
になります
""")
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

                Button("Close") {
                    showInfo = false
                }
                .foregroundStyle(.myYellow)
                .padding(.top, 12)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.myYellow, lineWidth: 2)
            )
            .padding(32)
        }
    }
}

struct StartButtonLabel: View {
    var body: some View {
        Text("START")
            .font(.system(size: 48))
            .foregroundStyle(.myYellow)
            .shadow(
                color: .myYellow.opacity(0.8),
                radius: 6
            )
            .padding(.horizontal, 40)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.myGray.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.myYellow, lineWidth: 4)
                    .shadow(
                        color: .myYellow,
                        radius: 5
                    )
            )
    }
}
