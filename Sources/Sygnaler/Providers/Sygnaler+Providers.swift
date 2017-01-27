import Vapor
import SwiftyBeaverVapor
import SwiftyBeaver

extension Sygnaler {
    public var providers: [Vapor.Provider] {
        return [configureLogProvider()]
    }

    private func configureLogProvider() -> Vapor.Provider {
        var destinations = [BaseDestination]()
        destinations.append(ConsoleDestination())

        if let appId = self.drop!.config["app", "sb_app_id"]?.string, appId.count > 0,
           let secretKey = self.drop!.config["app", "sb_secret_key"]?.string, secretKey.count > 0,
           let encryptionKey = self.drop!.config["app", "sb_encryption_key"]?.string, encryptionKey.count > 0 {
            let cloud = SBPlatformDestination(appID: appId, appSecret: secretKey, encryptionKey: encryptionKey)
            destinations.append(cloud)
        }

        return SwiftyBeaverProvider(destinations: destinations)
    }
}
