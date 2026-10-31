import Foundation
import SwiftUI

// MARK: - Project

struct AMZPProject: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    var frameRate: Double = 30.0
    var width: Int = 1080
    var height: Int = 1920
    var duration: Double = 5.0           // seconds
    var backgroundColor: String = "#000000"
    var layers: [Layer] = []
    var thumbnailName: String? = nil

    // Formato legível "1080×1920 · 30fps"
    var formatLabel: String {
        "\(width)×\(height) · \(Int(frameRate))fps"
    }
}

// MARK: - Layer

struct Layer: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var type: LayerType
    var startTime: Double = 0
    var endTime: Double = 5
    var opacity: Double = 1.0
    var isLocked: Bool = false
    var isVisible: Bool = true
    var speed: Double = 1.0
    var color: String = "#FFFFFF"
    var effects: [Effect] = []
    var keyframes: [Keyframe] = []

    enum LayerType: String, Codable, CaseIterable {
        case video, image, text, audio, shape, adjustment
        var icon: String {
            switch self {
            case .video:      return "film"
            case .image:      return "photo"
            case .text:       return "textformat"
            case .audio:      return "waveform"
            case .shape:      return "square.on.circle"
            case .adjustment: return "slider.horizontal.3"
            }
        }
    }
}

// MARK: - Effect

struct Effect: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var category: EffectCategory
    var intensity: Double = 1.0
    var isEnabled: Bool = true

    enum EffectCategory: String, Codable, CaseIterable {
        case glitch, glow, color, blur, distortion, particles,
             transition, overlay, texture, retro, lensflare, nature
        var displayName: String { rawValue.capitalized }
    }
}

// MARK: - Keyframe

struct Keyframe: Identifiable, Codable {
    var id: UUID = UUID()
    var time: Double
    var property: String
    var value: Double
    var easing: EasingType = .linear

    enum EasingType: String, Codable {
        case linear, easeIn, easeOut, easeInOut, bezier
    }
}

// MARK: - TimelineMark

struct TimelineMark: Identifiable, Codable {
    var id: UUID = UUID()
    var time: Double
    var label: String
    var colorHex: String = "#FFD700"
}

// MARK: - ExportSettings

struct ExportSettings: Codable {
    var resolution: ExportResolution = .full
    var format: ExportFormat = .mp4
    var fps: Double = 30
    var quality: Int = 95
    var includeAudio: Bool = true

    enum ExportResolution: String, Codable, CaseIterable {
        case full = "Full", half = "1/2", quarter = "1/4", eighth = "1/8"
    }
    enum ExportFormat: String, Codable, CaseIterable {
        case mp4 = "MP4", gif = "GIF", png = "PNG Sequence", mov = "MOV"
    }
}
