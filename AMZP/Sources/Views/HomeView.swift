import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ProjectStore
    @State private var showNewProject = false
    @State private var showSideMenu = false
    @State private var showSettings = false
    @State private var editingProject: AMZPProject? = nil
    @State private var editorProject: AMZPProject? = nil
    @AppStorage("appTheme") private var appTheme: String = "dark"

    // grid 2 colunas
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                // fundo
                themeBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // top bar
                    homeTopBar

                    // search
                    searchBar

                    // grid de projetos
                    if store.filtered.isEmpty {
                        emptyState
                    } else {
                        projectGrid
                    }
                }

                // side menu overlay
                if showSideMenu {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showSideMenu = false } }

                    SideMenuView(isShowing: $showSideMenu)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewProject) {
                NewProjectSheet { name, w, h, fps, bg in
                    let p = store.create(name: name, width: w, height: h, frameRate: fps, bg: bg)
                    editorProject = p
                }
            }
            .fullScreenCover(item: $editorProject) { project in
                EditorView(project: project)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Subviews

    private var themeBackground: Color {
        switch appTheme {
        case "amoled": return Color.black
        case "dark": return Color(hex: "#0D0D0D")
        default: return Color(hex: "#F0F0F0")
        }
    }

    private var homeTopBar: some View {
        HStack(spacing: 16) {
            Button { withAnimation(.spring()) { showSideMenu = true } } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }

            // logo
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [Color(hex: "#1A1AFF"), Color(hex: "#7B2FFF")],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                    Text("AM")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                }
                Text("AMZP")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            // tema switcher
            Menu {
                Button("Original") { appTheme = "original" }
                Button("Dark") { appTheme = "dark" }
                Button("AMOLED") { appTheme = "amoled" }
            } label: {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            }

            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#111111"))
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search projects...", text: $store.searchText)
                .foregroundColor(.white)
                .tint(.purple)
            if !store.searchText.isEmpty {
                Button { store.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var projectGrid: some View {
        ScrollView {
            // botão novo projeto
            Button { showNewProject = true } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                    Text("New Project")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [Color(hex: "#1A1AFF"), Color(hex: "#7B2FFF")],
                                  startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(14)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(store.filtered) { project in
                    ProjectCard(project: project) {
                        editorProject = project
                    } onDuplicate: {
                        store.duplicate(project)
                    } onDelete: {
                        store.delete(project)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.2))
            Text(store.searchText.isEmpty ? "No projects yet" : "No projects found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
            if store.searchText.isEmpty {
                Button("Create your first project") { showNewProject = true }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
            }
            Spacer()
        }
    }
}

// MARK: - ProjectCard

struct ProjectCard: View {
    let project: AMZPProject
    let onOpen: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    @State private var showMenu = false

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 0) {
                // thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(hex: project.backgroundColor).opacity(0.8))

                    // grade de preview simulada
                    CheckerboardView()
                        .opacity(0.15)

                    // ícone de tipo
                    Image(systemName: "film.stack")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(height: 110)
                .clipped()

                // info
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(project.formatLabel)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)

                    Text(project.modifiedAt.relativeString)
                        .font(.system(size: 10))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .background(Color(hex: "#1C1C1E"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .contextMenu {
            Button { onOpen() } label: { Label("Open", systemImage: "arrow.right.circle") }
            Button { onDuplicate() } label: { Label("Duplicate", systemImage: "doc.on.doc") }
            Divider()
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
        }
    }
}

// MARK: - CheckerboardView

struct CheckerboardView: View {
    var body: some View {
        Canvas { ctx, size in
            let tile: CGFloat = 8
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    let isLight = (Int(x / tile) + Int(y / tile)) % 2 == 0
                    ctx.fill(Path(CGRect(x: x, y: y, width: tile, height: tile)),
                             with: .color(isLight ? .white : .gray))
                    y += tile
                }
                x += tile
            }
        }
    }
}

// MARK: - Date helper

extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
