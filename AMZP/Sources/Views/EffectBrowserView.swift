import SwiftUI

struct EffectBrowserView: View {
    @ObservedObject var vm: EditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: EffectCategoryFilter = .all
    @State private var showThumbnails = true
    @State private var sortMode: SortMode = .default_

    enum EffectCategoryFilter: String, CaseIterable {
        case all = "All"
        case lastAdded = "Last Added"
        case favorites = "Favorites"
        case glitch = "Glitch"
        case glow = "Glow"
        case color = "Color Grading"
        case blur = "Blur"
        case particles = "Particles"
        case transition = "Transition"
        case overlay = "Overlay"
        case texture = "Texture"
        case retro = "Retro"
        case lensflare = "Lensflare"
        case nature = "Nature"
        case archive = "Archive"
    }

    enum SortMode: String, CaseIterable {
        case default_ = "Default"
        case name = "Name"
        case recent = "Recently Used"
        case added = "Recently Added"
    }

    // mock effects list
    let effects: [(String, EffectCategoryFilter, String)] = [
        // name, category, icon
        ("RGB Split", .glitch, "waveform.path.ecg"),
        ("Glitch", .glitch, "bolt.horizontal"),
        ("Chromatic Aberration", .glitch, "circle.grid.cross"),
        ("Neon Glow", .glow, "sparkles"),
        ("Outer Glow", .glow, "sun.max"),
        ("Bloom", .glow, "rays"),
        ("LUT Color Grade", .color, "slider.horizontal.3"),
        ("Curves", .color, "chart.xyaxis.line"),
        ("HSL Adjust", .color, "paintpalette"),
        ("Gaussian Blur", .blur, "drop.halffull"),
        ("Motion Blur", .blur, "arrow.right.to.line"),
        ("Depth of Field", .blur, "camera.aperture"),
        ("Particle Rain", .particles, "cloud.drizzle"),
        ("Particle Snow", .particles, "snowflake"),
        ("Particle Stars", .particles, "star.fill"),
        ("Wipe", .transition, "rectangle.split.2x1"),
        ("Fade", .transition, "sun.haze"),
        ("Iris Out", .transition, "circle.dashed"),
        ("Light Leak", .overlay, "sun.and.horizon"),
        ("Film Grain", .overlay, "tv.and.mediabox"),
        ("Retro VHS", .retro, "play.rectangle"),
        ("Vintage Film", .retro, "film"),
        ("Lens Flare", .lensflare, "aqi.medium"),
        ("Anamorphic", .lensflare, "light.beacon.max"),
        ("Falling Leaves", .nature, "leaf"),
        ("Smoke", .nature, "smoke"),
        ("Fractal Warp", .archive, "wand.and.stars"),
        ("Posterize", .archive, "photo.stack"),
    ]

    var filtered: [(String, EffectCategoryFilter, String)] {
        var list = effects
        if selectedCategory != .all {
            list = list.filter { $0.1 == selectedCategory }
        }
        if !searchText.isEmpty {
            list = list.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
        }
        switch sortMode {
        case .name: list.sort { $0.0 < $1.0 }
        default: break
        }
        return list
    }

    let columns = [GridItem(.adaptive(minimum: 90, maximum: 120))]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // search + sort
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search effects...", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color(hex: "#1C1C1E"))
                    .cornerRadius(10)

                    Menu {
                        Picker("Sort", selection: $sortMode) {
                            ForEach(SortMode.allCases, id: \.self) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        Toggle("Show Thumbnails", isOn: $showThumbnails)
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                            .background(Color(hex: "#1C1C1E"))
                            .cornerRadius(10)
                    }
                }
                .padding(12)

                // category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EffectCategoryFilter.allCases, id: \.self) { cat in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = cat
                                }
                            } label: {
                                Text(cat.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == cat
                                                ? Color.purple
                                                : Color(hex: "#2A2A2E"))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 8)

                // effect grid
                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No effects found")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if showThumbnails {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(filtered, id: \.0) { name, cat, icon in
                                effectTile(name: name, icon: icon)
                            }
                        }
                        .padding(12)
                    }
                } else {
                    List(filtered, id: \.0) { name, cat, icon in
                        effectListRow(name: name, cat: cat, icon: icon)
                            .listRowBackground(Color(hex: "#1C1C1E"))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(hex: "#0D0D0D"))
            .navigationTitle("Effect Browser")
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
    private func effectTile(name: String, icon: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#1C1C1E"))
                    .frame(height: 70)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.purple.opacity(0.8))
            }
            Text(name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onTapGesture {
            if var layer = vm.selectedLayer {
                let eff = Effect(name: name, category: .glitch)
                vm.updateLayer(layer.id) { $0.effects.append(eff) }
            }
            dismiss()
        }
    }

    @ViewBuilder
    private func effectListRow(name: String, cat: EffectCategoryFilter, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                Text(cat.rawValue)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
