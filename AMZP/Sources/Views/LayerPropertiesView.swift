import SwiftUI

struct LayerPropertiesView: View {
    @ObservedObject var vm: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    var layer: Layer? { vm.selectedLayer }

    var body: some View {
        NavigationStack {
            Group {
                if let layer {
                    layerForm(layer)
                } else {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "square.dashed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No layer selected")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .navigationTitle(layer?.name ?? "Properties")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func layerForm(_ layer: Layer) -> some View {
        Form {
            // Basic
            Section("Basic") {
                labeledRow("Name") {
                    Text(layer.name)
                        .foregroundColor(.gray)
                }
                labeledRow("Type") {
                    HStack(spacing: 6) {
                        Image(systemName: layer.type.icon)
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text(layer.type.rawValue.capitalized)
                            .foregroundColor(.gray)
                    }
                }
                labeledRow("Start") {
                    Text(String(format: "%.2fs", layer.startTime))
                        .foregroundColor(.gray)
                }
                labeledRow("End") {
                    Text(String(format: "%.2fs", layer.endTime))
                        .foregroundColor(.gray)
                }
                labeledRow("Duration") {
                    Text(String(format: "%.2fs", layer.endTime - layer.startTime))
                        .foregroundColor(.gray)
                }
            }
            .listRowBackground(Color(hex: "#1C1C1E"))

            // Transform
            Section("Transform") {
                opacityRow(layer)
                speedRow(layer)
            }
            .listRowBackground(Color(hex: "#1C1C1E"))

            // Color
            if layer.color != nil {
                Section("Color") {
                    colorRow(layer)
                }
                .listRowBackground(Color(hex: "#1C1C1E"))
            }

            // Effects
            Section("Effects (\(layer.effects.count))") {
                if layer.effects.isEmpty {
                    Text("No effects applied")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .listRowBackground(Color(hex: "#1C1C1E"))
                } else {
                    ForEach(layer.effects) { effect in
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(effect.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 13))
                                Text(effect.category.rawValue)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(Color(hex: "#1C1C1E"))
                    }
                    .onDelete { idx in
                        vm.updateLayer(layer.id) { $0.effects.remove(atOffsets: idx) }
                    }
                }
            }

            // Keyframes
            Section("Keyframes (\(layer.keyframes.count))") {
                if layer.keyframes.isEmpty {
                    Text("No keyframes")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .listRowBackground(Color(hex: "#1C1C1E"))
                } else {
                    ForEach(layer.keyframes) { kf in
                        HStack {
                            Image(systemName: "diamond.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text(kf.property)
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                            Spacer()
                            Text(String(format: "%.2fs", kf.time))
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .listRowBackground(Color(hex: "#1C1C1E"))
                    }
                }
            }

            // Visibility
            Section("Visibility") {
                Toggle(isOn: Binding(
                    get: { layer.isVisible },
                    set: { val in vm.updateLayer(layer.id) { $0.isVisible = val } }
                )) {
                    Label("Visible", systemImage: layer.isVisible ? "eye" : "eye.slash")
                        .foregroundColor(.white)
                }
                .tint(.purple)
                .listRowBackground(Color(hex: "#1C1C1E"))

                Toggle(isOn: Binding(
                    get: { layer.isLocked },
                    set: { val in vm.updateLayer(layer.id) { $0.isLocked = val } }
                )) {
                    Label("Locked", systemImage: layer.isLocked ? "lock.fill" : "lock.open")
                        .foregroundColor(.white)
                }
                .tint(.orange)
                .listRowBackground(Color(hex: "#1C1C1E"))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#0D0D0D"))
    }

    @ViewBuilder
    private func labeledRow<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 14))
            Spacer()
            content()
                .font(.system(size: 13))
        }
    }

    @ViewBuilder
    private func opacityRow(_ layer: Layer) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Opacity")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Spacer()
                Text("\(Int(layer.opacity * 100))%")
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
            Slider(value: Binding(
                get: { layer.opacity },
                set: { val in vm.updateLayer(layer.id) { $0.opacity = val } }
            ), in: 0...1)
            .tint(.purple)
        }
    }

    @ViewBuilder
    private func speedRow(_ layer: Layer) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Speed")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Spacer()
                Text(String(format: "%.2fx", layer.speed))
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
            Slider(value: Binding(
                get: { layer.speed },
                set: { val in vm.updateLayer(layer.id) { $0.speed = val } }
            ), in: 0.1...4.0, step: 0.05)
            .tint(.blue)
        }
    }

    @ViewBuilder
    private func colorRow(_ layer: Layer) -> some View {
        HStack {
            Text("Color")
                .foregroundColor(.white)
                .font(.system(size: 14))
            Spacer()
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: layer.color))
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    Text(layer.color)
                        .foregroundColor(.gray)
                        .font(.system(size: 12, design: .monospaced))
                }
        }
    }
}
