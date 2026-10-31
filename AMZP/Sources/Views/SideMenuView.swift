import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @AppStorage("appLanguage") private var appLanguage: String = "en"
    @State private var showOfficialInfo: Bool = false
    @State private var showAbout = false

    let languages = ["en": "English", "id": "Indonesian", "pt": "Português",
                     "es": "Español", "fr": "Français", "de": "Deutsch",
                     "ja": "日本語", "zh": "中文", "ko": "한국어",
                     "ru": "Русский", "it": "Italiano", "nl": "Nederlands",
                     "tr": "Türkçe", "ar": "العربية", "hi": "हिन्दी",
                     "pl": "Polski", "uk": "Українська", "vi": "Tiếng Việt",
                     "th": "ไทย"]

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // header
                VStack(alignment: .leading, spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#1A1AFF"), Color(hex: "#7B2FFF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 52, height: 52)
                        Text("AM")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                    }
                    Text("AMZP")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                    Text("Motion Editor · Build 678")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#111111"))

                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        menuItem(icon: "house", label: "Home") { isShowing = false }
                        menuItem(icon: "link", label: "Import From Link") {}
                        menuItem(icon: "square.and.arrow.down", label: "Import Package") {}
                        menuItem(icon: "square.and.arrow.up", label: "Export Package") {}

                        Divider().padding(.vertical, 6).opacity(0.3)

                        // language
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(languages.sorted(by: { $0.value < $1.value })),
                                        id: \.key) { code, name in
                                    Button {
                                        appLanguage = code
                                    } label: {
                                        HStack {
                                            Text(name)
                                                .font(.system(size: 14))
                                                .foregroundColor(appLanguage == code ? .purple : .white)
                                            Spacer()
                                            if appLanguage == code {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.purple)
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.leading, 36)
                                    }
                                }
                            }
                        } label: {
                            Label("Language", systemImage: "globe")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        Divider().padding(.vertical, 6).opacity(0.3)

                        // Official Info (foldable)
                        DisclosureGroup(isExpanded: $showOfficialInfo) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("AMZP is a modified version of Alight Motion with extended features. Not affiliated with Alight Creative.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 36)
                                    .padding(.bottom, 4)
                                infoLink("alightmotion.com", icon: "link")
                            }
                        } label: {
                            Label("Official Info", systemImage: "info.circle")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        Divider().padding(.vertical, 6).opacity(0.3)

                        menuItem(icon: "play.rectangle", label: "Demo Mode") {}
                        menuItem(icon: "arrow.clockwise", label: "Restart App") {}
                        menuItem(icon: "info.circle", label: "About") { showAbout = true }
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
            .frame(width: min(UIScreen.main.bounds.width * 0.78, 300))
            .background(Color(hex: "#0D0D0D"))

            Spacer()
        }
        .sheet(isPresented: $showAbout) { AboutView() }
    }

    @ViewBuilder
    private func menuItem(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 22)
                    .foregroundColor(.white.opacity(0.7))
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func infoLink(_ text: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.leading, 36)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [Color(hex: "#1A1AFF"), Color(hex: "#7B2FFF")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 90, height: 90)
                    Text("AM")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                }
                Text("AMZP Motion Editor")
                    .font(.title2.bold())
                Text("Build 678 — iOS Port")
                    .foregroundColor(.secondary)
                Text("Based on Alight Motion\nExtended with NmTools, NmLabs,\nand hundreds of new effects.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
