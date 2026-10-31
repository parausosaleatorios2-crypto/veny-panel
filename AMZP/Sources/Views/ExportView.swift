import SwiftUI

struct ExportView: View {
    @ObservedObject var vm: EditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    @State private var exportDone = false
    @State private var currentFrame = 0
    @State private var totalFrames: Int = 0

    var body: some View {
        NavigationStack {
            Form {
                // preview frame info
                Section {
                    HStack {
                        ZStack {
                            Color.black
                            Image(systemName: "film")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .frame(width: 100, height: 60)
                        .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(vm.project.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Text("\(vm.project.width)×\(vm.project.height) · \(Int(vm.project.frameRate)) fps")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.1f", vm.project.duration))s · \(vm.project.layers.count) layers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                Section("Format") {
                    Picker("Format", selection: $vm.exportSettings.format) {
                        ForEach(ExportSettings.ExportFormat.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                Section("Resolution") {
                    Picker("Quality", selection: $vm.exportSettings.resolution) {
                        ForEach(ExportSettings.ExportResolution.allCases, id: \.self) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                Section("Options") {
                    Toggle("Include Audio", isOn: $vm.exportSettings.includeAudio)
                        .tint(.purple)
                        .listRowBackground(Color(hex: "#1C1C1E"))

                    HStack {
                        Text("Quality")
                            .foregroundColor(.white)
                        Slider(value: Binding(
                            get: { Double(vm.exportSettings.quality) },
                            set: { vm.exportSettings.quality = Int($0) }
                        ), in: 50...100, step: 5)
                        .tint(.purple)
                        Text("\(vm.exportSettings.quality)%")
                            .foregroundColor(.gray)
                            .frame(width: 40)
                    }
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                // export progress
                if isExporting {
                    Section("Exporting") {
                        VStack(alignment: .leading, spacing: 8) {
                            ProgressView(value: exportProgress)
                                .tint(.purple)

                            HStack {
                                Text("Frame \(currentFrame) / \(totalFrames)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(exportProgress * 100))%")
                                    .font(.caption.bold())
                                    .foregroundColor(.purple)
                            }
                        }
                        .listRowBackground(Color(hex: "#1C1C1E"))
                    }
                }

                if exportDone {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Saved to Photos")
                                .foregroundColor(.green)
                        }
                        .listRowBackground(Color(hex: "#1C1C1E"))
                    }
                }

                Section {
                    Button {
                        startExport()
                    } label: {
                        HStack {
                            Spacer()
                            if isExporting {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 8)
                            }
                            Text(isExporting ? "Exporting…" : "Export")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(isExporting)
                    .listRowBackground(exportButtonBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("Advanced Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var exportButtonBackground: some View {
        if isExporting {
            Color.purple.opacity(0.4)
        } else {
            LinearGradient(colors: [Color(hex: "#1A1AFF"), Color(hex: "#7B2FFF")],
                           startPoint: .leading, endPoint: .trailing)
        }
    }

    private func startExport() {
        totalFrames = max(1, Int(vm.project.duration * vm.project.frameRate))
        currentFrame = 0
        exportProgress = 0
        exportDone = false
        isExporting = true

        // simulação de progresso de export
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            DispatchQueue.main.async {
                currentFrame += 1
                exportProgress = Double(currentFrame) / Double(totalFrames)
                if currentFrame >= totalFrames {
                    timer.invalidate()
                    isExporting = false
                    exportDone = true
                }
            }
        }
    }
}
