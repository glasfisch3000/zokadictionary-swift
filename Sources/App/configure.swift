import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public func configureDB(_ app: Application) async throws {
    app.databases.use(
        .postgres(
            configuration: .init(
				hostname: AppConfig.global.database.host,
				port: AppConfig.global.database.port,
				username: AppConfig.global.database.username,
				password: AppConfig.global.database.password,
				database: AppConfig.global.database.database,
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
	app.migrations.add(AddSoftDeleteTranslationsAndReferences())
	app.migrations.add(AddArgon2PasswordHashing())
	app.migrations.add(MakeOldPasswordHashesOptional())
	app.migrations.add(RemoveOldPasswordHashes())
	app.migrations.add(RemoveSoftDeleteTranslationsAndReferences())
	
	app.migrations.add(CreateAdminUser())
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
	app.leaf.tags["describeWordType"] = DescribeWordTypeTag()
	
	let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
	app.middleware.use(fileMiddleware)
    
    app.get("test") { req async in
        "It works!"
    }
	
	try app.routes
		.register(collection: WebRoutes())
}
