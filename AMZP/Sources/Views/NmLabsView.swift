import SwiftUI

struct NmLabsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("nmLabsEnabled_speedRamp") private var speedRamp = true
    @AppStorage("nmLabsEnabled_smoothSloMo") private var smoothSloMo = true
    @AppStorage("nmLabsEnabled_audioKeys") private var audioKeys = false
    @AppStorage("nmLabsEnabled_AIpalette") private var aiPalette = true
    @AppStorage("nmLabsEnabled_advExport") private var advExport = true
    @AppStorage("nmLabsEnabled_dafont") private var dafont = false
    @AppStorage("nmLabsEnabled_sfxDownload") private var sfxDownload = false
    @AppStorage("nmLabsEnabled_checkerboard") private var checkerboard = true
    @AppStorage("nmLabsEnabled_lockPreview") private var lockPreview = true
    @AppStorage("nmLabsEnabled_hideNmLabs") private var hideForNow = false

    var body: some View {
        NavigationStack {
            List {
                Section("Speed") {
                    toggle("Speed Ramp", desc: "RAMP button in speed panel", icon: "gauge.medium", binding: $speedRamp)
                    toggle("Smooth Slow Motion", desc: "Flow-blend between frames below 1x", icon: "tortoise.fill", binding: $smoothSloMo)
                }
                Section("Audio") {
                    toggle("Audio Keys", desc: "Audio-driven keyframe generation", icon: "music.note", binding: $audioKeys)
                    toggle("SFX Download", desc: "Search & download from Myinstants", icon: "arrow.down.circle", binding: $sfxDownload)
                    toggle("Dafont Browser", desc: "Download fonts from Dafont", icon: "textformat", binding: $dafont)
                }
                Section("Editor") {
                    toggle("AI Palette Prompt", desc: "Copies AI prompt to build palette from image", icon: "sparkles", binding: $aiPalette)
                    toggle("Lock Preview", desc: "Prevent preview from playing while scrubbing", icon: "lock.fill", binding: $lockPreview)
                    toggle("Checkerboard BG", desc: "Show transparency grid in preview", icon: "checkerboard.rectangle", binding: $checkerboard)
                }
                Section("Export") {
                    toggle("Advanced Export", desc: "Live frame preview during render", icon: "film.stack", binding: $advExport)
                }
                Section("NmLabs Button") {
                    toggle("Hide For Now", desc: "Hides the NmLabs floating button", icon: "eye.slash", binding: $hideForNow)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("NmLabs")
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
    private func toggle(_ title: String, desc: String, icon: String, binding: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .medium))
                Text(desc)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Spacer()
            Toggle("", isOn: binding)
                .tint(.purple)
                .labelsHidden()
        }
        .listRowBackground(Color(hex: "#1C1C1E"))
        .padding(.vertical, 2)
    }
}
