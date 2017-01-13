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

        for (app, value) in apps {
            guard let appConfig = value.object else {
                throw AppError.custom("Missing config for \(app)")
            }

            do {
                let options = try buildOptions(config: appConfig, workDir: drop.workDir, appId: app)
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

    private func buildOptions(config: [String: Polymorphic], workDir: String, appId: String) throws -> Options {
        let authKey = config["authKey"]?.bool ?? false
        let appSufix = config["voip"]?.bool == true ? ".voip" : ""
        let topic = "\(appId)\(appSufix)"
        let certDirs = "\(workDir)Config/certs/"

        if authKey {
            guard let keyPath = config["keyPath"]?.string else {
                throw AppError.missingConfig("keyPath", appId)
            }

            guard let teamId = config["teamId"]?.string else {
                throw AppError.missingConfig("teamId", appId)
            }

            guard let keyId = config["keyId"]?.string else {
                throw AppError.missingConfig("keyId", appId)
            }

            return try Options(topic: topic, teamId: teamId, keyId: keyId, keyPath: "\(certDirs)\(keyPath)")
        } else {
            // certificates
            guard let certPath = config["certPath"]?.string else {
                throw AppError.missingConfig("certPath", appId)
            }

            guard let keyPath = config["keyPath"]?.string else {
                throw AppError.missingConfig("keyPath", appId)
            }

            return try Options(topic: topic, certPath: "\(certDirs)\(certPath)", keyPath: "\(certDirs)\(keyPath)")
        }
    }
}
