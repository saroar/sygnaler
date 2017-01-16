import Vapor
import Sygnaler

extension Sygnaler {
    func getDroplet() throws -> Droplet {
        return self.drop!
    }
}
