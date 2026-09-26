import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public func configureDB(_ app: Application) async throws {
    app.databases.use(
        .postgres(
            configuration: .init(
				hostname: AppConfig.global.databaseHost,
                port: AppConfig.global.databasePort,
                username: AppConfig.global.databaseUsername,
                password: AppConfig.global.databasePassword,
                database: AppConfig.global.databaseName,
				tls: .prefer(try .init(configuration: .clientDefault)),
            )
        ), as: .psql
    )
    
    app.migrations.add(CreateWord())
    app.migrations.add(CreateReference())
    app.migrations.add(CreateTranslation())
    app.migrations.add(CreateUser())
    app.migrations.add(UniqueUsername())
	app.migrations.add(AddSoftDelete())
}

func configureRoutes(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	
	app.views.use(.leaf)
	
	let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
	app.middleware.use(fileMiddleware)
    
    app.get { req async in
        "It works!"
    }
}
