import SwiftUI

@Observable
final class AppState {
    var showSettings = false
    var showQuitConfirmation = false

    @ObservationIgnored
    let updater = UpdaterController()
}
