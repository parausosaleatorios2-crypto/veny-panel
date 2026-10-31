import SwiftUI

@main
struct AMZPApp: App {
    @StateObject private var projectStore = ProjectStore()
    @AppStorage("appTheme") private var appTheme: String = "dark"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(projectStore)
                .preferredColorScheme(appTheme == "amoled" || appTheme == "dark" ? .dark : .light)
        }
    }
}
