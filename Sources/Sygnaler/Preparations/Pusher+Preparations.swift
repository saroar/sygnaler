import Fluent

extension Pusher: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("pushers") { apps in
            apps.id()
            apps.string("name", unique: true)
            apps.string("bundle_id", unique: true)
            apps.bool("voip")
            apps.string("team_id", length: 10, unique: false)
            apps.string("key_id", length: 10, unique: false)
            apps.string("key_path", unique: true)
            apps.bool("sandbox")
            apps.bool("enabled")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("pushers")
    }
}
