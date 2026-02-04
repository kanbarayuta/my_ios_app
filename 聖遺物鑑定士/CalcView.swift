//
//  CalcView.swift
//  ArtifactAppraiser
//
import SwiftUI

struct CalcView: View {
    @Binding var screen: Screen
    @Binding var elapsed: TimeInterval
    @Binding var maxScore: Double
    @Binding var maxScoreArtifact: String
    let vm: ArtifactViewModel

    @State private var currentIndex = 0
    @State private var startTime: Date? = nil
    @State private var tokens: [String] = []
    var body: some View {
        ZStack {
            CalcBackground()
            ScrollView {
                VStack(spacing: 0) {
                    if vm.artifacts.indices.contains(currentIndex) {
                        let artifact = vm.artifacts[currentIndex]
                        VStack(spacing: 0) {
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(
                                        LinearGradient (
                                            colors: [.myRedBlack,.myRedLight,.myRedBlack],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                HStack {
                                    Text("原初の\(artifact.type.displayName)")
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                        .padding(8)
                                    Spacer()
                                    Text("\(currentIndex+1) / 20")
                                        .font(.system(size: 24).bold())
                                        .foregroundStyle(.myYellow)
                                        .padding(.trailing)
                                }
                            }
                            .frame(height: 48)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("古の\(artifact.type.displayName)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                HStack {
                                    VStack(alignment: .leading,spacing: 5) {
                                        Spacer().frame(height: 10)
                                        Text("\(artifact.mainStat.type.displayName)")
                                            .font(.body)
                                            .foregroundStyle(.white)
                                        Text("\(formattedValue(artifact.mainStat))")
                                            .font(.title.bold())
                                            .foregroundStyle(.white)
                                        Text("★★★★★")
                                            .font(.system(size: 22))
                                            .foregroundStyle(.myYellowStar)
                                    }
                                    Spacer()
                                    Image("\(artifact.type.imageName)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                }
                            }
                            .padding(.horizontal,24)
                            .padding(.vertical,8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient (
                                    colors: [.myPinkBlack, .myPinkLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            
                            VStack(alignment: .leading, spacing:5) {
                                Text("+20")
                                    .font(.system(size: 20).bold())
                                    .padding(.horizontal, 3)
                                    .foregroundStyle(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.myGray)
                                    )
                                ForEach(artifact.subStats.indices, id: \.self) { i in
                                    let stat = artifact.subStats[i]
                                    Text("・\(stat.type.displayName) \(formattedValue(stat))")
                                        .font(.system(size: 20).bold())
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(.myPinkThin)
                        }
                        .overlay(
                            Rectangle()
                                .stroke(
                                    LinearGradient (
                                        colors: [.myYellow,.gray],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 5
                                )
                                .shadow(color: .myYellow, radius: 5)
                        )
                        .padding(.horizontal)
                        
                    }
                    VStack(spacing: 0) {
                        VStack {
                            // 入力欄
                            Text(tokens.joined())
                                .font(.system(size: 36).bold())
                                .foregroundStyle(.myYellow)
                                .shadow(color: .myYellow, radius: 4)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.myYellow, lineWidth: 4)
                                        .shadow(color: .myYellow, radius: 4)
                                )
                            // 数字キーボード
                            NumberPad(tokens: $tokens)
                        }
                        
                        .padding(8)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.myYellow, lineWidth: 4)
                            .shadow(color: .myYellow, radius: 4)
                    )
                    .padding()
                    
                }
                .onAppear(perform: setupGame)
                
                .onChange(of: currentIndex) { _, newValue in
                    handleIndexChange(newValue)
                }
                
                .onChange(of: tokens) { _, newValue in
                    handleTokensChange(newValue)
                }
                
                .onDisappear(perform: saveElapsed)
            }
        }
    }

    func formattedValue(_ stat: Stat) -> String {
        if stat.type.isPercent {
            return String(format: "+%.1f%%", stat.value * 100)
        } else {
            return String(format: "+%.0f", stat.value)
        }
    }
    
    func currentScore() -> Double? {
        guard vm.artifacts.indices.contains(currentIndex) else { return nil }
        return vm.artifacts[currentIndex].score * 100
    }

    func inputValue() -> Double? {
        Double(tokens.joined())
    }
    
    private func setupGame() {
        startTime = Date()
        vm.startNewGame()
        maxScore = 0
        maxScoreArtifact = ""
    }

    private func handleIndexChange(_ index: Int) {
        if index >= vm.artifacts.count {
            screen = .result
        }
    }

    private func handleTokensChange(_ tokens: [String]) {
        guard
            let input = inputValue(),
            let score = currentScore()
        else { return }

        if abs(input - score) < 0.01 {
            let realScore = vm.artifacts[currentIndex].score * 100

            if realScore > maxScore {
                maxScore = realScore
                maxScoreArtifact = vm.artifacts[currentIndex].type.imageName
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentIndex += 1
                self.tokens.removeAll()
            }
        }
    }

    private func saveElapsed() {
        if let start = startTime {
            elapsed = Date().timeIntervalSince(start)
        }
    }

}
struct CalcBackground: View {
    var body: some View {
        GeometryReader { geo in
            if geo.size.width >= 600 {
                // iPad / 大画面用
                Image("mainBackgroundiPad")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            } else {
                // iPhone 用
                Image("mainBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: -15)
            }
        }
        .ignoresSafeArea()
    }
}
