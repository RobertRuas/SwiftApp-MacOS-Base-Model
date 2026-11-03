import AppKit
import SwiftUI

@Observable
final class PanelController {
    var isExpanded = false
    var tabHovering = false

    @ObservationIgnored
    private var panel: NSPanel?

    @ObservationIgnored
    let state = AppState()

    static let tabWidth: CGFloat = 24
    static let contentWidth: CGFloat = 344
    static let panelWidth: CGFloat = tabWidth + contentWidth
    static let panelHeight: CGFloat = 420
    static let topMargin: CGFloat = 60
    static let tabHeight: CGFloat = 80
    static let titleBarHeight: CGFloat = 38

    init() {
        setupPanel()
    }

    private func setupPanel() {
        guard let screen = NSScreen.main else { return }
        let area = screen.visibleFrame

        let p = NSPanel(
            contentRect: NSRect(
                x: area.maxX - Self.tabWidth,
                y: area.maxY - Self.topMargin - Self.panelHeight,
                width: Self.panelWidth,
                height: Self.panelHeight
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        p.level = .floating
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.isMovableByWindowBackground = false
        p.hidesOnDeactivate = false

        p.contentView = NSHostingView(
            rootView: MainPanelView(controller: self, state: state)
        )

        p.orderFrontRegardless()
        panel = p
    }

    func toggle() {
        isExpanded.toggle()
        animatePanel()
    }

    func collapse() {
        guard isExpanded else { return }
        isExpanded = false
        state.showSettings = false
        animatePanel()
    }

    private func animatePanel() {
        guard let screen = NSScreen.main, let panel else { return }
        let area = screen.visibleFrame
        let targetX = isExpanded
            ? area.maxX - Self.panelWidth
            : area.maxX - Self.tabWidth

        panel.hasShadow = isExpanded

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.32
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(
                NSRect(
                    x: targetX,
                    y: area.maxY - Self.topMargin - Self.panelHeight,
                    width: Self.panelWidth,
                    height: Self.panelHeight
                ),
                display: true
            )
        }
    }
}
