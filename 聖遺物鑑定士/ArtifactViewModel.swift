//
//  ArtifactViewModel.swift
//  ArtifactAppraiser
//
import SwiftUI

@Observable
class ArtifactViewModel {
    var artifacts: [Artifact] = []

    func startNewGame() {
        artifacts = (0..<20).map { _ in
            let type: ArtifactType = [.flower, .plume, .sands, .goblet, .circlet].randomElement()!
            return generateArtifact(type: type)
        }
    }

    private func generateArtifact(type: ArtifactType) -> Artifact {
        let mainType = ArtifactDatabase.mainStatPool[type]!.randomElement()!
        let mainValue = ArtifactDatabase.mainStatValue[mainType]!
        let mainStat = Stat(type: mainType, value: mainValue)

        // 火力3種
        let damageStats: [StatType] = [.atkPercent, .critRate, .critDamage]

        // メインと被らない火力系
        let availableDamage = damageStats.filter { $0 != mainType }

        // 火力系から必ず2つ選ぶ
        let guaranteed = Array(availableDamage.shuffled().prefix(2))

        // そのほかのサブステ候補（メイン除外・ロール可能なもの）
        var availableSubStats = StatType.allCases.filter {
            $0 != mainType && ArtifactDatabase.subStatRolls[$0] != nil
        }

        // すでに選んだ2つを除外
        availableSubStats.removeAll { guaranteed.contains($0) }

        var finalSubTypes = guaranteed

        // 残り2枠をランダムに埋める
        for _ in 0..<(4 - finalSubTypes.count) {
            let next = availableSubStats.randomElement()!
            finalSubTypes.append(next)
            availableSubStats.removeAll { $0 == next }
        }

        // 初期サブステ（4段階ロール）
        var subStats = finalSubTypes.map { type in
            let roll = ArtifactDatabase.subStatRolls[type]!.randomElement()!
            return Stat(type: type, value: roll)
        }

        // 5回の強化（毎回4段階ロール）
        for _ in 0..<5 {
            let i = Int.random(in: 0..<subStats.count)
            let type = subStats[i].type
            let roll = ArtifactDatabase.subStatRolls[type]!.randomElement()!

            subStats[i] = Stat(
                type: type,
                value: subStats[i].value + roll
            )
        }

        let score = calculateScore(subStats: subStats)
        return Artifact(type: type, mainStat: mainStat, subStats: subStats, score: score)
    }

    func calculateScore(subStats: [Stat]) -> Double {
        let atk = subStats.first(where: { $0.type == .atkPercent })?.value ?? 0
        let cr  = subStats.first(where: { $0.type == .critRate })?.value ?? 0
        let cd  = subStats.first(where: { $0.type == .critDamage })?.value ?? 0

        return atk + cr * 2 + cd
    }
}



