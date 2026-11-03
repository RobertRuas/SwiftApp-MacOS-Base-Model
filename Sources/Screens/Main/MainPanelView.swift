import SwiftUI

struct MainPanelView: View {
    var controller: PanelController
    var state: AppState

    var body: some View {
        let panelShape = PanelShape(isExpanded: controller.isExpanded)

        VStack(spacing: 0) {
            TitleBar(controller: controller, state: state)
                .frame(width: PanelController.panelWidth)

            HStack(spacing: 0) {
                SidePanel(controller: controller)

                Group {
                    if state.showSettings {
                        SettingsView(state: state)
                            .transition(.opacity)
                    } else {
                        Color.clear
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(
            width: PanelController.panelWidth,
            height: PanelController.panelHeight
        )
        .background {
            panelShape.fill(.regularMaterial)
        }
        .overlay {
            panelShape.stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
                .allowsHitTesting(false)
        }
        .clipShape(panelShape)
        .shadow(
            color: .black.opacity(controller.isExpanded ? 0.2 : 0),
            radius: 12, x: -2, y: 2
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.easeInOut(duration: 0.32), value: controller.isExpanded)
        .animation(.spring(duration: 0.3), value: state.showSettings)
    }
}
