import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configureDB(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "zokadictionary",
        password: Environment.get("DATABASE_PASSWORD") ?? "zokadictionary",
        database: Environment.get("DATABASE_NAME") ?? "zokadictionary",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateWord())
    app.migrations.add(CreateReference())
    app.migrations.add(CreateTranslation())
}

func configureRoutes(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.get { req async in
        "It works!"
    }

    try app.register(collection: WordController())
}
