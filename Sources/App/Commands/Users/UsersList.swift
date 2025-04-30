import ArgumentParser
import Yams
import Vapor
import Fluent
import NIOFileSystem

struct UsersList: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List API users.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: .shortAndLong) // TODO: add description, 0 = no limit
    private var limit: UInt = 0
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var search: String?
    
    init() { }
    
    func run() async throws {
        let config = try await readAppConfig(path: configFile)
        
        let environment = self.environment ?? config.environment
        var env = environment.makeEnvironment()
        env.commandInput.arguments = []
        
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
        // let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])
        
        do {
            try await configureDB(app, config)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        var query = User.query(on: app.db)
        
        if let search = search {
            query = query.filter(\.$name =~ search)
        }
        
        let users = try await query
            .range(lower: 0, upper: self.limit == 0 ? nil : Int(self.limit))
            .all()
            .map { $0.toDTO() }
        
        try await app.asyncShutdown()
        
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let data = try encoder.encode(users)
            guard let string = String(data: data, encoding: .utf8) else {
                throw StringEncodingError()
            }
            
            print(string)
        case .yaml:
            let encoder = YAMLEncoder()
            encoder.options.indent = 2
            encoder.options.sortKeys = true
            encoder.options.width = -1
            encoder.options.sequenceStyle = .block
            
            let string = try encoder.encode(users)
            print(string)
        }
    }
}
