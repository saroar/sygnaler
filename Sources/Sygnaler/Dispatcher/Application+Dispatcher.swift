import Vapor
import VaporAPNS

extension Application {
    internal func setupPushers(_ drop: Droplet) throws {
        guard let config = drop.config["pushers"]?.object,
              let apps = config["apps"]?.object else {
            throw AppError.noPusherConfig
        }

        Dispatcher.set(maxTries: config["max_tries"]?.int ?? 3)
        Dispatcher.set(logger: drop.log)

        let certDirs = "\(drop.workDir)Config/certs/"

        for (app, value) in apps {
            guard let appConfig = value.object else {
                throw AppError.custom("Missing config for \(app)")
            }

            guard let cert = appConfig["cert"]?.string else {
                throw AppError.missingConfig("cert", app)
            }

            guard let key = appConfig["key"]?.string else {
                throw AppError.missingConfig("key", app)
            }

            do {
                let options = try Options(topic: app, certPath: "\(certDirs)\(cert)", keyPath: "\(certDirs)\(key)")
                let APNSInstance = try VaporAPNS(options: options)
                let sandbox = appConfig["sandbox"]?.bool ?? false

                Dispatcher.append(id: app, sender: APNSInstance, sandbox: sandbox)
            } catch InitializeError.keyFileDoesNotExist {
                drop.log.warning("[CONFIG] \(app): \(InitializeError.keyFileDoesNotExist.description)")
            } catch InitializeError.certificateFileDoesNotExist {
                drop.log.warning("[CONFIG] \(app): \(InitializeError.certificateFileDoesNotExist.description)")
            } catch {
                drop.log.error("\(error)")
            }
        }

        if Dispatcher.count == 0 {
            throw AppError.noAppsConfigured
        }

        drop.log.info("Configured with app IDs \((Dispatcher.getAppIds()).joined(separator: ", "))")
    }
}
