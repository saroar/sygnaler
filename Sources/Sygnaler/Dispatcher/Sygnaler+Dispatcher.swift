import Vapor

extension Sygnaler {
    internal func prepareDispatcher(_ drop: Droplet) throws {
        let dispatcher = Dispatcher.sharedInstance

        dispatcher.set(logger: drop.log)
        dispatcher.set(maxTries: drop.config["app", "max_tries"]?.int ?? 3)
        dispatcher.set(certsDir: "\(drop.workDir)Config/certs/")
    }
}
