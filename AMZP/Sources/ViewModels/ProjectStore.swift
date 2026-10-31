import Foundation
import Combine

class ProjectStore: ObservableObject {
    @Published var projects: [AMZPProject] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    private let saveKey = "amzp_projects_v1"

    init() { load() }

    // MARK: - CRUD

    func create(name: String, width: Int = 1080, height: Int = 1920,
                frameRate: Double = 30, bg: String = "#000000") -> AMZPProject {
        var p = AMZPProject(name: name, frameRate: frameRate, width: width, height: height,
                            backgroundColor: bg)
        p.layers = [
            Layer(name: "Layer 1", type: .video)
        ]
        projects.insert(p, at: 0)
        save()
        return p
    }

    func delete(_ project: AMZPProject) {
        projects.removeAll { $0.id == project.id }
        save()
    }

    func update(_ project: AMZPProject) {
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            var p = project; p.modifiedAt = Date()
            projects[idx] = p
        }
        save()
    }

    func duplicate(_ project: AMZPProject) {
        var copy = project
        copy.id = UUID()
        copy.name = project.name + " Copy"
        copy.createdAt = Date()
        copy.modifiedAt = Date()
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects.insert(copy, at: idx + 1)
        }
        save()
    }

    // MARK: - Filter

    var filtered: [AMZPProject] {
        if searchText.isEmpty { return projects }
        return projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Persist

    private func save() {
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([AMZPProject].self, from: data)
        else {
            // projetos demo na primeira abertura
            projects = AMZPProject.demos
            return
        }
        projects = decoded
    }
}

extension AMZPProject {
    static var demos: [AMZPProject] {
        var p1 = AMZPProject(name: "My First Project")
        p1.layers = [
            Layer(name: "Background", type: .video),
            Layer(name: "Title", type: .text),
            Layer(name: "Music", type: .audio)
        ]
        var p2 = AMZPProject(name: "Intro Animation", frameRate: 60, width: 1920, height: 1080)
        return [p1, p2]
    }
}
