import SwiftUI

struct TitleBar: View {
    var controller: PanelController
    var state: AppState

    var body: some View {
        HStack {
            Button(action: { state.showQuitConfirmation = true }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(TitleBarButtonStyle())
            .help("Fechar o SwiftApp-MacOS-Base-Model")
            .accessibilityLabel("Fechar aplicativo")
            .accessibilityHint("Encerra o SwiftApp-MacOS-Base-Model completamente")
            .alert(
                "Fechar o SwiftApp-MacOS-Base-Model?",
                isPresented: Binding(
                    get: { state.showQuitConfirmation },
                    set: { state.showQuitConfirmation = $0 }
                )
            ) {
                Button("Cancelar", role: .cancel) {}
                Button("Fechar", role: .destructive) {
                    NSApplication.shared.terminate(nil)
                }
            } message: {
                Text("Isso vai encerrar o SwiftApp-MacOS-Base-Model completamente.")
            }

            Spacer()

            Button(action: { state.showSettings.toggle() }) {
                Image(systemName: state.showSettings ? "gearshape.fill" : "gearshape")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(state.showSettings ? .primary : .secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(TitleBarButtonStyle())
            .help(state.showSettings ? "Fechar configurações" : "Abrir configurações")
            .accessibilityLabel(state.showSettings ? "Fechar configurações" : "Abrir configurações")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

private struct TitleBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                Circle()
                    .fill(.primary.opacity(configuration.isPressed ? 0.12 : 0))
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
