import SwiftUI

struct EditorView: View {
    @EnvironmentObject var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: EditorViewModel
    @State private var showAddLayer = false
    @State private var showEffectBrowser = false
    @State private var showExport = false
    @State private var showNmTools = false
    @State private var showNmLabs = false
    @State private var showLayerProperties = false
    @State private var showConfirmLeave = false

    init(project: AMZPProject) {
        _vm = StateObject(wrappedValue: EditorViewModel(project: project))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#0A0A0A").ignoresSafeArea()

            VStack(spacing: 0) {
                // top actionbar
                editorTopBar

                // canvas preview
                canvasPreview

                // taskbar
                editorTaskBar

                // layers / timeline
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        layerListHeader
                        if vm.project.layers.isEmpty {
                            emptyLayerHint
                        } else {
                            layerList
                        }
                        timelineStrip
                    }
                    .frame(height: geo.size.height)
                }

                // playback bar
                playbackBar
            }

            // NmLabs floating button
            nmLabsButton
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddLayer) { AddLayerSheet(vm: vm) }
        .sheet(isPresented: $showEffectBrowser) { EffectBrowserView(vm: vm) }
        .sheet(isPresented: $showExport) { ExportView(vm: vm) }
        .sheet(isPresented: $showNmTools) { NmToolsView(vm: vm) }
        .sheet(isPresented: $showNmLabs) { NmLabsView() }
        .sheet(isPresented: $showLayerProperties) {
            if let layer = vm.selectedLayer {
                LayerPropertiesView(vm: vm, layer: layer)
            }
        }
        .alert("Leave Editor?", isPresented: $showConfirmLeave) {
            Button("Stay", role: .cancel) {}
            Button("Leave", role: .destructive) {
                store.update(vm.project)
                dismiss()
            }
        } message: {
            Text("Unsaved changes will be lost.")
        }
    }

    // MARK: - Top Bar

    private var editorTopBar: some View {
        HStack(spacing: 8) {
            Button { showConfirmLeave = true } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .padding(8)
            }

            Text(vm.project.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            // undo/redo
            HStack(spacing: 4) {
                Button { vm.undo() } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .editorIconStyle()
                }
                .disabled(vm.undoStack.isEmpty)

                Button { vm.redo() } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .editorIconStyle()
                }
                .disabled(vm.redoStack.isEmpty)
            }

            Button { showExport = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Export")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(LinearGradient(colors: [Color(hex: "#1A1AFF"), Color(hex: "#7B2FFF")],
                                          startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#111111"))
    }

    // MARK: - Canvas

    private var canvasPreview: some View {
        ZStack {
            // checkerboard bg
            CheckerboardView().opacity(0.1)

            // canvas simulado
            Color(hex: vm.project.backgroundColor)
                .aspectRatio(CGFloat(vm.project.width) / CGFloat(vm.project.height),
                             contentMode: .fit)
                .overlay(
                    VStack {
                        Text("\(vm.project.width)×\(vm.project.height)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.3))
                    }
                )

            // preview quality badge
            VStack {
                HStack {
                    Spacer()
                    Text(vm.previewQuality.rawValue)
                        .font(.caption2.monospaced())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(6)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(Color.black)
    }

    // MARK: - Taskbar

    private var editorTaskBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                taskbarBtn("lock.fill",
                           label: vm.isPreviewLocked ? "Locked" : "Lock",
                           active: vm.isPreviewLocked) {
                    vm.isPreviewLocked.toggle()
                }
                taskbarBtn("sparkles", label: "Quality") { showEffectBrowser = true }
                taskbarBtn("speaker.wave.2", label: "Audio") {}
                taskbarBtn("gauge.medium", label: "Speed") {}
                taskbarBtn("arrow.counterclockwise", label: "Reset View") {}
                taskbarBtn("chart.xyaxis.line", label: "Easing") { vm.showEasingGraph.toggle() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .background(Color(hex: "#161616"))
    }

    @ViewBuilder
    private func taskbarBtn(_ icon: String, label: String,
                            active: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(active ? .purple : .white.opacity(0.7))
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(active ? .purple : .gray)
            }
        }
    }

    // MARK: - Layers

    private var layerListHeader: some View {
        HStack(spacing: 8) {
            Text("Layers")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            // select all, hide, link
            HStack(spacing: 12) {
                Button { /* select all */ } label: {
                    Image(systemName: "checkmark.square")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                Button { /* hide all */ } label: {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                Button { showAddLayer = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.purple)
                }
                // preset / NmTools
                Button { showNmTools = true } label: {
                    Text("NmTools")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.purple.opacity(0.7))
                        .cornerRadius(6)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "#141414"))
    }

    private var layerList: some View {
        List {
            ForEach(vm.project.layers) { layer in
                LayerRow(layer: layer, isSelected: vm.selectedLayerID == layer.id) {
                    vm.selectedLayerID = layer.id
                    showLayerProperties = true
                } onVisibility: {
                    vm.toggleVisible(layer)
                } onLock: {
                    vm.toggleLock(layer)
                } onDelete: {
                    vm.deleteLayer(layer)
                }
                .listRowBackground(
                    vm.selectedLayerID == layer.id
                    ? Color.purple.opacity(0.15)
                    : Color(hex: "#1A1A1A")
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
            }
            .onMove { from, to in vm.reorderLayers(from: from, to: to) }
            .onDelete { idx in
                for i in idx { vm.deleteLayer(vm.project.layers[i]) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(.active))
    }

    private var emptyLayerHint: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("No layers yet")
                .foregroundColor(.gray)
                .font(.callout)
            Button("Add Layer") { showAddLayer = true }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .font(.callout)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Timeline Strip

    private var timelineStrip: some View {
        ZStack(alignment: .leading) {
            Color(hex: "#0F0F0F")

            // track bars para cada layer
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    // ruler
                    timelineRuler

                    VStack(spacing: 2) {
                        ForEach(Array(vm.project.layers.enumerated()), id: \.element.id) { idx, layer in
                            timelineBar(layer: layer, row: idx)
                        }
                    }
                    .padding(.top, 22)

                    // playhead
                    let playheadX = CGFloat(vm.currentTime / vm.project.duration) * 800
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 1.5)
                        .offset(x: playheadX)
                }
                .frame(width: 800)
            }

            // marks
            ForEach(vm.marks) { mark in
                let markX = CGFloat(mark.time / vm.project.duration) * 300
                VStack(spacing: 0) {
                    Color(hex: mark.colorHex)
                        .frame(width: 2)
                    Text(mark.label)
                        .font(.system(size: 7))
                        .foregroundColor(Color(hex: mark.colorHex))
                        .fixedSize()
                }
                .offset(x: markX)
            }
        }
        .frame(height: 80)
        .clipped()
    }

    private var timelineRuler: some View {
        HStack(spacing: 0) {
            ForEach(0...Int(vm.project.duration), id: \.self) { sec in
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(sec)s")
                        .font(.system(size: 8))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(width: 800.0 / vm.project.duration, alignment: .leading)
                        .padding(.leading, 2)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 6)
                }
            }
        }
        .frame(height: 22)
    }

    private func timelineBar(layer: Layer, row: Int) -> some View {
        let pxPerSec = 800.0 / vm.project.duration
        let startX = layer.startTime * pxPerSec
        let width = (layer.endTime - layer.startTime) * pxPerSec

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(layerColor(layer.type).opacity(layer.isVisible ? 0.7 : 0.25))
                .frame(width: max(width, 20), height: 18)
                .overlay(
                    HStack {
                        Image(systemName: layer.type.icon)
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                        Text(layer.name)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                )
        }
        .offset(x: startX)
        .frame(width: 800, alignment: .leading)
    }

    private func layerColor(_ type: Layer.LayerType) -> Color {
        switch type {
        case .video: return .blue
        case .image: return .green
        case .text: return .orange
        case .audio: return .pink
        case .shape: return .teal
        case .adjustment: return .yellow
        }
    }

    // MARK: - Playback Bar

    private var playbackBar: some View {
        HStack(spacing: 20) {
            // tempo
            Text(timeString(vm.currentTime))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))

            Button { vm.seek(to: 0) } label: {
                Image(systemName: "backward.end.fill")
                    .foregroundColor(.white.opacity(0.7))
            }

            Button { vm.togglePlay() } label: {
                Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.purple))
            }

            Button { vm.seek(to: vm.project.duration) } label: {
                Image(systemName: "forward.end.fill")
                    .foregroundColor(.white.opacity(0.7))
            }

            // scrubber
            Slider(value: $vm.currentTime, in: 0...vm.project.duration) { editing in
                if !editing && vm.isPlaying { vm.play() }
                if editing { vm.pause() }
            }
            .tint(.purple)

            Text(timeString(vm.project.duration))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)

            // mark
            Button { vm.addMark() } label: {
                Image(systemName: "flag.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#111111"))
    }

    private var nmLabsButton: some View {
        Button { showNmLabs = true } label: {
            VStack(spacing: 0) {
                Text("NmLabs")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 26)
            .background(
                Capsule()
                    .fill(LinearGradient(colors: [Color(hex: "#FF6B00"), Color(hex: "#FF0080")],
                                        startPoint: .leading, endPoint: .trailing))
                    .shadow(color: .orange.opacity(0.4), radius: 6)
            )
        }
        .padding(.trailing, 16)
        .padding(.bottom, 100)
    }

    private func timeString(_ t: Double) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        let f = Int((t.truncatingRemainder(dividingBy: 1)) * vm.project.frameRate)
        return String(format: "%d:%02d:%02d", m, s, f)
    }
}

// MARK: - LayerRow

struct LayerRow: View {
    let layer: Layer
    let isSelected: Bool
    let onTap: () -> Void
    let onVisibility: () -> Void
    let onLock: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.4))
                .frame(width: 16)

            // type icon
            Image(systemName: layer.type.icon)
                .font(.system(size: 13))
                .foregroundColor(layerTypeColor)
                .frame(width: 20)

            Text(layer.name)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            // controls
            HStack(spacing: 12) {
                Button(action: onVisibility) {
                    Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                        .font(.system(size: 13))
                        .foregroundColor(layer.isVisible ? .white.opacity(0.6) : .gray.opacity(0.3))
                }

                Button(action: onLock) {
                    Image(systemName: layer.isLocked ? "lock.fill" : "lock.open")
                        .font(.system(size: 12))
                        .foregroundColor(layer.isLocked ? .orange : .white.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var layerTypeColor: Color {
        switch layer.type {
        case .video: return .blue
        case .image: return .green
        case .text: return .orange
        case .audio: return .pink
        case .shape: return .teal
        case .adjustment: return .yellow
        }
    }
}

// MARK: - Icon Style

extension Image {
    func editorIconStyle() -> some View {
        self.font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.7))
            .padding(8)
    }
}
