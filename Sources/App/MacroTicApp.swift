import AppKit

@main
enum SwiftAppBase {
    static let appDelegate = AppDelegate()

    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.delegate = appDelegate
        app.run()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: PanelController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        panelController = PanelController()
    }
}
