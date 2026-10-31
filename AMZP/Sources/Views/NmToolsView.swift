import SwiftUI

struct NmToolsView: View {
    @ObservedObject var vm: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    struct NmTool: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let desc: String
        let action: () -> Void
    }

    var tools: [NmTool] {
        [
            NmTool(name: "Presets", icon: "star.fill", desc: "Load saved presets") {},
            NmTool(name: "Link Null/Cam", icon: "link", desc: "Link layer to null or camera") {},
            NmTool(name: "Beat Maker", icon: "music.note.list", desc: "Generate beat keyframes") {},
            NmTool(name: "Audio Keys", icon: "waveform", desc: "Audio-driven keyframes") {},
            NmTool(name: "Shift KF", icon: "arrow.left.arrow.right", desc: "Shift keyframes in time") {},
            NmTool(name: "Sequence", icon: "list.number", desc: "Sequence layer timing") {},
            NmTool(name: "Duplicate", icon: "doc.on.doc.fill", desc: "Duplicate up to 300 copies") {
                // duplicate selected layer up to 300x
            },
            NmTool(name: "Split Text", icon: "textformat.characters", desc: "Split by char / word / line") {},
            NmTool(name: "Reverse KF", icon: "arrow.uturn.left", desc: "Reverse keyframe order") {},
            NmTool(name: "Adj. Layer", icon: "slider.horizontal.3", desc: "Add adjustment layer") {
                vm.addLayer(type: .adjustment)
                dismiss()
            },
            NmTool(name: "Extend Layer", icon: "arrow.right.to.line.alt", desc: "Extend to composition end") {},
        ]
    }

    let columns = [GridItem(.adaptive(minimum: 100, maximum: 130))]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(tools) { tool in
                        nmTile(tool)
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("NmTools")
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
    private func nmTile(_ tool: NmTool) -> some View {
        Button(action: tool.action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#1E1E2E"))
                        .frame(height: 70)
                    Image(systemName: tool.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.purple)
                }
                Text(tool.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                Text(tool.desc)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
    }
}
