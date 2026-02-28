import SwiftUI

enum DemoMode {
    case none
    case empty
    case hotdog
    case notHotdog

    static func fromLaunchArguments() -> DemoMode {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-demo-hotdog") { return .hotdog }
        if args.contains("-demo-nothotdog") { return .notHotdog }
        if args.contains("-demo-empty") { return .empty }
        return .none
    }
}

@main
struct SeeFoodApp: App {
    private let demoMode = DemoMode.fromLaunchArguments()

    var body: some Scene {
        WindowGroup {
            ContentView(demoMode: demoMode)
        }
    }
}
