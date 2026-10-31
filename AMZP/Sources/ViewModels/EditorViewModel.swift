import Foundation
import Combine
import SwiftUI

class EditorViewModel: ObservableObject {
    @Published var project: AMZPProject
    @Published var currentTime: Double = 0
    @Published var isPlaying: Bool = false
    @Published var selectedLayerID: UUID? = nil
    @Published var previewQuality: PreviewQuality = .full
    @Published var isPreviewLocked: Bool = false
    @Published var showEasingGraph: Bool = false
    @Published var timelineScale: Double = 1.0   // zoom
    @Published var marks: [TimelineMark] = []
    @Published var exportSettings = ExportSettings()
    @Published var undoStack: [[Layer]] = []
    @Published var redoStack: [[Layer]] = []

    private var playTimer: Timer? = nil

    enum PreviewQuality: String, CaseIterable {
        case full = "Full", half = "1/2", quarter = "1/4",
             eighth = "1/8", twelfth = "1/12"
    }

    init(project: AMZPProject) {
        self.project = project
    }

    // MARK: - Playback

    func togglePlay() {
        isPlaying ? pause() : play()
    }

    func play() {
        guard !isPreviewLocked else { return }
        isPlaying = true
        playTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / project.frameRate,
                                        repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime += 1.0 / self.project.frameRate
            if self.currentTime >= self.project.duration {
                self.currentTime = 0
            }
        }
    }

    func pause() {
        isPlaying = false
        playTimer?.invalidate()
        playTimer = nil
    }

    func seek(to time: Double) {
        currentTime = max(0, min(time, project.duration))
    }

    // MARK: - Layer management

    var selectedLayer: Layer? {
        project.layers.first { $0.id == selectedLayerID }
    }

    func addLayer(type: Layer.LayerType) {
        pushUndo()
        let layer = Layer(name: "\(type.rawValue.capitalized) Layer",
                          type: type,
                          startTime: currentTime,
                          endTime: min(currentTime + 3, project.duration))
        project.layers.insert(layer, at: 0)
        selectedLayerID = layer.id
    }

    func deleteLayer(_ layer: Layer) {
        pushUndo()
        project.layers.removeAll { $0.id == layer.id }
        if selectedLayerID == layer.id { selectedLayerID = nil }
    }

    func toggleVisible(_ layer: Layer) {
        updateLayer(layer.id) { $0.isVisible.toggle() }
    }

    func toggleLock(_ layer: Layer) {
        updateLayer(layer.id) { $0.isLocked.toggle() }
    }

    func updateLayer(_ id: UUID, transform: (inout Layer) -> Void) {
        if let idx = project.layers.firstIndex(where: { $0.id == id }) {
            transform(&project.layers[idx])
        }
    }

    func reorderLayers(from: IndexSet, to: Int) {
        pushUndo()
        project.layers.move(fromOffsets: from, toOffset: to)
    }

    // MARK: - Undo/Redo

    func pushUndo() {
        undoStack.append(project.layers)
        redoStack.removeAll()
        if undoStack.count > 50 { undoStack.removeFirst() }
    }

    func undo() {
        guard let snapshot = undoStack.popLast() else { return }
        redoStack.append(project.layers)
        project.layers = snapshot
    }

    func redo() {
        guard let snapshot = redoStack.popLast() else { return }
        undoStack.append(project.layers)
        project.layers = snapshot
    }

    // MARK: - Marks

    func addMark(label: String = "Mark", color: String = "#FFD700") {
        let mark = TimelineMark(time: currentTime, label: label, colorHex: color)
        marks.append(mark)
    }

    func deleteMark(_ mark: TimelineMark) {
        marks.removeAll { $0.id == mark.id }
    }
}
