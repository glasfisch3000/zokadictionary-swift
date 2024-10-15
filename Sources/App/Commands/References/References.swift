import ArgumentParser
import Vapor
import NIOFileSystem

struct References: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "references",
        abstract: "Work with word references.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [ReferencesList.self, ReferencesGet.self, ReferencesCreate.self, ReferencesDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}
