import Vapor
//import VaporMySQL

extension Application {
    public var providers: [Vapor.Provider.Type] {
        return []
        //return [VaporMySQL.Provider.self]
    }
}
