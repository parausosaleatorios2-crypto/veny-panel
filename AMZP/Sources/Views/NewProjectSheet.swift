import SwiftUI

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onCreate: (String, Int, Int, Double, String) -> Void

    @State private var name: String = "My Project"
    @State private var selectedPreset: Int = 0
    @State private var customW: String = "1080"
    @State private var customH: String = "1920"
    @State private var selectedFPS: Double = 30
    @State private var bgColorHex: String = "#000000"
    @FocusState private var focusedField: Field?

    enum Field { case name, w, h, bg }

    let presets: [(String, Int, Int)] = [
        ("1080×1920 · Vertical", 1080, 1920),
        ("1920×1080 · Horizontal", 1920, 1080),
        ("1080×1080 · Square", 1080, 1080),
        ("2160×3840 · 4K Vertical", 2160, 3840),
        ("Custom", 0, 0)
    ]
    let fpsList: [Double] = [24, 25, 30, 60, 120]

    private var selectedW: Int {
        if presets[selectedPreset].2 == 0 { return Int(customW) ?? 1080 }
        return presets[selectedPreset].1
    }
    private var selectedH: Int {
        if presets[selectedPreset].2 == 0 { return Int(customH) ?? 1920 }
        return presets[selectedPreset].2
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Name") {
                    TextField("Untitled", text: $name)
                        .focused($focusedField, equals: .name)
                        .onTapGesture { name = "" }   // Select All on first tap
                }

                Section("Resolution") {
                    Picker("Preset", selection: $selectedPreset) {
                        ForEach(presets.indices, id: \.self) { i in
                            Text(presets[i].0).tag(i)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedPreset == presets.count - 1 {
                        HStack {
                            TextField("Width", text: $customW)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .w)
                            Text("×")
                            TextField("Height", text: $customH)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .h)
                        }
                    }
                }

                Section("Frame Rate & Duration") {
                    Picker("FPS", selection: $selectedFPS) {
                        ForEach(fpsList, id: \.self) { fps in
                            Text("\(Int(fps)) fps").tag(fps)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Background Color") {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: bgColorHex))
                            .frame(width: 32, height: 32)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.4)))
                        TextField("#000000", text: $bgColorHex)
                            .focused($focusedField, equals: .bg)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let n = name.trimmingCharacters(in: .whitespaces)
                        onCreate(n.isEmpty ? "Untitled" : n,
                                 selectedW, selectedH, selectedFPS, bgColorHex)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
