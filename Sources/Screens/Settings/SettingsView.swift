import SwiftUI

struct SettingsView: View {
    var state: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GeneralSection()
                UpdatesSection(updater: state.updater)
            }
            .padding(16)
        }
    }
}

private struct UpdatesSection: View {
    var updater: UpdaterController

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Atualizações")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text("SwiftApp-MacOS-Base-Model verifica e instala novas versões automaticamente em segundo plano.")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)

            Button(action: { updater.checkForUpdates() }) {
                Text("Verificar atualizações")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .disabled(!updater.canCheckForUpdates)
        }
    }
}

private struct GeneralSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Geral")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text("Mais configurações em breve")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
    }
}
