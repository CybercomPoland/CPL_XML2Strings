//
//  main.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

do {
    var arguments = CommandLine.arguments
    // First argument is the executable file path. We don't need that, so remove it from arguments.
    arguments.removeFirst()
    let configuration = try Configuration(arguments: arguments)
    let converter = Converter(configuration: configuration)
    converter.parse()
} catch let error as Configuration.ConfigurationErrors {
    print("CPL_XLM2Strings Configuration Error: \(error.description)")
}
