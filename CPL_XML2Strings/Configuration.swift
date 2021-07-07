//
//  Configuration.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

class Configuration {
    enum ConfigurationErrors: Error {
        case invalidParameter(parameter: String)
        case invalidArgument(argument: String, for: Constants.Parameters)
        case missingArgument(for: Constants.Parameters)

        var description: String {
            switch self {
            case .invalidParameter(let parameter): return "Parameter: \(parameter) is not recognized as valid."
            case .invalidArgument(let argument, let parameter): return "Parameter: \(parameter.rawValue) has an invalid argument: \(argument)."
            case .missingArgument(let parameter): return "Parameter: \(parameter.rawValue) is missing an argument."
            }
        }
    }

    enum Constants {
        enum Parameters: String {
            case inputFolder = "-i"
            case outputFolder = "-o"
            case outputName = "-n"
            case swapName = "-swap"
        }

        static let inputExtension = "xml"
        static let outputExtension = "strings"
        static let pluralsOutputExtension = "stringsdict"
        static let transifexFileString = "stringsxml_"
    }

    var inputFolder: String = Bundle.main.bundlePath
    var outputFolder: String = Bundle.main.bundlePath
    var localizableStringsFileName: String = "Localizable"
    var infoPlistStringsFileName: String = "InfoPlist"
    var languageFilenameSubstitutes = [String: String]()

    init(arguments: [String]) throws {
        var index = 0
        while index < arguments.count {
            // Making sure parameter is valid
            guard let parameter = Constants.Parameters(rawValue: arguments[index]) else { throw ConfigurationErrors.invalidParameter(parameter: arguments[index]) }

            // All parameters require at least 1 argument
            guard index + 1 < arguments.count else { throw ConfigurationErrors.missingArgument(for: parameter) }
            let firstArgument = arguments[index + 1]

            // Making sure there are no two consecutive parameters passed together
            guard Constants.Parameters(rawValue: firstArgument) == nil else { throw ConfigurationErrors.invalidArgument(argument: firstArgument, for: parameter) }

            switch parameter {
            case Constants.Parameters.inputFolder:
                inputFolder = firstArgument
            case Constants.Parameters.outputFolder:
                outputFolder = firstArgument
            case Constants.Parameters.outputName:
                localizableStringsFileName = firstArgument
            case Constants.Parameters.swapName:
                // This parameter requires 2 arguments
                guard index + 2 < arguments.count else { throw ConfigurationErrors.missingArgument(for: parameter) }
                let secondArgument = arguments[index + 2]

                // Making sure the second argument is also not a parameter
                guard Constants.Parameters(rawValue: secondArgument) == nil else { throw ConfigurationErrors.invalidArgument(argument: secondArgument, for: parameter) }

                languageFilenameSubstitutes[firstArgument] = secondArgument

                // Additional incrementation, since we are using 2 arguments
                index += 1
            }

            index += 2
        }
    }
}
