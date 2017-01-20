import Vapor
import VaporMySQL

extension Sygnaler {
    public var providers: [Vapor.Provider.Type] {
        return [VaporMySQL.Provider.self]
    }
}
