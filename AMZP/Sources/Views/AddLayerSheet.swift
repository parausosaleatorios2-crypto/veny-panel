import SwiftUI

struct AddLayerSheet: View {
    @ObservedObject var vm: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(Layer.LayerType.allCases, id: \.self) { type in
                    Button {
                        vm.addLayer(type: type)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(iconBg(type))
                                    .frame(width: 40, height: 40)
                                Image(systemName: type.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue.capitalized + " Layer")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text(typeDescription(type))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.4))
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color(hex: "#1C1C1E"))
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("Add Layer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func iconBg(_ type: Layer.LayerType) -> Color {
        switch type {
        case .video: return .blue
        case .image: return .green
        case .text: return .orange
        case .audio: return .pink
        case .shape: return .teal
        case .adjustment: return .purple
        }
    }

    private func typeDescription(_ type: Layer.LayerType) -> String {
        switch type {
        case .video: return "Import a video clip"
        case .image: return "Import an image or PNG"
        case .text: return "Add animated text"
        case .audio: return "Import an audio track"
        case .shape: return "Draw vector shapes"
        case .adjustment: return "Color grades layers below"
        }
    }
}
