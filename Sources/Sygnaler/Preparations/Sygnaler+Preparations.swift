import Fluent

extension Sygnaler {
    public var preparations: [Preparation.Type] {
        return [Pusher.self, Error.self]
    }
}
