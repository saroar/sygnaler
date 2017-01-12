import Vapor
import HTTP

final class ErrorController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Error.all().makeNode().converted(to: JSON.self)
    }

    func show(request: Request, post: Error) throws -> ResponseRepresentable {
        return post
    }

    func makeResource() -> Resource<Error> {
        return Resource(
                index: index,
                show: show
        )
    }
}
