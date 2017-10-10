//
//  Configuration.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

class Configuration {
    static let inputFolderKey = "-i"
    static let outputFolderKey = "-o"
    static let outputNameKey = "-n"
    static let inputExtension = "xml"
    static let outputExtension = "strings"
    static let transifexFileString = "stringsxml_"

    var inputFolder: String = Bundle.main.bundlePath
    var outputFolder: String = Bundle.main.bundlePath
    var outputName: String = "Localizable"

    init(arguments: [String]) {
        for (index,argument) in arguments.enumerated() {
            switch argument {
            case Configuration.inputFolderKey where index + 1 < arguments.count:
                inputFolder = arguments[index + 1]
            case Configuration.outputFolderKey where index + 1 < arguments.count:
                outputFolder = arguments[index + 1]
            case Configuration.outputNameKey where index + 1 < arguments.count:
                outputName = arguments[index + 1]
            default:
                continue
            }
        }
    }
}
