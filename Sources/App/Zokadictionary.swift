import ArgumentParser

@main
struct Zokadictionary: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "zokadictionary",
//        abstract: <#T##String#>,
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [Serve.self, Routes.self, Migrate.self],
        groupedSubcommands: [
            CommandGroup(name: "Database manipulation", subcommands: [Words.self, References.self])
        ],
        defaultSubcommand: Serve.self,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}
