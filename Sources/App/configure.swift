import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configureDB(_ app: Application, _ config: AppConfig) async throws {
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: config.database.host,
                port: Int(config.database.port),
                username: config.database.user,
                password: config.database.password,
                database: config.database.database
            )
        ), as: .psql
    )
    
    app.migrations.add(CreateWord())
    app.migrations.add(CreateReference())
    app.migrations.add(CreateTranslation())
    app.migrations.add(CreateUser())
    app.migrations.add(UniqueUsername())
}

func configureRoutes(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.get { req async in
        "It works!"
    }

    let authenticated = app.grouped("api")
        .grouped(ErrorMiddleware())
        .grouped(AuthMiddleware(requiresMaintainer: false))
    
    @Sendable
    func authenticate(req: Request) -> Bool {
        return true
    }
        
    authenticated.get("checkauth", use: authenticate(req:))
    try authenticated.grouped("words").register(collection: WordController())
    try authenticated.grouped("translations").register(collection: TranslationsController())
    try authenticated.grouped("references").register(collection: ReferencesController())
}
