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
	app.migrations.add(UpdateUserType())
}

func configureRoutes(_ app: Application) throws {
	app.middleware.use(app.sessions.middleware)
	app.sessions.use(.memory)
	app.sessions.configuration.cookieFactory = { sessionID in
		HTTPCookies.Value(
			string: sessionID.string,
			expires: .now + AppConfig.global.sessionLifetime,
			maxAge: nil,
			domain: nil,
			path: "/",
			isSecure: true,
			isHTTPOnly: false,
			sameSite: .strict
		)
	}

	app.middleware.use(ErrorMiddleware())
	app.middleware.use(SessionAuthenticator())
	
	app.views.use(.leaf)
	app.leaf.tags["path"] = PathTag()
	
	let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
	app.middleware.use(fileMiddleware)
    
    app.get("test") { req async in
        "It works!"
    }
	
	try app.routes
		.register(collection: WebRoutes())
}
