import SwiftUI

struct SidePanel: View {
    var controller: PanelController

    var body: some View {
        VStack {
            Spacer()
            ExpandCollapseButton(controller: controller)
            Spacer()
        }
        .frame(
            width: PanelController.tabWidth,
            height: PanelController.panelHeight - PanelController.titleBarHeight
        )
        .contextMenu {
            Button("Quit MacroTic") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

private struct ExpandCollapseButton: View {
    var controller: PanelController

    var body: some View {
        Button(action: { controller.toggle() }) {
            Image(systemName: controller.isExpanded
                  ? "chevron.compact.right"
                  : "chevron.compact.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .frame(width: PanelController.tabWidth, height: PanelController.tabHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(ExpandCollapseButtonStyle(isHovering: controller.tabHovering))
        .opacity(controller.tabHovering || controller.isExpanded ? 1 : 0.75)
        .animation(.easeOut(duration: 0.2), value: controller.isExpanded)
        .onHover { controller.tabHovering = $0 }
        .help(controller.isExpanded ? "Recolher painel" : "Expandir painel")
        .accessibilityLabel(controller.isExpanded ? "Recolher painel" : "Expandir painel")
        .accessibilityHint("Alterna entre o painel expandido e recolhido")
    }
}

private struct ExpandCollapseButtonStyle: ButtonStyle {
    var isHovering: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : (isHovering ? 1.08 : 1))
            .animation(.easeOut(duration: 0.15), value: isHovering)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
