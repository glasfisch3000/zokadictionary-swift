import ArgumentParser
import Vapor
import NIOFileSystem

struct Words: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "words",
        abstract: "Work with the database's stored words.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [WordsList.self, WordsGet.self, WordsCreate.self, WordsDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}
