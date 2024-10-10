import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configureDB(_ app: Application, _ config: AppConfig) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: try .init(url: config.databaseURL.absoluteString)),as: .psql)

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
