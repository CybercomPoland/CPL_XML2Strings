//
//  main.swift
//  CPL_XML2Strings
//
//  Created by Adrian Ziemecki on 09/10/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

var arguments = CommandLine.arguments
arguments.removeFirst()
let configuration = Configuration(arguments: arguments)
let converter = Converter(configuration: configuration)
converter.parse()
