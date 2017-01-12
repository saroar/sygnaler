import Fluent

extension Error: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("errors") { errors in
            errors.id()
            errors.string("token")
            errors.string("last_failure_ts")
            errors.string("last_failure_type")
            errors.string("last_failure_code")
            errors.string("token_invalidated_at")
            errors.data("original_payload")
            errors.data("apns_payload")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete("errors")
    }
}
