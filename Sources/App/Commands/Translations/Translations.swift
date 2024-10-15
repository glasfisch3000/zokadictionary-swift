import ArgumentParser
import Vapor
import NIOFileSystem

struct Translations: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "translations",
        abstract: "Work with translations.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [TranslationsList.self, TranslationsGet.self, TranslationsCreate.self, TranslationsDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}
