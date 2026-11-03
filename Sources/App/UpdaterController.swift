import Sparkle

@Observable
final class UpdaterController {
    @ObservationIgnored
    private let standardController: SPUStandardUpdaterController

    init() {
        standardController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var canCheckForUpdates: Bool {
        standardController.updater.canCheckForUpdates
    }

    func checkForUpdates() {
        standardController.checkForUpdates(nil)
    }
}
