import ArgumentParser
import Vapor

struct Serve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "serve",
//        abstract: <#T##String#>,
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: ["run"]
    )
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment = .development
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var port: UInt16 = 8080
    
    @ArgumentParser.Option(name: [.long, .customShort("H")])
    private var hostname: String = "127.0.0.1"
    
    init() { }
    
    func run() async throws {
        var env = environment.makeEnvironment()
        env.commandInput.arguments = ["serve"]
        
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)
        
        app.http.server.configuration.port = Int(port)
        app.http.server.configuration.hostname = hostname

        try await runApp(app)
    }
}
