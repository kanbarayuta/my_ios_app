//
//  ArtifactModel.swift
//  ArtifactAppraiser
//
import Foundation

enum ArtifactType {
    case flower, plume, sands, goblet, circlet
}
extension ArtifactType {
    var displayName: String {
        switch self {
        case .flower:
            return "花"
        case .plume:
            return "羽"
        case .sands:
            return "時計"
        case .goblet:
            return "杯"
        case .circlet:
            return "冠"
        }
    }
    var imageName: String {
        switch self {
        case .flower:
            return "artifact01"
        case .plume:
            return "artifact02"
        case .sands:
            return "artifact03"
        case .goblet:
            return "artifact04"
        case .circlet:
            return "artifact05"
        }
    }
}

enum StatType: String, CaseIterable {
    case hpFlat, atkFlat, defFlat
    case hpPercent, atkPercent, defPercent
    case critRate, critDamage, energyRecharge
    case elementalMastery, healingBonus, elementalDamage
}
extension StatType {
    var displayName: String {
        switch self {
        case .hpFlat, .hpPercent:
            return "HP"
        case .atkFlat, .atkPercent:
            return "攻撃力"
        case .defFlat, .defPercent:
            return "防御力"
        case .critRate:
            return "会心率"
        case .critDamage:
            return "会心ダメージ"
        case .energyRecharge:
            return "元素チャージ効率"
        case .elementalMastery:
            return "元素熟知"
        case .healingBonus:
            return "治療効果"
        case .elementalDamage:
            return "元素ダメージ"
        }
    }

    var isPercent: Bool {
        switch self {
        case .hpPercent, .atkPercent, .defPercent, .critRate, .critDamage, .energyRecharge, .healingBonus, .elementalDamage:
            return true
        default:
            return false
        }
    }
}

struct Stat {
    let type: StatType
    let value: Double
}

struct Artifact {
    let id = UUID()
    let type: ArtifactType
    let mainStat: Stat
    let subStats: [Stat]
    let score: Double
}

struct ArtifactDatabase{
    static let mainStatPool: [ArtifactType: [StatType]] = [
        .flower: [.hpFlat],
        .plume: [.atkFlat],
        .sands: [.hpPercent, .atkPercent, .defPercent, .elementalMastery, .energyRecharge],
        .goblet: [.hpPercent, .atkPercent, .defPercent, .elementalMastery, .elementalDamage],
        .circlet: [.hpPercent, .atkPercent, .defPercent, .elementalMastery, .critRate, .critDamage, .healingBonus]
    ]

    static let mainStatValue: [StatType: Double] = [
        .hpFlat: 4780,
        .atkFlat: 311,
        .hpPercent: 0.466,
        .atkPercent: 0.466,
        .defPercent: 0.583,
        .elementalMastery: 186.5,
        .energyRecharge: 0.518,
        .critRate: 0.311,
        .critDamage: 0.622,
        .healingBonus: 0.359,
        .elementalDamage: 0.466
//        .hpFlat: 717,
//        .atkFlat: 47,
//        .hpPercent: 0.07,
//        .atkPercent: 0.07,
//        .defPercent: 0.087,
//        .elementalMastery: 28,
//        .energyRecharge: 0.078,
//        .critRate: 0.047,
//        .critDamage: 0.093,
//        .healingBonus: 0.054,
//        .elementalDamage: 0.07
    ]
    static let subStatRolls: [StatType: [Double]] = [
        .hpFlat: [209,239,268,298],
        .atkFlat: [13,15,17,19],
        .defFlat: [16,18,20,22],

        .hpPercent: [0.04,0.046,0.052,0.058],
        .atkPercent: [0.04,0.046,0.052,0.058],
        .defPercent: [0.051,0.058,0.065,0.072],

        .elementalMastery: [16,18,20,22],
        .energyRecharge: [0.045,0.052,0.058,0.064],
        .critRate: [0.027,0.031,0.035,0.039],
        .critDamage: [0.054,0.062,0.07,0.078]
    ]

}


