import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var appTheme: String = "dark"
    @AppStorage("defaultFPS") private var defaultFPS: Double = 30
    @AppStorage("defaultResolution") private var defaultResolution: String = "1920x1080"
    @AppStorage("previewQuality") private var previewQuality: String = "full"
    @AppStorage("autoSave") private var autoSave = true
    @AppStorage("haptics") private var haptics = true
    @AppStorage("showRuler") private var showRuler = true
    @AppStorage("showGrid") private var showGrid = false
    @AppStorage("snapToGrid") private var snapToGrid = true

    let resolutions = ["1920x1080", "1280x720", "3840x2160", "1080x1920", "1080x1080"]
    let qualities   = ["full", "1/2", "1/4", "1/8", "1/12"]

    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $appTheme) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                        Text("System").tag("system")
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                // Project Defaults
                Section("New Project Defaults") {
                    Picker("Default FPS", selection: $defaultFPS) {
                        Text("24").tag(24.0)
                        Text("25").tag(25.0)
                        Text("30").tag(30.0)
                        Text("60").tag(60.0)
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(hex: "#1C1C1E"))

                    Picker("Default Resolution", selection: $defaultResolution) {
                        ForEach(resolutions, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                // Editor
                Section("Editor") {
                    Picker("Preview Quality", selection: $previewQuality) {
                        ForEach(qualities, id: \.self) { q in
                            Text(q).tag(q)
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color(hex: "#1C1C1E"))

                    Toggle("Auto Save", isOn: $autoSave)
                        .tint(.purple)
                        .foregroundColor(.white)
                        .listRowBackground(Color(hex: "#1C1C1E"))

                    Toggle("Show Ruler", isOn: $showRuler)
                        .tint(.purple)
                        .foregroundColor(.white)
                        .listRowBackground(Color(hex: "#1C1C1E"))

                    Toggle("Show Grid", isOn: $showGrid)
                        .tint(.purple)
                        .foregroundColor(.white)
                        .listRowBackground(Color(hex: "#1C1C1E"))

                    Toggle("Snap to Grid", isOn: $snapToGrid)
                        .tint(.purple)
                        .foregroundColor(.white)
                        .listRowBackground(Color(hex: "#1C1C1E"))
                }

                // Haptics
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $haptics)
                        .tint(.purple)
                        .foregroundColor(.white)
                        .listRowBackground(Color(hex: "#1C1C1E"))
                }

                // Storage
                Section("Storage") {
                    Button {
                        // clear temp files
                    } label: {
                        HStack {
                            Label("Clear Cache", systemImage: "trash")
                                .foregroundColor(.red)
                            Spacer()
                            Text("0 MB")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }

                // About
                Section("About") {
                    labeledRow("Version", value: "1.0.0 (Build 678)")
                    labeledRow("NmTools", value: "Enabled")
                    labeledRow("NmLabs", value: "Enabled")
                }
                .listRowBackground(Color(hex: "#1C1C1E"))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("Settings")
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
    private func labeledRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 14))
            Spacer()
            Text(value)
                .foregroundColor(.gray)
                .font(.system(size: 13))
        }
    }
}
